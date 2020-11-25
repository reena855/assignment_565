

$stat_file = "part1b_results/stats.txt";
$report_file = "Report/part1b/results.csv";

open('RPT', '>', "$report_file") or die "part1b report file not found\n";
open('STAT', '<', "$stat_file") or die "part1b stat file not found\n";
@stat_lines = <STAT>;



for $line(@stat_lines) {
	chomp($line);

        if ($line =~ /Begin/) {
		print RPT "\n\n\nop_class, num_inst, percent_inst\n"
	}

	elsif ($line =~ /^(system.cpu.op_class\:\:)(\w+)(\s*)(\d*)(\s*)(\d*[.]\d*%)(\s*)(\d*[.]\d*%)(\s*)(#.*)/) {
		$op = $2;
                $num_inst = $4;
                $percentage_inst = $6;
		print RPT "$op,$num_inst,$percentage_inst\n";
	}

}
