#!/usr/bin/perl 
use strict;
use Getopt::Long;
  my $length = 24;
  my $verbose;
  my %dateHash = ();
  my %idHash = ();
  my ($year, $month, $day, $verbose, $date, $type, $countryCode, $stationID, $century );
  my @centuries = sort {$a <=> $b} (1700,1800,1900,2000);
  my @baseMM = sort {$a <=> $b} qw (01 02 03 04 05 06 07 08 09 10 11 12);
  my @types = qw(PRCP SNOW SNWD TMAX TMIN ALL); 
  my $baseRawDir = "/home/alexmac/data/NOAA/GHCN_Daily/";

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

  GetOptions ("dater=i" => \$date,    # numeric
              "type=s"   => \$type,      # string
              "Country=s"   => \$countryCode,      # string
              "stationid=s"   => \$stationID,      # string
              "verbose"  => \$verbose)   # flag
  or die("Error in command line arguments\n");

  # make sure its either YYYY MM  DD
  if ($date !~ /(?:^\d{4}$|^\d{6}$|^\d{8}$)/) {
  		print "bad year ", $date , $1,	 "\n";
  }
  else {
  		# break it down and check if we have the range
  		($year, $month, $day) = ($date =~ /(\d{4})(\d{0,2})(\d{0,2})/)[0,1,2];
  		$century = int($year / 100) * 100;
  		if (!grep {/$century/} @centuries) {
  			print "Century range must be ", $centuries[0] , " to ", $centuries[-1], "\n";
  		}
  		if (($month) && (!grep {/$month/} @baseMM)) {
  			print "Month must be between  " , $baseMM[0] , " ", $baseMM[-1], " \n";
  		}
 }

 if (!grep {/(^$type$)/i} @types) {

 	print "The data type given \"$type\" is not available select from list below\n";
	foreach my $tmp (@types) {
		print "\t",	 $tmp, "\n";

	}
 	print "\n";
 }

if ($date eq $year) {
	print "we scan directory \n";
	getFilelist({"century" => $century,"rawdir" => $baseRawDir});
}
else {
	print "we open a file \n";
}

exit;
my $start = time;

#if the file is yyyy , we want a specific century
# 		scan the whole dir and process for that type
#if we say yyyymm then we only want to process that file for that month
#		scan the file only for that month
#if we say yyyymmdd then we only want that day
#		scan only for that day

#alex#STATION,DATE (yyyymmdd),TYPE,reading,XX,YY,ZZ,TIME (HHMM)
#alex
#alex
$SIG{'INT'} = sub {
	print "interupted processing \n";
	exit;
};


sub getFilelist {
	my $args =  shift;
	# read the directory  to process
    my $currentDir = $args->{rawdir} . $args->{century};
	opendir(DIR, $currentDir) || die "\n\nError:\nCan not read directory $currentDir.\n$!  $^E. \n\n";
 		my @filelist = grep {/csv$/i} readdir(DIR);
	closedir (DIR);
	return @filelist;
}

#alexforeach my $filename (@filelist) {


#alex	next if $filename !~ /\.csv$/;
#alex	my $checkdup = ($filename =~ /(\w+).csv$/)[0];
#alex	my @matched =  grep /$checkdup/, @maxlist;
#alex	if (scalar(@matched) > 0) {
#alex		print "$filename  already processed\n";
#alex		next;
#alex	}
#alex	else {
#alex		print "processing $filename \n";
#alex	}


sub processFile {

	my $args = shift; 

	return;
	my $currentDir;
	my $filename;
	#Pass in file , type , century, if all is type then all repeated for each type
	#load the single file data 
	open (DATA, $currentDir . "/".  $filename) || die "can not open $filename $! \n";
		my @data = <DATA>;
		chomp(@data);
	close (DATA);
	
	#process the rows.
	foreach my $tmp (@data) {
		my @dataPoints  = split(/,/, $tmp) ;	

		#only process TMAX
		if ($dataPoints[$fieldsHash{'observation_type'}] eq "TMAX" ) {
			my $datea = $dataPoints[$fieldsHash{'date'}];
			if (exists  $dateHash{$datea} ) {
#				push ($dateHash{$datea} ,$dataPoints[$fieldsHash{'stationid'}]);
			}
			else { 
			#	$dateHash{$datea}  = [];
#				push ($dateHash{$datea} ,$dataPoints[$fieldsHash{'stationid'}]);
			}
			#my $dateW = "$datea " . $dataPoints[$fieldsHash{'observation_value'}];
			if (exists  $idHash{$dataPoints[$fieldsHash{'stationid'}]} ) {
#				push ($idHash{$dataPoints[$fieldsHash{'stationid'}]} ,$dateW);
			}
			else { 
				#$idHash{$dataPoints[$fieldsHash{'stationid'}]}  = [];
				#push ($idHash{$dataPoints[$fieldsHash{'stationid'}]} ,$dateW);
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
			#	print OUT "{\"station\":$id ,\"lat\": $stations{$id}{'lat'}, \"lng\":$stations{$id}{'lng'}, \"TMAX:\": $temperature },\n";
			}
		}
		print OUT "]\n},\n";
	}
	close (OUT);
	%dateHash = ();
	%idHash = ();
}

#alexEND {
#alexprint "report generated in ", time - $start, " seconds.\n";
#alex
#alex}
