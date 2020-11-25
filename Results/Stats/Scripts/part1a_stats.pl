

$stat_file = "part1a_results/stats.txt";
$report_file = "Report/part1a/results.csv";

open('RPT', '>', "$report_file") or die "part1a report file not found\n";
open('STAT', '<', "$stat_file") or die "part1a stat file not found\n";
@stat_lines = <STAT>;


print RPT "op_class, num_inst, percent_inst\n"; 

for $line(@stat_lines) {
	chomp($line);
	if ($line =~ /^(system.cpu.op_class\:\:)(\w+)(\s*)(\d*)(\s*)(\d*[.]\d*%)(\s*)(\d*[.]\d*%)(\s*)(#.*)/) {
		$op = $2;
                $num_inst = $4;
                $percentage_inst = $6;
		print RPT "$op,$num_inst,$percentage_inst\n";
	}

}
