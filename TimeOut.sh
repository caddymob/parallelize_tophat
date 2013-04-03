#!/bin/bash

START=$1
END=$(date +%s)

S=$(( $END - $START ))
((h=S/3600))
((m=S%3600/60))
((s=S%60))
#TOTALTIME=`printf "%dh:%dm:%ds\n" $h $m $s`
TOTALTIME=`printf "%dh:%dm:%ds" $h $m $s`

echo $TOTALTIME
