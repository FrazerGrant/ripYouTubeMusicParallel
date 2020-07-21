#!/bin/bash

startTime=$(date +%s)
sleep 70
endTime=$(date +%s)
totalSeconds=$(($endTime-$startTime))
Minutes=$(( totalSeconds / 60 ))
Seconds=$(( totalSeconds % 60 ))
echo "$Minutes: Minutes $Seconds: Seconds"