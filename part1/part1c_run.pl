#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d part1/part1c_results".
	   " ./configs/example/se.py".
	   " --cpu-type=MinorCPU".
	   " --caches".
           " --l2cache".
	   " --fpu_operation_latency=6".
	   " --fpu_issue_latency=1".
	   " -c ./part1/daxpy_part1b";

system($run_cmd);

