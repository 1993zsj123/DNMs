DNMs: De Novo Mutation Identification and Mutation Rate Calculation
Project Overview
This repository contains a set of scripts for identifying de novo mutations (DNMs) and calculating mutation rates using trio family sequencing data from the domestic dog (Canis familiaris). The main script, pedigree.pl, orchestrates the process from variable calling data (GVCF files) to the identification of DNMs. Additional scripts, bam_fiter.pl, filtere.pl, and callable_sites.pl, provide specialized functionalities for filtering, validating, and analyzing the data.
Project Purpose
The primary goal of this project is to:

Detect de novo mutations (DNMs) in offspring (proband) compared to their parents (dam and sire) in a trio setting.
Calculate mutation rates across different genomic regions, such as CpG islands, pseudoautosomal regions (PAR), the X chromosome, and autosomes.
Provide a robust pipeline for genetic analysis in pedigree-based studies.

The project is tailored for high-performance computing (HPC) environments and uses standard bioinformatics tools like GATK, VCFtools, BCFtools, and samtools.

Scripts Overview
1. pedigree.pl

Purpose: This is the main script that automates the entire pipeline for variant calling, filtering, and DNM identification.
Functionality:
Reads a sample file containing pedigree information (e.g., pedigree ID, proband, dam, sire, and their depths).
For each pedigree, generates a bash script that:
Combines GVCF files for the trio using GATK's CombineGVCFs.
Performs genotyping with GATK's GenotypeGVCFs.
Filters variants to separate SNPs and INDELs, applying quality filters (e.g., QD, FS, MQ, SOR).
Merges filtered results and identifies discordant genotypes between parents and offspring to detect DNMs.


Uses tools like GATK, VCFtools, BCFtools, and samtools.


Input: A sample file with pedigree details (e.g., pedigree proband depth_proband sex dam depth_dam sire depth_sire).
Output: Filtered VCF files containing potential DNMs for each pedigree.

2. filtere.pl

Purpose: Filters VCF files to identify high-confidence DNMs based on quality, genotype consistency, and read depth.
Functionality:
Takes a VCF file and expected depth values for the dam, sire, and proband as input.
Applies filters such as:
Quality score > 40.
Dam: Heterozygous genotype with read depth within 50%-200% of expected depth.
Sire: Homozygous genotype consistent with the dam's allele.
Proband: Heterozygous genotype with allele frequency between 25% and 75%.


Ensures variants meet inheritance patterns and quality standards.


Input: VCF file, depth values for dam, sire, and proband.
Output: Filtered VCF file with high-confidence DNMs.

3. bam_fiter.pl

Purpose: Validates DNMs by extracting and analyzing reads from BAM files at suspected DNM positions.
Functionality:
Generates bash scripts for each pedigree.
Uses samtools tview to extract reads from BAM files of the proband, dam, and sire at positions listed in a DNM list file.
Processes the extracted reads to count nucleotide frequencies (A, T, G, C) at those positions.
Helps identify potential artifacts or errors in the sequencing data.


Input: BAM files for the trio and a list of DNM positions.
Output: Files containing read counts and nucleotide frequencies for each DNM position.

4. callable_sites.pl

Purpose: Calculates variant counts in specific genomic regions (e.g., CpG islands, PAR, X chromosome, autosomes) for mutation rate analysis.
Functionality:
Generates bash scripts for each pedigree.
Processes VCF files to count variants in predefined regions:
CpG islands (using a provided BED file).
Pseudoautosomal region (PAR) on the X chromosome (positions ≤ 6,800,000).
X chromosome.
Autosomes (chromosomes 1–38).


Applies filters to exclude homozygous reference genotypes (e.g., "0/0").
Outputs variant counts for each region.


Input: VCF file, BED file for CpG islands, and other region definitions.
Output: Files containing variant counts for each region (e.g., $pedigree.cpg.num, $pedigree.X.num, etc.).


Usage
Step 1: Set Up Environment

Ensure the following tools are installed:
Perl
GATK (Genome Analysis Toolkit)
VCFtools (VCFtools)
BCFtools (BCFtools)
samtools (samtools)


Set up the directory structure and paths as per the scripts' requirements (e.g., reference genome, known sites, etc.).
The scripts are designed for an HPC environment using PBS for job scheduling.

Step 2: Prepare Input Data

Prepare a sample file with pedigree information. Each line should contain:
Pedigree ID
Proband (offspring) ID
Proband depth
Sex
Dam (mother) ID
Dam depth
Sire (father) ID
Sire depth


Example format:pedigree1 proband1 20 F dam1 20 sire1 20
pedigree2 proband2 25 M dam2 25 sire2 25


Ensure GVCF files for each individual in the trio are available in the specified directory (e.g., /xtdisk/wanggd_kiz/zhangsj/pedigree/data/gvcf/).
Ensure BAM files for the trio are available for bam_fiter.pl (e.g., /xtdisk/wanggd_kiz/zhangsj/pedigree/data/bam/).

Step 3: Run the Main Script

Run pedigree.pl with the sample file as input:perl pedigree.pl sample_file.txt


This will generate bash scripts for each pedigree in the specified directory (e.g., /xtdisk/wanggd_kiz/zhangsj/pedigree/work/script/).

Step 4: Execute Bash Scripts

Submit the generated bash scripts to your HPC cluster using the PBS system:qsub /xtdisk/wanggd_kiz/zhangsj/pedigree/work/script/pedigree1.sh


Alternatively, run them locally if resources permit.

Step 5: Filter and Analyze Results

Use filtere.pl to further filter VCF files for high-confidence DNMs:perl filtere.pl input.vcf depth_dam depth_sire depth_proband

Example: perl filtere.pl pedigree1.vcf 20 20 20
Use bam_fiter.pl to validate DNMs by examining BAM files:perl bam_fiter.pl sample_file.txt


Use callable_sites.pl to calculate variant counts for mutation rate analysis:perl callable_sites.pl sample_file.txt





