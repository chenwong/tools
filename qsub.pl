#!/usr/bin/env perl -w
use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);
use File::Path;

if (@ARGV<1) {
	print "perl $Script xxx.sh\n";
	exit;
	# body...
}

open (IN,$ARGV[0]) or die;
my $shdir=dirname($ARGV[0]);
my ($name)=basename($ARGV[0])=~/(.+).sh/;

$shdir="$shdir/$name.qsub";
mkpath($shdir);
$shdir = File::Spec->rel2abs($shdir);
my $count=0;
open (OUT2,">$shdir.sh") or die;
chdir $shdir;
while (<IN>) {
	chomp;
	$count ++;
	my $c=sprintf("%03d",$count);
	my $shfile="$shdir/${name}_$c.sh";
	open (OUT,">$shfile") or die;
	print OUT "$_ && touch $shfile.check\n";
	close OUT;
	print OUT2 "qsub -clear -binding linear:1 -b no -l num_proc=1,vf=5G -cwd -P HUMwxyS  -q bc.q $shfile\n";
}
close IN;
close OUT2;
print "sh $shdir.sh\n";
system("sh $shdir.sh");

