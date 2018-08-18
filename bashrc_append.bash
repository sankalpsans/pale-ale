#!/bin/bash

BUCKET=yourbucketname
LOGPATH=path/to/logfile/on/s3
YEAR=$(date -d "$y" '+%Y')
MONTH=$(date -d "$m" '+%m')
DAY=$(date -d "$d" '+%d')
LOCAL_ELB_LOGS_FILE_PATH=. # Wherever this gets included 

function getlogs() {

    # Take UTC time input for analysis. Expecting start and end of range.
    start_time=$1" "$2
    end_time=$3" "$4
    echo $start_time;
    echo $end_time;
    # Process time in different formats for processing.
    start_ts_to_zulu=$(date -d "$start_time" '+%Y%m%dT%H%MZ')
    START_YEAR=$(date -d "$start_time" '+%Y')
    START_MONTH=$(date -d "$start_time" '+%m')
    START_DATE=$(date -d "$start_time" '+%d')

    end_ts_to_epoch=$(date +%s -d "$end_time") #Converting to EPOCH
    start_ts_to_epoch=$(date +%s -d "$start_time") #Converting to EPOCH
    MPHR=60    # Minutes per hour.
    STEP=5     # Step value based on aws logs generation timestamp.

    # Take out difference between START_TS and END_TS in minutes. Change $MPHR to get diff in different unit i.e. seconds, hours.
    DIFF_IN_TIMESTAMPS=$(( ($end_ts_to_epoch - $start_ts_to_epoch) / $MPHR ))


    cd $LOCAL_ELB_LOGS_FILE_PATH;

    #Now we calculate no of files to process based on assumption - Log files are generated after every 5minutes. //To do - add it as config variable.
    LOOP_COUNT=$(( $DIFF_IN_TIMESTAMPS / $STEP ))
    echo "LOOP COUNT: "$LOOP_COUNT;

    s=0
    SEARCH_TIME=$start_time
    SEARCH_TIME_LOG_FORMAT=$start_ts_to_zulu

    echo SEACHING FOR $SEARCH_TIME_LOG_FORMAT

    #Loop for copying & unzipping files for required timestamp range.
    echo "####" $LOGPATH
    while [ $s -le $LOOP_COUNT ]
    do
        aws s3 ls s3://$BUCKET/$LOGPATH/$START_YEAR/$START_MONTH/$START_DATE/ | grep "$SEARCH_TIME_LOG_FORMAT" | awk '{print $4}' \
        | while read line;
        do
            echo "Copying : $line"; aws s3 cp s3://$BUCKET/$LOGPATH/$START_YEAR/$START_MONTH/$START_DATE/$line $LOCAL_ELB_LOGS_FILE_PATH;
            echo "Unzipping: "; gunzip $line;
        done;
        #Increase timestamp to find next log file
        SEARCH_TIME=$(date --date "$SEARCH_TIME 5 minutes" '+%Y-%m-%d %H:%M')
        SEARCH_TIME_LOG_FORMAT=$(date -d "$SEARCH_TIME" '+%Y%m%dT%H%MZ')
        s=$((s+1))
    done
    echo "DONE Copying REQD FILES";
    
}

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
