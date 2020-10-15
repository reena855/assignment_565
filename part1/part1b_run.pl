#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d part1/part1b_results".
	   " ./configs/example/se.py".
	   " --cpu-type=TimingSimpleCPU".
	   " --caches".
           " --l2cache".
	   " -c ./part1/daxpy_hooks";

system($run_cmd);

