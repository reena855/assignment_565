#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d Results/Stats/part1a_results".
	   " ./configs/example/se.py".
	   " --cpu-type=TimingSimpleCPU".
	   " --caches".
           " --l2cache".
	   " -c Results/MyBench/daxpy_part1a";

system($run_cmd);

