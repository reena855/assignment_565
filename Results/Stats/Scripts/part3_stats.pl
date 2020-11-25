

@benchmarks = ("bzip2", "libquantum", "sjeng");
@options = ("default", "disable_bp");

$report_file = "Report/part3/results.csv";

open('RPT', '>', "$report_file") or die "part3 report file not found\n";

for $bench(@benchmarks) {

	print RPT "\n\n$bench\n";
        print RPT "\noption, cpi\n";
	
	for $opt(@options) {
		
		$stat_file = "part3_results/${opt}/${bench}/stats.txt";
		open('STAT', '<', "$stat_file") or die "$opt stat file for $bench not found\n";
		@stat_lines = <STAT>;

		for $line(@stat_lines) {
			chomp($line);
		
			if ($line =~ /^(system.cpu.cpi\s*)(\d*[.]\d*)(\s*)(\s*)(#.*)/) {
				$cpi = $2;
				
				print RPT "$opt, $cpi\n";
			}
		}
	}
}
