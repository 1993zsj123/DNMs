#!/usr/bin/perl
use warnings;
use strict;

my $path=qx(pwd);
my $sample = shift;

open IN, "<", $sample  or die $!;
my @list;
while(<IN>){
	chomp;
	my ($pedigree, $sample1, $depa1, $depa2, $sample2, $depb1, $depb2, $sample3, $depc1, $depc2, $awk1, $awk2) = split /\s+/;
	open PEDIGREE, ">/asnas/wanggd_kiz/zhangsj/pedigree/mutation_rate/split/chr/script/$pedigree.sh";
	print PEDIGREE "#!/bin/bash

#PBS -N $pedigree.sh
#PBS -o $pedigree.sh.stdout
#PBS -e $pedigree.sh.stderr
#PBS -q core24
#PBS -l mem=6gb,walltime=572:00:00,nodes=1:ppn=1
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
FILTERE=/xtdisk/wanggd_kiz/zhangsj/bin/filtere.pl



cd /asnas/wanggd_kiz/zhangsj/pedigree/mutation_rate/split/chr/work



vcftools --gzvcf $pedigree\_all.g.vcf.gz  --bed  /asnas/wanggd_kiz/zhangsj/pedigree/mutation_rate/split/chr/script/dog_cpgIslandExt.bed --recode --out $pedigree\_cpg
cut -f 10,11,12 $pedigree\_cpg.recode.vcf | awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 {print \$0}\' | wc -l >$pedigree.cpg.num
vcftools --gzvcf /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filtered.vcf.gz   --bed  /asnas/wanggd_kiz/zhangsj/pedigree/mutation_rate/split/chr/script/dog_cpgIslandExt.bed --recode --out $pedigree\_cpg.snp
cut -f 10,11,12 $pedigree\_cpg.snp.recode.vcf | awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 && \$$awk1  !~ /0\\/0/  && \$$awk2 !~ /0\\/0/{print \$0}\' | wc -l >>$pedigree.cpg.num


zgrep \'^X\' $pedigree\_all.g.vcf.gz |awk -v FS=\"\\t\" -v OFS=\"\\t\" '\$2<=6800000\' | cut -f 10,11,12 | awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 {print \$0}\' | wc -l >$pedigree.PAR.num 
zgrep \'^X\' /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filtered.vcf.gz |awk -v FS=\"\\t\" -v OFS=\"\\t\" '\$2<=6800000\' | cut -f 10,11,12| awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 && \$$awk1  !~ /0\\/0/  && \$$awk2 !~ /0\\/0/{print \$0}\' | wc -l >>$pedigree.PAR.num 
zgrep \'^X\' $pedigree\_all.g.vcf.gz | cut -f 10,11,12 | awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 {print \$0}\' | wc -l >$pedigree.X.num 
zgrep \'^X\' /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filtered.vcf.gz | cut -f 10,11,12| awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 && \$$awk1  !~ /0\\/0/  && \$$awk2 !~ /0\\/0/{print \$0}\' | wc -l >>$pedigree.X.num 

for i in \{1..38\} \; 
do zgrep \"^\$i\" $pedigree\_all.g.vcf.gz | cut -f 10,11,12 | awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 {print \$0}\' | wc -l >$pedigree.\$i.num \; done 
for i in \{1..38\} \; 
do zgrep \"^\$i\" /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filtered.vcf.gz | cut -f 10,11,12| awk -F \":\" \'\$3>=$depa1 && \$3<=$depa2 && \$7>=$depb1 && \$7<=$depb2 && \$11>=$depc1 && \$11<=$depc2 && \$$awk1  !~ /0\\/0/  && \$$awk2 !~ /0\\/0/{print \$0}\' | wc -l >>$pedigree.\$i.num \;done




";
}
