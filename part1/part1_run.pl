#!/usr/bin/perl


$run_cmd = "./build/X86/gem5.opt".
	   " -d part1/timingSimpleCPU".
	   " ./configs/example/se.py".
	   " --cpu-type=TimingSimpleCPU".
	   " --caches".
           " --l2cache".
	   " -c ./part1/a.out";

system($run_cmd);

