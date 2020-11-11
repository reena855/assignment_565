#!/usr/bin/perl

$debug_mode = 0;

for $acc(0,50,100) {

	$Global_Stat_Dir = "Results/Stats/degrade_bp_${acc}_results";
	unless (-e $Global_Stat_Dir or mkdir $Global_Stat_Dir) {
		die "Unable to create stat dir for $opt\n";
	}

	for $bench("sjeng", "libquantum", "bzip2") {
	
		$stat_dir = "${Global_Stat_Dir}/$bench";
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
		           " --l2cache".
			   " --degrade_branch_prediction".
			   " --branch_prediction_accuracy=$acc";

                if ($debug_mode) {
			$run_cmd = $rum_cmd . " --debug-flags=Branch";
		}
		
		print ("$run_cmd\n");
		system($run_cmd);
	}
}