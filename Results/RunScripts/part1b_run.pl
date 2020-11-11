#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d Results/Stats/part1b_results".
	   " ./configs/example/se.py".
	   " --cpu-type=TimingSimpleCPU".
	   " --caches".
           " --l2cache".
	   " -c Results/MyBench/daxpy_part1b";

system($run_cmd);

