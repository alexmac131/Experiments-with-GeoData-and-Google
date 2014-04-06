#!/usr/bin/perl -w
use strict;
my $start = time;


my $currentDir =  $ENV{'PWD'};
my $maxDir =  $ENV{'PWD'} . "/TMAX";



# read the directory already done
opendir(MAX, $maxDir) || die " can not read directory $!  $^E \n";
 	my @maxlist = readdir(MAX);
closedir (MAX);

my @fixed = grep {/fix$/} @maxlist;
# go through the file list we got
foreach my $filename (@maxlist) {
	next if $filename !~ /\.json$/;
	
	if (grep {/$filename/} @fixed) {
		next;
	}
	print "===> $filename \n";

	#load the single file data 
	open (DATA, $maxDir . "/".  $filename) || die "can not open $filename $! \n";
	#process the rows.
	my $group = "";

	open (FIX, ">" . $maxDir . "/" . $filename . ".fix") || die "Can not open fix file $! ";
	
	my $preset = 0;
	my $id = "";
	my $thermal = "";

	while (my $tmp = <DATA>) { 
		chomp($tmp);
		if ($tmp =~ /station\":(\"\w+\")/) {
			#print "-> $tmp  $1\n";
			$id = $1;
			$preset = 1;
		} 
		else {
			if ($preset) {
				$tmp =~ /TMAX:\":\s+(-{0,1}\d+)/;
				$thermal = $1;
				print FIX "\t$id:$thermal\n";
				$preset = 0;
				$id = "";
			}
			else {
				print FIX $tmp , "\n";
			}
		}
        }
	close (DATA);
	close (FIX);
	# now lets write the tempature maps 
}



