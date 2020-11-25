

$report_file = "Report/part1c/results.csv";
open('RPT', '>', "$report_file") or die "part1c report file not found\n";

print RPT "opLat, issueLat, CPI, sim_ticks\n";

for $op_lat(1,2,3,4,5,6) {

	$issue_lat = 7-$op_lat;

	$stat_file = "part1c_results/fpu_${op_lat}_${issue_lat}/stats.txt";
	open('STAT', '<', "$stat_file") or die "part1c stat file for ${op_lat}_${issue_lat} not found\n";
	@stat_lines = <STAT>;


	for $line(@stat_lines) {
		chomp($line);
		
		if ($line =~ /^(sim_ticks\s*)(\d*)(\s*#.*)/) {
			$sim_ticks = $2;
		}
		
		elsif ($line =~ /^(system.cpu.cpi\s*)(\d*[.]\d*)(\s*#.*)/) {
			$cpi = $2;
	
			print RPT "$op_lat, $issue_lat, $cpi, $sim_ticks\n";
		}
	
	}

}
