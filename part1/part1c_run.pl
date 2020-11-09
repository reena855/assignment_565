#!/usr/bin/perl


$Global_stat_dir = "part1/part1c_results";

for $issue_lat(1,2,3,4,5,6) {

	$op_lat = 7 - $issue_lat;
	
	$stat_dir = "${Global_stat_dir}/fpu_${op_lat}_${issue_lat}";
	unless (-e $stat_dir or mkdir $stat_dir) {
		die "Unable to create stat dir\n";
	}
	
	$run_cmd = "./build/X86/gem5.opt".
		   " -d ${stat_dir}".
		   " ./configs/example/se.py".
		   " --cpu-type=MinorCPU".
		   " --caches".
	           " --l2cache".
		   " --fpu_operation_latency=$op_lat".
		   " --fpu_issue_latency=$issue_lat".
		   " -c ./part1/daxpy_part1b";
	
	print ("$run_cmd\n");
	system($run_cmd);
}

