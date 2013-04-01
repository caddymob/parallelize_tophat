#!/bin/bash

SAMPLE_ID=$1
JOB_PATH=$2
SUFFIX=$3

CRON_LOG=${JOB_PATH}/${SAMPLE_ID}.cron.log #should use this

source ~/SCRIPTS/parallelize_tophat/tophat2/export_paths-IDs_tophat-cufflinks.sh

echo -ne "Begin $0 \n" >> ${JOB_PATH}/${SAMPLE_ID}.cron.log
echo "BWA = $BWA"
echo "BWA = $BWA"
echo "SAMPLE_ID = ${SAMPLE_ID}"
echo "SAMPLE_ID = ${SAMPLE_ID}"
echo "SUFFIX = ${SUFFIX}"
echo "SUFFIX = ${SUFFIX}"

## SAMPLE_ID is just the suffix now! eg 001

START=$(date +%s)
read1=R1${SUFFIX}
read2=R2${SUFFIX}
echo -ne "\n\nread1 = ${read1}\n"
echo -ne "\nread2 = ${read2}\n"

echo -ne "\n\nTophat begin ${SAMPLE_ID}_${SUFFIX} on `hostname` at `date`\n"
echo -ne "\n\nTophat begin ${SAMPLE_ID}_${SUFFIX} on `hostname` at `date`\n" >> ${JOB_PATH}/${SAMPLE_ID}.cron.log

echo "calculating combined read length for ${read1} and ${read2}"
read1Length=$(cat $read1 | head -2 | tail -1 | wc -c)
read2Length=$(cat $read2 | head -2 | tail -1 | wc -c)
combinedLength=`echo "$read1Length + $read2Length - 2" | bc`

echo "${read1} is ${read1Length} and ${read2} is ${read2Length} for combined length of ${combinedLength}"

####### BWA ALIGN READ 1 & 2 #####

${BWA} aln -t ${ALN_THREADS} ${BWA_REF} ${read1} > ${read1}.sai &
${BWA} aln -t ${ALN_THREADS} ${BWA_REF} ${read2} > ${read2}.sai &

wait

echo -ne "\nbwa aln done, now pairing, runtime: "
bash ~/SCRIPTS/TimeOut.sh $START

####### BWA SAMPE, SORT "${SAMPLE_ID}_${SUFFIX}" #####
${BWA} sampe \
-r "@RG\tID:${SUFFIX}_${DATE}\tSM:${SAMPLE_ID}\tPL:ILLUMINA\tLB:${SAMPLE_ID}_${SUFFIX}_Lib1" \
-t ${THREADS} \
-P \
${BWA_REF} \
${read1}.sai  ${read2}.sai ${read1} ${read2} | \
${SAMTOOLS} view -S -h -b -t ${BWA_REF}.fai - | \
${SAMTOOLS} sort - ${SAMPLE_ID}_${SUFFIX}.rnaInsert.sorted

echo -ne "\n\ngetting insert size metrics with picard, runtime: "
bash ~/SCRIPTS/TimeOut.sh $START

java -Xmx4g -jar ${PICARD}CollectInsertSizeMetrics.jar \
INPUT=${SAMPLE_ID}_${SUFFIX}.rnaInsert.sorted.bam \
OUTPUT=${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.txt \
HISTOGRAM_FILE=${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.pdf \
VALIDATION_STRINGENCY=SILENT \
TMP_DIR=${TMP_DIR} \
LEVEL=ALL_READS 2>&1 

echo -ne "\n\ngetting insert size metrics with picard is done, runtime: "
bash ~/SCRIPTS/TimeOut.sh $START

echo -ne "reading insert size from ${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.txt picard output\n\n"
INNERDIST=`head -n 8 "${SAMPLE_ID}_${SUFFIX}".picInsertMetrics.txt | tail -n 1 | cut -f5 | awk -v var1="$combinedLength" '{printf "%.0f\n", $1-var1}'`
STDEV=`head -n 8 "${SAMPLE_ID}_${SUFFIX}".picInsertMetrics.txt | tail -n 1 | cut -f6 | awk '{printf "%.0f\n", $1}'`

echo -ne "\nCOMBINED READ LENGTH=$combinedLength INNERDIST=${INNERDIST} STDEV=${STDEV} for ${SAMPLE_ID}_${SUFFIX} (from $read1Length and $read2Length - 2) \n"  >> ${JOB_PATH}/${SAMPLE_ID}.cron.log
echo -ne "\nCOMBINED READ LENGTH=$combinedLength INNERDIST=${INNERDIST} STDEV=${STDEV} for ${SAMPLE_ID}_${SUFFIX} (from $read1Length and $read2Length - 2) \n"

mv ${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.pdf ${JOB_PATH}/jobLogs/${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.pdf

rm ${SAMPLE_ID}_${SUFFIX}.rnaInsert.sorted.bam 
rm ${SAMPLE_ID}_${SUFFIX}.picInsertMetrics.txt 
rm ${read1}.sai 
rm ${read2}.sai 

echo -ne "cleaning up ${read1}.sai and ${read2}.sai finished with exit($?)\n"
echo -ne "cleaning up ${read1}.sai and ${read2}.sai finished with exit($?)\n" >> ${JOB_PATH}/${SAMPLE_ID}.cron.log

echo -ne "Starting Tophat on ${SAMPLE_ID}_${SUFFIX} `date` \n\n" >> ${JOB_PATH}/${SAMPLE_ID}.cron.log
echo -ne "Starting Tophat on ${SAMPLE_ID}_${SUFFIX} `date` $0, runtime: "
bash ~/SCRIPTS/TimeOut.sh $START

time ${TOPHAT} \
--mate-inner-dist ${INNERDIST} \
--mate-std-dev ${STDEV} \
--output-dir ${JOB_PATH}/${SAMPLE_ID}_${SUFFIX} \
--num-threads ${THREADS} \
--transcriptome-index ${HUMAN_TRANS_FA} \
--rg-id ${SAMPLE_ID}_${SUFFIX} \
--rg-sample ${SAMPLE_ID} \
--rg-library ${SAMPLE_ID}_Lib1 \
--library-type fr-unstranded \
--rg-platform ILLUMINA \
--fusion-search \
--fusion-ignore-chromosomes MT \
--b2-sensitive \
--keep-fasta-order \
${HUMAN_REF_FA} \
${read1} ${read2} 

echo "${SAMTOOLS} sort and flagstat ${SAMPLE_ID} on `hostname`, runtime: "
bash ~/SCRIPTS/TimeOut.sh $START
echo "${SAMTOOLS} sort and flagstat ${SAMPLE_ID} on `hostname` " >> ${JOB_PATH}/${SAMPLE_ID}.cron.log

cd ${JOB_PATH}/${SAMPLE_ID}_${SUFFIX}
${SAMTOOLS} index accepted_hits.bam 
${SAMTOOLS} flagstat accepted_hits.bam > accepted_hits.flagstat 

echo -ne "samtools flagstat for ${SAMPLE_ID}_${SUFFIX}\n\n `cat accepted_hits.flagstat` \n"
echo -ne "samtools flagstat for ${SAMPLE_ID}_${SUFFIX}\n\n `cat accepted_hits.flagstat` \n" >> ${JOB_PATH}/${SAMPLE_ID}.cron.log

echo -ne "\nTophat is done with ${SAMPLE_ID}_${SUFFIX}\nexit status($?)\nTotal runtime was: "
bash ~/SCRIPTS/TimeOut.sh $START

