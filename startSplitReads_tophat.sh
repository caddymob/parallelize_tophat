#!/bin/bash

SAMPLE_ID=$1

echo "Began $SAMPLE_ID test at `date`" > splitbam.${SAMPLE_ID}.timeCount.txt

rm ~/SCRIPTS/parallelize_tophat/tophat2/messages/${SAMPLE_ID}.*

#First check if we gave the FQs to split!
if [ -z ${SAMPLE_ID} ]; then 
	echo "you must define SAMPLE_ID!"; 
	exit
fi

mkdir -p jobLogs

FQ1=`echo ${SAMPLE_ID}.R1.QC.fq.gz`
FQ2=`echo ${SAMPLE_ID}.R2.QC.fq.gz`

JOB_PATH=$PWD

echo -ne "\nJOB PATH: ${JOB_PATH}\n"

echo "${SAMPLE_ID} ${JOB_PATH}" > ${HOME}/SCRIPTS/parallelize_tophat/tophat2/messages/${SAMPLE_ID}.started

splitJob=`qsub \
 -v SAMPLE_ID=${SAMPLE_ID},FQ1=${FQ1},FQ2=${FQ2},JOB_PATH=${JOB_PATH} \
 -d ${JOB_PATH} \
 -N ${SAMPLE_ID}.Split \
 ~/SCRIPTS/parallelize_tophat/tophat2/make_split_reads.pbs | sed -e 's/.newmoab.local//g'`

echo -ne "\n\nSplitting ${FQ1} and ${FQ2} started with job ${splitJob} `date`\n"

crontab -l > currentcrontabs
echo "* * * * * bash ${HOME}/SCRIPTS/parallelize_tophat/tophat2/tophat2_slit_cronScript.v2.sh ${SAMPLE_ID} >> ${JOB_PATH}/${SAMPLE_ID}.cron.log"  >> ${SAMPLE_ID}_cron
cat currentcrontabs >> ${SAMPLE_ID}_cron
crontab ${SAMPLE_ID}_cron

echo -ne "Greetings, you added:\n\n`cat ${SAMPLE_ID}_cron` \n\nto a cronjob `date`\n\n" > ${SAMPLE_ID}.cron.log

rm ${SAMPLE_ID}_cron
rm currentcrontabs

echo -ne "\nCron job will pick up from once fastqs are done splitting, just watch the queue explode...\n\n"

echo -ne "\n\n`qstat | grep ${SAMPLE_ID} | tail -1`\n\n"
