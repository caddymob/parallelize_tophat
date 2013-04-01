#!/bin/bash

SAMPLE_ID=$1
messages="${HOME}/SCRIPTS/parallelize_tophat/tophat2/messages"

echo -ne "\n~~~~~~~ * ET PHONE HOME $SAMPLE_ID `date` * ~~~~~~~\n"

for toRun in `ls ${messages}`
do
	case $toRun in
	${SAMPLE_ID}.started) 
		JOB_PATH=`cat $messages/${SAMPLE_ID}.started | cut -f2 -d " "`
	;;

	${SAMPLE_ID}.suffs.txt)   echo -ne "\nWill submit split reads on $SAMPLE_ID `date`\n\n" 
		echo -ne "\nSample ID is: $SAMPLE_ID\nJob Path is: $JOB_PATH\n\n"
		SUFFS=`cat $messages/${SAMPLE_ID}.suffs.txt`
		rm $messages/${SAMPLE_ID}.suffs.txt
		rm $messages/$SAMPLE_ID.started
		for suffix in ${SUFFS[@]}
			do
					tmpName=`qsub \
						-v SAMPLE_ID=${SAMPLE_ID},SUFFIX=${suffix},JOB_PATH=${JOB_PATH} \
						-d ${JOB_PATH} \
						-N ${SAMPLE_ID}_${suffix} \
						~/SCRIPTS/parallelize_tophat/tophat2/InferInsert_run_tophat_split-reads.pbs | sed -e 's/.newmoab.local//g'`
					
					if [ $? -ne 0 ]; then
						echo -e "ERROR! ${suffix}_${SAMPLE_ID} did not submit right with exit ($?).... \nnap for a sec...."
						sleep 30
						echo "Trying ${suffix}_${SAMPLE_ID} again..."
						
							tmpName=`qsub \
							-v SAMPLE_ID=${SAMPLE_ID},SUFFIX=${suffix},JOB_PATH=${JOB_PATH} \
							-d ${JOB_PATH} \
							-N ${SAMPLE_ID}_${suffix} \
							~/SCRIPTS/parallelize_tophat/tophat2/InferInsert_run_tophat_split-reads.pbs | sed -e 's/.newmoab.local//g'`
						
						echo -ne "Re-Submitted ${suffix} for ${SAMPLE_ID} with jobID: ${tmpName} - exit = ($?)\n"
						sleep 30

					fi

					echo -ne "Submitted ${suffix} for ${SAMPLE_ID} with jobID: ${tmpName} - exit  = ($?)\n"
					jobId="$jobId:$tmpName"
					sleep 5
		
			done
		
		jobIDs=`echo $jobId | sed -e 's/^://g'`
		
		echo -ne "\n$jobIDs are running InferInsert_run_tophat_split-reads.pbs\n\n" 

		tmpName=`qsub -W depend=afterok:${jobIDs} \
		-v JOB_PATH=${JOB_PATH},SAMPLE_ID=${SAMPLE_ID} \
		 -d ${JOB_PATH} \
		 -N ${SAMPLE_ID}.merge \
		 ~/SCRIPTS/parallelize_tophat/tophat2/merge_bam_end.v2.pbs`
		 
		 echo -ne "\nSubmitted ${SAMPLE_ID} merge with jobID: ${tmpName} exit = ($?)\n"

		 if [ $? -ne 0 ]; then
			echo -ne "ERROR! ${SAMPLE_ID}  merge did not submit right...\n\n"
			sleep 30
			echo "Trying merge again..."
				tmpName=`qsub -W depend=afterok:${jobIDs} \
					-v JOB_PATH=${JOB_PATH},SAMPLE_ID=${SAMPLE_ID} \
					-d ${JOB_PATH} \
		 			-N ${SAMPLE_ID}.merge \
		 			~/SCRIPTS/parallelize_tophat/tophat2/merge_bam_end.v2.pbs`

					echo -ne "\nRe-Submitted ${SAMPLE_ID} merge with jobID: ${tmpName} exit = ($?)\n"
			fi
			
			echo -ne  "\n#### Removing crontab entry for ${SAMPLE_ID} ####\n"
			crontab -l | grep ${SAMPLE_ID}
			crontab -l | grep -v ${SAMPLE_ID} > crontab.new
			crontab crontab.new
			rm crontab.new
	;;

	esac
done

