#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d part1/part1a_results".
	   " ./configs/example/se.py".
	   " --cpu-type=TimingSimpleCPU".
	   " --caches".
           " --l2cache".
	   " -c ./part1/daxpy_part1a";

system($run_cmd);

