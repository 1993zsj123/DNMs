#!/bin/env perl
use strict;
use warnings;
use threads;
use threads::shared;
die "Usage: perl $0 <vcf_file> <depth_dam> <depth_sire> <depth_proband>\n" unless @ARGV == 4;
my $vcf_file= shift;
die "vcf file not found\n" unless -e $vcf_file;
my $depth_dam = shift;
die "depth dam not correct\n" unless $depth_dam =~ /^\d+$/;
my $depth_sire = shift;
die "depth sire not correct\n" unless $depth_sire =~ /^\d+$/;
my $depth_proband = shift;
die "depth proband not correct\n" unless $depth_proband =~ /^\d+$/;
open IN, "<", $vcf_file or die $!;
my $reads=<IN>;
until($reads=~/^#CHR/){
	$reads=<IN>;
}
chomp $reads;
while($reads=<IN>)
{
        chomp $reads;
        my @F=split/\s+/,$reads;
        next if ($F[5]<40);
	$F[9] =~ /(\d)\/(\d):(\d+),(\d+)/;
	next if $1 != $2 ||  ($3+$4) < (0.5 * $depth_dam)||  ($3+$4) > (2 * $depth_dam)||($3>1 && $4>1);
	next if $F[10] !~ /$1\/$1/;
	$F[10] =~ /(\d)\/(\d):(\d+),(\d+)/;
	next if $1 != $2||  ($3+$4) < (0.5 * $depth_sire) ||  ($3+$4) > (2 * $depth_sire)||($3>1 && $4>1);
	$F[11] =~ /(\d)\/(\d):(\d+),(\d+)/;
	next if $4 ==0;
	next if $1 == $2 || ($3+$4) < (0.5*$depth_proband) ||  ($3+$4) > (2*$depth_proband)|| $4/($3 +$4) <0.25  || $4/($3 +$4) >0.75;
	print $reads,"\n";
}

