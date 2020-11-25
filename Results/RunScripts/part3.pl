#!/usr/bin/perl

$debug_mode = 0;

$Global_Stat_Dir = "Results/Stats/part3_results";
unless (-e $Global_Stat_Dir or mkdir $Global_Stat_Dir) {
	die "Unable to create stat dir for $opt\n";
}

for $opt("default", "disable_bp") {

	$Current_Stat_Dir = "${Global_Stat_Dir}/$opt";
	unless (-e $Current_Stat_Dir or mkdir $Current_Stat_Dir) {
		die "Unable to create stat dir for $opt\n";
	}
	
	for $bench("sjeng", "libquantum", "bzip2") {
	
		$stat_dir = "${Current_Stat_Dir}/$bench";
		unless (-e $stat_dir or mkdir $stat_dir) {
			die "Unable to create stat dir\n";
		}
		
	
		$run_cmd = "./build/ARM/gem5.opt".
		           " -d ${stat_dir}".
		           " configs/spec2k6/run.py".
		           " -b $bench".
		           " --maxinsts=100000000".
			   " --cpu-type=MinorCPU".
		           " --l1d_size=64kB".
		           " --l1i_size=16kB".
			   " --caches".
		           " --l2cache";
	
	        if ($debug_mode) {
			$run_cmd = $run_cmd . " --debug-flags=Branch";
		}
	        
		if ($opt eq "disable_bp") {
			$run_cmd = $run_cmd . " --disable_branch_prediction";
		}
		
		print ("$run_cmd\n");
		system($run_cmd);
	}
}

