#!/bin/bash

BUCKET=yourbucketname
LOGPATH=path/to/logfile/on/s3
YEAR=$(date -d "$y" '+%Y')
MONTH=$(date -d "$m" '+%m')
DAY=$(date -d "$d" '+%d')

# Lists log files present for today's date at the relevant location in S3
function showlogs() {
 echo Listing Logs from $BUCKET/$LOGPATH/$YEAR/$MONTH/$DAY/;
 aws s3 ls s3://$BUCKET/$LOGPATH/$YEAR/$MONTH/$DAY/ | sort -n
}

# accepts filename present in remote directory
function getlog() {
 aws s3 cp s3://$BUCKET/$LOGPATH/$YEAR/$MONTH/$DAY/$1 `pwd`
}

# accepts filename
function find4xx() {
 cat $1 | awk {'print $1" "$6" "$7" "$8" "$12" "$13" "$15" "$16" "$17" "$18" "$19'} | grep " 4[0-9][0-9] "
}

# accepts filename
function find5xx() {
 cat $1 | awk {'print $1" "$6" "$7" "$8" "$12" "$13" "$15" "$16" "$17" "$18" "$19'} | grep " 5[0-9][0-9] "
}

# accepts filename
function findslow() {
 cat $1 | awk {'print $6" "$1" "$12" "$13" "$15" "$16" "$17" "$18" "$19" "$20" "$21'} |sort -n | tail -20
}


# Shows slow log for the most recent 20 log files. TODO: update this function to accept a generic number of files
function analyze_slow_logs() {
 NUMBER_OF_FILES_TO_ANALYZE=20
 echo Analyzing $NUMBER_OF_FILES_TO_ANALYZE file\(s\)
 showlogs | tail -$NUMBER_OF_FILES_TO_ANALYZE | awk {'print $4'} > .pale_ale_analysis
 cat .pale_ale_analysis
 COUNTER=1
 while [ $COUNTER -lt $NUMBER_OF_FILES_TO_ANALYZE ]; do
  echo $COUNTER;
  LOGFILE_NAME=`tail -$COUNTER .pale_ale_analysis | head -1`
  echo $LOGFILE_NAME
  echo Getting logfile $LOGFILE_NAME...
  getlog $LOGFILE_NAME
  findslow $LOGFILE_NAME >> .pale_ale_slow
  let COUNTER=COUNTER+1
 done
cat .pale_ale_slow | sort -n
}
