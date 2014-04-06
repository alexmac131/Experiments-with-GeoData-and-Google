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
my $endpoint  = scalar (keys %stations);
my $startpoint = 1;
print "[";
my @sorted = sort keys %stations;
foreach my $key (@sorted) {
	
	print "\n{ \n";

	print "\t\"station\": \"$key\",", "\n"; 
	my $inEnd =scalar ( keys %{$stations{$key}});
	my $inSide = 1;
	foreach my $set (keys %{$stations{$key}}) {
		print "\t\"$set\":$stations{$key}->{$set}";
		if ($inSide < $inEnd) {
			print ",\n";
		}
		$inSide++;
	}
	print "\n}";
	if ($startpoint < $endpoint) {
		print ",";
	}
	$startpoint++;
}
print "\n]\n";







