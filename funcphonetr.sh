#!/bin/bash

function Log_Open() {
    Pipe=tmplog.pipe
    mkfifo -m 700 $Pipe
    LOGFILE=phonelog.txt
    exec 3>&1
    tee ${LOGFILE} <$Pipe >&3 &
    teepid=$!
    exec 1>$Pipe
    PIPE_OPENED=1
}

function Log_Close() {
    if [ ${PIPE_OPENED} ] ; then
       exec 1<&3
       sleep 0.2
       ps --pid $teepid >/dev/null
       if [ $? -eq 0 ] ; then
            # a wait $teepid whould be better but some
            # commands leave file descriptors open
            sleep 1
            kill  $teepid
       fi
                rm $Pipe
                unset PIPE_OPENED
        fi
}


function checkG729() {
    /sbin/asterisk -rx 'core show translation' | grep -q g729
    codec=$(echo $?)

    if [[ $codec==0 ]]
    then
	echo "#########################"
	printf "Codec G729 INSTALLED\n"
	echo "#########################"
    else
	echo "############################"
	printf "Codec G729 NOT INSTALLED\n"
	echo "##########################"
    fi
}


function ask() {

    #ex : /sbin/asterisk -rx "pjsip show contacts"    
    # comment > command

    if [[ -z $3 ]] ; then
        echo "~~~~~~~~~~~~~~~~~"
        echo "$1"
        echo "~~~~~~~~~~~~~~~~~"
        /sbin/asterisk -rx "$2"
        echo ""
    else
        # terzo parametro
        echo "~~~~~~~~~~~~~~~~~"
        echo "$1"
        echo "~~~~~~~~~~~~~~~~~"
        /sbin/asterisk -rx "$2" |grep Busy
        echo ""
    fi
}

Log_Open

ask "EXTENSION REGISTERED:" "pjsip show contacts"
ask "EXTENSION CONFIGURED:" "pjsip show endpoints"
ask "STATE OF PRESENCE AND AVAILABILITY:" "core show hints" "CercaBusy" 
ask "EXTENSIONS IN DND:" "database show DND"
ask "EXTENSIONS CALL FORWARD CONFIGURATION:" "database show CF"
ask "EXTENSIONS CALL FORWARD BUSY CONFIGURATION:" "database show CFB"
ask "EXTENSIONS CALL FORWARD UNAVAILABLE CONFIGURATION:" "database show CFU"
ask "ACTIVE CALLS AND CHANNELS:" "core show channels verbose"

checkG729

echo ""
echo "Generated on $(date)"
echo ""
Log_Close
echo "Please paste this link into the ticket reply: "
PUSH_LOG=$(curl --silent -H "Max-Days: 5" --upload-file ./$LOGFILE https://transfer.sh/)
echo ""
echo "~> $PUSH_LOG <~"
echo ""
