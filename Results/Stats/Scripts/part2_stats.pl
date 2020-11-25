

@benchmarks = ("bzip2", "libquantum", "sjeng");
@options = ("with_bp", "disable_bp", "degrade_bp_0", "degrade_bp_50", "degrade_bp_100");

$report_file = "Report/part2/results.csv";

open('RPT', '>', "$report_file") or die "part2 report file not found\n";

for $bench(@benchmarks) {

	print RPT "\n\n$bench\n";
        print RPT "\noption, condPredicted, condIncorrect, degraded_predictions, correct_predictions, cpi, ipc\n";
	
	for $opt(@options) {
		
		$stat_file = "${opt}_results/${bench}/stats.txt";
		open('STAT', '<', "$stat_file") or die "$opt stat file for $bench not found\n";
		@stat_lines = <STAT>;

		for $line(@stat_lines) {
			chomp($line);
		
			if ($line =~ /^(system.cpu.branchPred.condPredicted\s*)(\d*)(\s*)(\s*)(#.*)/) {
				$condPredicted = $2;
			}
			
   			elsif ($line =~ /^(system.cpu.branchPred.condIncorrect\s*)(\d*)(\s*)(\s*)(#.*)/) {
				$condIncorrect = $2;
			}
   			
   			elsif ($line =~ /^(system.cpu.fetch2.correct_branch_predictions\s*)(\d*)(\s*)(\s*)(#.*)/) {
				$correct_branch_predictions = $2;
			}
		
   			elsif ($line =~ /^(system.cpu.fetch2.degraded_branch_predictions\s*)(\d*)(\s*)(\s*)(#.*)/) {
				$degraded_branch_predictions = $2;
			}
   			
			elsif ($line =~ /^(system.cpu.cpi\s*)(\d*[.]\d*)(\s*)(\s*)(#.*)/) {
				$cpi = $2;
			}
			
			elsif ($line =~ /^(system.cpu.ipc\s*)(\d*[.]\d*)(\s*)(\s*)(#.*)/) {
				$ipc = $2;
				
				print RPT "$opt, $condPredicted, $condIncorrect, $degraded_branch_predictions, $correct_branch_predictions, $cpi, $ipc\n";
			}
		}
	}
}
