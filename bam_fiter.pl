#!/usr/bin/perl
use warnings;
use strict;

my $path=qx(pwd);
my $sample = shift;

open IN, "<", $sample  or die $!;
my @list;
while(<IN>){
	chomp;
	my ($pedigree, $proband, $probandcrr, $breed, $sex, $dam, $damcrr, $sire, $sirecrr) = split /\s+/;
	open PEDIGREE, ">/xtdisk/wanggd_kiz/zhangsj/pedigree/analysis/bam_filter/script/$pedigree.sh";
	print PEDIGREE "#!/bin/bash

#PBS -N $pedigree.sh
#PBS -o $pedigree.sh.stdout
#PBS -e $pedigree.sh.stderr
#PBS -q core40
#PBS -l mem=4gb,walltime=572:00:00,nodes=1:ppn=1
#HSCHED -s hschedd
#PPN limit 1
# Description:
set -e
set -u

WORK=/xtdisk/wanggd_kiz/zhangsj/pedigree/work
REF=/xtdisk/wanggd_kiz/zhangsj/ref/Canis_familiaris.CanFam3.1.dna.toplevel.fa
KNOWSITE=/xtdisk/wanggd_kiz/zhangsj/ref/58indiv.unifiedgenotyper.recalibrated_95.5_filtered.pass_snp.vcf
SAMTOOLS=/xtdisk/wanggd_kiz/zhangsj/bin/anaconda3/bin/samtools
PICARD_DIR=/xtdisk/wanggd_kiz/zhangsj/bin/software/picard-tools-1.96
GATK=/xtdisk/wanggd_kiz/zhangsj/bin/software/GenomeAnalysisTK.jar
VCFTOOLS=/xtdisk/wanggd_kiz/zhangsj/bin/anaconda3/bin/vcftools
BCFTOOLS=/xtdisk/wanggd_kiz/zhangsj/bin/software/smcpp/bin/bcftools
CHRBED=/xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/intervals.list
DENOVOGEAR=/xtdisk/wanggd_kiz/zhangsj/bin/software/denovogear-0.5.4-Linux-x86_64/bin/denovogear
TRIODENOVO=/xtdisk/wanggd_kiz/zhangsj/bin/software/triodenovo.0.06/bin/triodenovo
FILTERE=/xtdisk/wanggd_kiz/zhangsj/bin/filtere.pl

#samtools index /asnas/wanggd_kiz/zhangsj/pedigree/data/bam/$probandcrr/$probandcrr.bam

mkdir -p /xtdisk/wanggd_kiz/zhangsj/pedigree/analysis/bam_filter/reads/$proband
for i in \$(cat /xtdisk/wanggd_kiz/zhangsj/pedigree/analysis/bam_filter/dnm/$pedigree\_overlap.dnm.7.vcf.chr)\; \\
do samtools tview  -p  \$i /asnas/wanggd_kiz/zhangsj/pedigree/data/bam/$probandcrr/$probandcrr.bam \\
-d T > /xtdisk/wanggd_kiz/zhangsj/pedigree/analysis/bam_filter/reads/$proband/$proband.\$i.reads \; done

for y in \$(ls /xtdisk/wanggd_kiz/zhangsj/pedigree/analysis/bam_filter/reads/$proband/$proband.*reads)\; \\
do sed \"1,3d\" \$y |cut -b1 | sed '/^[  ]*\$\/d' |tr a-z A-Z | sort | uniq -c | sort -n | sed 's/^[  ]*//' |sed \"s/ /\\t/\" | sed \":label\;N\;s/\\n/\\t/\;b label\">\$y.num \; done

";
}
