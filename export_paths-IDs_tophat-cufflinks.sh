#!/bin/bash

export BWA=~/bin/bwa
export CUFFCOMPARE=~/bin/cuffcompare
export CUFFLINKS=~/bin/cufflinks
export CUFFDIFF=~/bin/cuffdiff
export DATE=`echo -n $(date '+aln_%m-%d-%y')`
export GATK=~/bin/GenomeAnalysisTK-latest/GenomeAnalysisTK.jar
export GTF=~/resources/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.66.gtf
export HUMAN_REF_FA=~/resources/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.62
export REF=${HUMAN_REF_FA}.fa
export HUMAN_TRANS_FA=~/resources/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.transcriptome/Homo_sapiens.GRCh37.66
export MASK=~/resources/GRCh37/bowtie2_b37/Homo_sapiens.GRCh37.66.MASK.gtf
export PICARD=~/bin/picard-tools-current/
export BWA_REF=~/resources/GRCh37/Homo_sapiens.GRCh37.62.fa
export SAMTOOLS=~/bin/samtools
export TMP_DIR=/scratch/jcorneveaux/tmp
export TOPHAT=~/bin/tophat
export VCF=~/resources/GRCh37/dbSNP135.vcf
export THREADS=`grep -c ^processor /proc/cpuinfo`
export ALN_THREADS=`echo $THREADS / 2 | bc`
