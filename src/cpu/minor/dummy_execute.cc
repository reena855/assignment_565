#include "cpu/minor/dummy_execute.hh"

#include "cpu/minor/pipeline.hh"
#include "debug/Decode.hh"
#include "debug/MinorTrace.hh"

namespace Minor
{

dummyExecute::dummyExecute(const std::string &name,
    MinorCPU &cpu_,
    MinorCPUParams &params,
    Latch<ForwardInstData>::Output inp_,
    Latch<ForwardInstData>::Input out_,
    std::vector<InputBuffer<ForwardInstData>> &next_stage_input_buffer) :
    Named(name),
    cpu(cpu_),
    inp(inp_),
    out(out_),
    nextStageReserve(next_stage_input_buffer),
    outputWidth(params.dummyExecuteInputWidth),
    processMoreThanOneInput(params.dummyExecuteCycleInput),
    dummyExecuteInfo(params.numThreads),
    threadPriority(0)
   

{
    if (outputWidth < 1)
        fatal("%s: executeInputWidth must be >= 1 (%d)\n", name, outputWidth);

    if (params.dummyExecuteInputBufferSize < 1) {
        fatal("%s: decodeInputBufferSize must be >= 1 (%d)\n", name,
        params.decodeInputBufferSize);
    }
        /* Per-thread input buffers */
    for (ThreadID tid = 0; tid < params.numThreads; tid++) {
        inputBuffer.push_back(
            InputBuffer<ForwardInstData>(
                name + ".inputBuffer" + std::to_string(tid), "insts",
                params.dummyExecuteInputBufferSize));
    }
}

const ForwardInstData *
dummyExecute::getInput(ThreadID tid)
{
    /* Get insts from the inputBuffer to work with */
    if (!inputBuffer[tid].empty()) {
        const ForwardInstData &head = inputBuffer[tid].front();

        return (head.isBubble() ? NULL : &(inputBuffer[tid].front()));
    } else {
        return NULL;
    }
}

void
dummyExecute::popInput(ThreadID tid)
{
    if (!inputBuffer[tid].empty())
        inputBuffer[tid].pop();

    dummyExecuteInfo[tid].inputIndex = 0;
    
}

void
dummyExecute::evaluate()
{
    /* Push input onto appropriate input buffer */
    if (!inp.outputWire->isBubble())
        inputBuffer[inp.outputWire->threadId].setTail(*inp.outputWire);

    ForwardInstData &insts_out = *out.inputWire;

    assert(insts_out.isBubble());

    for (ThreadID tid = 0; tid < cpu.numThreads; tid++)
        dummyExecuteInfo[tid].blocked = !nextStageReserve[tid].canReserve();

    ThreadID tid = getScheduledThread(); // RE: Re-Scheduling. 

    if (tid != InvalidThreadID) {
        dummyExecuteThreadInfo &dummyExecute_info = dummyExecuteInfo[tid];
        const ForwardInstData *insts_in = getInput(tid);

        unsigned int output_index = 0; // RE: will never be incremented

	while (insts_in &&
	           dummyExecute_info.inputIndex < insts_in->width() && /* Still more input */
	           output_index < outputWidth /* Still more output to fill */)
	   {


            MinorDynInstPtr inst = insts_in->insts[dummyExecute_info.inputIndex];

            if (inst->isBubble()) {
                /* Skip */
                dummyExecute_info.inputIndex++;
                
            } else {
                StaticInstPtr static_inst = inst->staticInst;
                /* Static inst of a macro-op above the output_inst */
                StaticInstPtr parent_static_inst = NULL;
                MinorDynInstPtr output_inst = inst;

                if (inst->isFault()) {
                    DPRINTF(Decode, "Execute 1 Fault being passed: %d\n",
                        inst->fault->name());

                    dummyExecute_info.inputIndex++;
                    
                   } else {
                    /* Doesn't need decomposing, pass on instruction */
                    DPRINTF(Decode, "Execute 1 Passing on inst: %s inputIndex:"
                        " %d output_index: %d\n",
                        *output_inst, dummyExecute_info.inputIndex, output_index);

                    parent_static_inst = static_inst;

                    /* Step input */
                    dummyExecute_info.inputIndex++;
                    
                }
                  
                /* Set execSeqNum of output_inst */
                output_inst->id.execSeqNum = dummyExecute_info.execSeqNum;

                /* Step to next sequence number */
                dummyExecute_info.execSeqNum++;
            	
                /* Correctly size the output before writing */
                if (output_index == 0) insts_out.resize(outputWidth);


                /* Set output */
                insts_out.insts[output_index] = output_inst;
		output_index++;
            }

            /* Have we finished with the input? */
            if (dummyExecute_info.inputIndex == insts_in->width()) {
              
              
                popInput(tid);
                insts_in = NULL;

                if (processMoreThanOneInput) {
                    DPRINTF(Decode, "Execute 1 here Wrapping\n");
                    insts_in = getInput(tid);
                }
            }
	}
        
    }

    
    if (!insts_out.isBubble()) {
        /* Note activity of following buffer */
        cpu.activityRecorder->activity();
        insts_out.threadId = tid;
        nextStageReserve[tid].reserve();
    }

    
    for (ThreadID i = 0; i < cpu.numThreads; i++)
    {
        if (getInput(i) && nextStageReserve[i].canReserve()) {
            cpu.activityRecorder->activateStage(Pipeline::dummyExecuteStageId);
            break;
        }
    }

    /* Make sure the input (if any left) is pushed */
    if (!inp.outputWire->isBubble())
        inputBuffer[inp.outputWire->threadId].pushTail();
}



inline ThreadID
dummyExecute::getScheduledThread()
{
    /* Select thread via policy. */
    std::vector<ThreadID> priority_list;

    switch (cpu.threadPolicy) {
      case Enums::SingleThreaded:
        priority_list.push_back(0);
        break;
      case Enums::RoundRobin:
        priority_list = cpu.roundRobinPriority(threadPriority);
        break;
      case Enums::Random:
        priority_list = cpu.randomPriority();
        break;
      default:
        panic("Unknown fetch policy");
    }

    for (auto tid : priority_list) {
        if (getInput(tid) && !dummyExecuteInfo[tid].blocked) {
            threadPriority = tid;
            return tid;
        }
    }

   return InvalidThreadID;
}

bool
dummyExecute::isDrained()
{
    for (const auto &buffer : inputBuffer) {
        if (!buffer.empty())
            return false;
    }

    return (*inp.outputWire).isBubble();
}


}
