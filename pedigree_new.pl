#!/usr/bin/perl
use warnings;
use strict;

my $path=qx(pwd);
my $sample = shift;

open IN, "<", $sample  or die $!;
my @list;
while(<IN>){
	chomp;
	my ($pedigree, $proband, $depth_proband,$sex, $dam, $depth_dam, $sire, $depth_sire) = split /\s+/;
	open PEDIGREE, ">/xtdisk/wanggd_kiz/zhangsj/pedigree/work/script/$pedigree\_dep.sh";
	print PEDIGREE "#!/bin/bash

#PBS -N $pedigree\_dep.sh
#PBS -o $pedigree\_dep.sh.stdout
#PBS -e $pedigree\_dep.sh.stderr
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



cd $path

#VCF Calling

##First step 
java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T CombineGVCFs \\
-R \$REF \\
-L \$CHRBED \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.gvcf.list \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.g.vcf.gz
 

##Second step
java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T GenotypeGVCFs \\
-nt 4 \\
-R \$REF \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.g.vcf.gz \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf

#VCF Filter

bgzip -f /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf
tabix -p vcf /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf.gz

java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T SelectVariants \\
-R \$REF \\
-L \$CHRBED \\
-selectType  SNP \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf.gz \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.raw.vcf.gz


java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T SelectVariants \\
-R \$REF \\
-L \$CHRBED \\
-selectType  INDEL \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf.gz \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.raw.vcf.gz


java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T  VariantFiltration \\
-R \$REF \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.raw.vcf.gz \\
--filterExpression \"QD \< 2.0 || FS \> 200.0 || SOR \> 10.0 || InbreedingCoeff<-0.8\" \\
--filterName  \"Filter\" \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.filter.vcf.gz

java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T VariantFiltration \\
-R \$REF \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.raw.vcf.gz \\
--filterExpression \"QD \< 2.0 || FS \> 60.0 || MQ \< 40.0 || QUAL \< 50.0 || SOR \> 3.0 || MQRankSum \< -12.5\" \\
--filterName \"Filter\" \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filter.vcf.gz

gatk \\
MergeVcfs \\
-I /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.filter.vcf.gz \\
-I /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filter.vcf.gz \\
-O /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filter.vcf.gz

java -Xmx16g -Xms16g -Djava.io.tmpdir=1rst/temp \\
-jar \$GATK \\
-T SelectVariants \\
-R \$REF \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filter.vcf.gz \\
-ef -o /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filtered.vcf.gz

#rm
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.g.vcf.gz
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree\_all.raw.vcf.gz
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.raw.vcf.gz
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.raw.vcf.gz
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.snp.filter.vcf.gz 
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.indel.filter.vcf.gz 
rm /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filter.vcf.gz

#DNM
mkdir -p /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree
mkdir -p /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk
mkdir -p /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/overlap

##GATK

java -Xmx8g  -jar \$GATK -R \$REF -T SelectVariants \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filtered.vcf.gz \\
-sn $proband -env \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/son_$proband.vcf

java -Xmx8g  -jar \$GATK -R \$REF -T SelectVariants \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filtered.vcf.gz \\
-sn $dam -sn $sire -env \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/parent_$dam\_$sire.vcf

java -Xmx8g  -jar \$GATK -R \$REF -T SelectVariants \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/son_$proband.vcf \\
--discordance /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/parent_$dam\_$sire.vcf \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/denovo_$pedigree.vcf

java -Xmx8g  -jar \$GATK -R \$REF -T SelectVariants \\
-V /xtdisk/wanggd_kiz/zhangsj/pedigree/data/vcf/$pedigree.all.filtered.vcf.gz \\
--concordance /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/denovo_$pedigree.vcf \\
-o /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/fam-denovo_$pedigree.vcf

\$VCFTOOLS --vcf  /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/fam-denovo_$pedigree.vcf \\
--min-meanDP 12 --max-missing 1 --remove-indels --max-alleles 2 --recode \\
--out /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/trio_$pedigree.filtered

\$BCFTOOLS  view  -s $dam,$sire,$proband \\
/xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/trio_$pedigree.filtered.recode.vcf > /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/trio_$pedigree.filtered.vcf

perl \$FILTERE /xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/trio_$pedigree.filtered.vcf $depth_dam $depth_sire $depth_proband >/xtdisk/wanggd_kiz/zhangsj/pedigree/work/$pedigree/gatk/$pedigree\_gatk.dep.vcf
";
}
