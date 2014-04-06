#!/usr/bin/perl -w
use strict;
my $start = time;


my $stationinfo = "/home/alexmac/data/NOAA/GHCN_Daily/stations.txt";
open(FILE, $stationinfo) || die "Can not open $stationinfo $! \n";
	my @stationinfo = <FILE>;
close(FILE);

my %stations;

foreach my $tmp (@stationinfo) {
	chomp($tmp);
	my @aaa = split(/\s+/, $tmp);
	#print $aaa[0], " " . $aaa[2], "\n";
	$stations{$aaa[0]} = { "lat" => $aaa[1], "lng" => $aaa[2]}; 

}


$SIG{'INT'} = sub {exit;};

my $currentDir =  $ENV{'PWD'};
my $maxDir =  $ENV{'PWD'} . "/TMAX";

open (CODEID, $currentDir . "/stationsCodes.txt") || die " can not read stationsCodes $! \n";
	my @IDS = <CODEID>;
close(CODEID);

my %fieldsHash = ( 
"stationid" => 0,
"date" => 1,
"observation_type" => 2,
"observation_value" => 3,
"observation_time" => 4,
"observation_blank" => 5,
"observation_blank" => 6,
"observation_blank" => 7,


);

my %dateHash = ();
my %idHash = ();

# read the directory  to process
opendir(DIR, $currentDir) || die " can not read directory $!  $^E \n";
 	my @filelist = readdir(DIR);
closedir (DIR);

# read the directory already done
opendir(MAX, $maxDir) || die " can not read directory $!  $^E \n";
 	my @maxlist = readdir(MAX);
closedir (MAX);



# go through the file list we got
foreach my $filename (@filelist) {
	next if $filename !~ /\.csv$/;
	my $checkdup = ($filename =~ /(\w+).csv$/)[0];
	my @matched =  grep /$checkdup/, @maxlist;
	if (scalar(@matched) > 0) {
		print "$filename  already processed\n";
		next;
	}
	else {
		print "processing $filename \n";
	}
	#load the single file data 
	open (DATA, $currentDir . "/".  $filename) || die "can not open $filename $! \n";
		my @data = <DATA>;
		chomp(@data);
	close (DATA);
	
	# sort that data 
        my @sortedData = sort {$a cmp $b} @data;

	#process the rows.
	foreach my $tmp (@sortedData) {
		my @dataPoints  = split(/,/, $tmp) ;	

		#only process TMAX
		if ($dataPoints[$fieldsHash{'observation_type'}] eq "TMAX" ) {
			my $datea = $dataPoints[$fieldsHash{'date'}];
			if (exists  $dateHash{$datea} ) {
				push ($dateHash{$datea} ,$dataPoints[$fieldsHash{'stationid'}]);
			}
			else { 
				$dateHash{$datea}  = [];
				push ($dateHash{$datea} ,$dataPoints[$fieldsHash{'stationid'}]);
			}
			my $dateW = "$datea " . $dataPoints[$fieldsHash{'observation_value'}];
			if (exists  $idHash{$dataPoints[$fieldsHash{'stationid'}]} ) {
				push ($idHash{$dataPoints[$fieldsHash{'stationid'}]} ,$dateW);
			}
			else { 
				$idHash{$dataPoints[$fieldsHash{'stationid'}]}  = [];
				push ($idHash{$dataPoints[$fieldsHash{'stationid'}]} ,$dateW);
			}
		}
        }
	# now lets write the tempature maps 
	my @dates = keys %dateHash;
	my @sortedDates =  sort {$b <=> $a} @dates;
	$filename =~ s/csv$/json/;
	open (OUT, ">TMAX/$filename") || die "can't write file because $!\n";
	foreach my $date (@sortedDates) {
		print OUT "{\n \"date\": $date, \n\"data\":[";
		foreach my $id (@{$dateHash{$date}}) {
			my @datelist = grep /$date/, @{$idHash{$id}};
			foreach my $tmp (@datelist) {
				my (undef, $temperature) = split (/\s+/, $tmp);
				print OUT "{\"station\":$id ,\"lat\": $stations{$id}{'lat'}, \"lng\":$stations{$id}{'lng'}, \"TMAX:\": $temperature },\n";
			}
		}
		print OUT "]\n},\n";
	}
	close (OUT);
	%dateHash = ();
	%idHash = ();
}

print "we have data for ", scalar(keys %dateHash), " dates with ", scalar (keys %idHash), " stations reporting.\n";
print "report generated in ", time - $start, " seconds.\n";


END {
print "report generated in ", time - $start, " seconds.\n";

}
