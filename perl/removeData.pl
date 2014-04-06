#!/usr/bin/perl -w
use strict;
my $start = time;

$SIG{'INT'} = sub {exit;};

my $currentDir =  $ENV{'PWD'};
my $maxDir =  $ENV{'PWD'} . "/TMAX";


my %dateHash = ();
my %idHash = ();

# read the directory already done
opendir(MAX, $maxDir) || die " can not read directory $!  $^E \n";
 	my @maxlist = readdir(MAX);
closedir (MAX);


# go through the file list we got
foreach my $filename (@maxlist) {
	next if $filename !~ /\.json$/;
	#load the single file data 
	open (DATA, $maxDir . "/".  $filename) || die "can not open $filename $! \n";
		my @data = <DATA>;
		chomp(@data);
	close (DATA);
	#process the rows.
	my $group = "";
	open (FIX, ">" . $maxDir . "/" . $filename . ".fix") || die "Can not open fix file $! ";
	#print FIX "[";
	my $unit = scalar(@data) -2;
	$data[$unit] =~ s/,$//g;
	#my ($front, $second) = $data[0] =~ /^([)(.*)/;
	$data[0] =~ /(^\[)(.*)/;
	my $top  = $1; 
	my $top2 = $2;	
	shift(@data);
	unshift (@data, $top2);
	unshift (@data, $top);
	print "---\n";
	my $count = 0;	
	foreach my $tmp (@data) {

# ALEX		#print "-> $tmp ";
# ALEX		if ($tmp =~ /^},$/) {
# ALEX			$group .= $tmp;
# ALEX			$group =~ s/ },]/}]/;
		#"lat": 50.0906, "lng":14.4192,
		$tmp =~ s/"lat":\s+-{0,1}\d{1,3}\.\d{0,5},\s+"lng":-{0,1}\d{0,3}\.\d{0,5},//ig;
		$tmp =~ s/{/{\t\n/g;
		$tmp =~ s/}/\n}/g;
		$tmp =~ s/]/]\n/g;
		$tmp =~ s/,/,\n/g;
			#print $tmp . "\n";
			print FIX $tmp . "\n";
			$count++;
# ALEX			$group = "";
# ALEX		}
# ALEX		else {
# ALEX			if ($tmp =~ /\"station\":[^\"]/) {
# ALEX				$tmp =~ s/^(.*\"station\":)(\w+)\s/$1\"$2\"/;
# ALEX			}
# ALEX			$group .= $tmp;
# ALEX		}
        }
# ALEX	print FIX "]";
	close (FIX);
	# now lets write the tempature maps 
	%dateHash = ();
	%idHash = ();
}

print "we have data for ", scalar(keys %dateHash), " dates with ", scalar (keys %idHash), " stations reporting.\n";
print "report generated in ", time - $start, " seconds.\n";


END {
print "report generated in ", time - $start, " seconds.\n";

}
