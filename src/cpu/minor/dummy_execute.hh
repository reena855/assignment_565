#ifndef __CPU_MINOR_DUMMY_EXECUTE_HH__
#define __CPU_MINOR_DUMMY_EXECUTE_HH__

#include "cpu/minor/buffers.hh"
#include "cpu/minor/cpu.hh"
#include "cpu/minor/pipe_data.hh"

namespace Minor
{

class dummyExecute : public Named
{
    protected:
        MinorCPU &cpu;
         /** Input port carrying instructions from Decode */
        Latch<ForwardInstData>::Output inp;

        /** Output port carrying instructions to Execute */
        Latch<ForwardInstData>::Input out;

        /** Interface to reserve space in the next stage */
        std::vector<InputBuffer<ForwardInstData>> &nextStageReserve;
        unsigned int outputWidth;
        bool processMoreThanOneInput;
    
    public: /* Public for Pipeline to be able to pass it to Decode */
        std::vector<InputBuffer<ForwardInstData>> inputBuffer;

      protected:
    /** Data members after this line are cycle-to-cycle state */

    struct dummyExecuteThreadInfo {

        /** Default Constructor */
        dummyExecuteThreadInfo() :
            inputIndex(0),
            execSeqNum(InstId::firstExecSeqNum),
            blocked(false)
        { }

        dummyExecuteThreadInfo(const dummyExecuteThreadInfo& other) :
            inputIndex(other.inputIndex),
            execSeqNum(other.execSeqNum), 
            blocked(other.blocked)
        { }


        /** Index into the inputBuffer's head marking the start of unhandled
         *  instructions */
        unsigned int inputIndex;

        /** True when we're in the process of decomposing a micro-op and
         *  microopPC will be valid.  This is only the case when there isn't
         *  sufficient space in Executes input buffer to take the whole of a
         *  decomposed instruction and some of that instructions micro-ops must
         *  be generated in a later cycle */
        //bool inMacroop;
        //TheISA::PCState microopPC;

        /** Source of execSeqNums to number instructions. */
        InstSeqNum execSeqNum;

        /** Blocked indication for report */
        bool blocked;
    };

    std::vector<dummyExecuteThreadInfo> dummyExecuteInfo;
    ThreadID threadPriority;

  protected:
    /** Get a piece of data to work on, or 0 if there is no data. */
    const ForwardInstData *getInput(ThreadID tid);

    /** Pop an element off the input buffer, if there are any */
    void popInput(ThreadID tid);

    /** Use the current threading policy to determine the next thread to
     *  decode from. */
    ThreadID getScheduledThread();

    public:
        dummyExecute(const std::string &name,
            MinorCPU &cpu_,
            MinorCPUParams &params,
            Latch<ForwardInstData>::Output inp_,
            Latch<ForwardInstData>::Input out_,
            std::vector<InputBuffer<ForwardInstData>> &next_stage_input_buffer);

    public:
        /** Pass on input/buffer data to the output if you can */
        void evaluate();

        void minorTrace() const;

        /** After thread suspension, has Execute been drained of in-flight
         *  instructions and memory accesses. */
        bool isDrained();


};

}


#endif /* __CPU_MINOR_DUMMY_EXECUTE_HH__ */
