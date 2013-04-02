#!/bin/bash

echo $HOSTNAME | grep pnap
if [ "$?" -eq 0 ]; then
  TMP_DIR=/scratch/tmp
  REF_DIR=/scratch/jcorneveaux/resources
else
  TMP_DIR=/huentelman/tmp
  REF_DIR=~/resources
fi

export PATH=$PATH:${HOME}/bin

export BWA=~/bin/bwa
export CUFFCOMPARE=~/bin/CUFFLINKS/2.0.2/cuffcompare
export CUFFLINKS=~/bin/CUFFLINKS/2.0.2/cufflinks
export CUFFDIFF=~/bin/CUFFLINKS/2.0.2/cuffdiff
export DATE=`echo -n $(date '+aln_%m-%d-%y')`
export GATK=~/bin/GenomeAnalysisTK-latest/GATK2/GenomeAnalysisTK.jar
export GTF=${REF_DIR}/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.66.gtf
export HUMAN_REF_FA=${REF_DIR}/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.62
export REF=${HUMAN_REF_FA}.fa
export HUMAN_TRANS_FA=${REF_DIR}/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.transcriptome/Homo_sapiens.GRCh37.66
export MASK=${REF_DIR}/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.66.MASK.gtf
export PICARD=~/bin/picard-tools-current/
export BWA_REF=${REF_DIR}/GRCh37/Homo_sapiens.GRCh37.62.fa
export SAMTOOLS=~/bin/samtools
export TOPHAT=~/bin/tophat-2.0.4.Linux_x86_64/tophat
export VCF=${REF_DIR}/GRCh37/dbSNP137.vcf
export THREADS=`grep -c ^processor /proc/cpuinfo`
export ALN_THREADS=`echo $THREADS / 2 | bc`
