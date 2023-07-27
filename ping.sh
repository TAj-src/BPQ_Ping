#!/bin/bash
##################################################################
#
# File         : ping.sh
# Descriptipon : PING message server script for LinBPQ
# Author       : G7TAJ@GB7BEX.#38.GBR.EU (Steve)
#
# Install in a directory off the BASE_DIR (e.g. /home/pi/linbpq/scripts/)
# Change variables to match your system
#
# You need an export FWD in BPQMail to export P-type msgs to the below directory
#
# add in CRONTAB before you call
# e.g.
# #Check for PING msgs
# 0 1 * * * /home/<usr>/linbpq/scrips/ping.sh > /dev/null 2>&1
#
# Replace /dev/null if you want to log the output (e.g. /tmp/ping.log)
#
#
##################################################################
BBS_NAME=GB7BEX
BBS_HR=.#38.GBR.EU
BASE_DIR=/home/pi/linbpq
MAIL_FILE=$BASE_DIR/Mail/Import/mail.in
EXPORT_DIR=$BASE_DIR/Mail/Export/ping
LOG=ping.out

IN_MSG=0
IN_HEADER=0
FOUND_WP=0

#if no log - exit
if [ ! -f "$EXPORT_DIR/$LOG" ]; then
 exit 1;
fi

ALL_MSG='\n'

while read -r line; do
  first2=${line:0:2}
  first3=${line:0:3}

   if [ "$first2" == "R:" ] && [ $IN_MSG -eq 1 ]; then
        IN_HEADER=1
        LAST_R=$line
#       ALL_MSG="$ALL_MSG> $line"
   fi

   if [ "$first2" != "R:" ] && [ $IN_HEADER -eq 1 ]; then  # we're out of the R lines so process the last R:
        IN_HEADER=0

        # normal format => R:190107/1136Z @:GB7CIP.#32.GBR.EURO $:51342G4APL
        searchstr="@:"
        WP=${LAST_R#*$searchstr}
        TMP_WP=($(echo $WP | tr " " "\n"))
        FROMBBS="${TMP_WP[0]}"

        if [ "${FROMBBS:0:2}" == "R:" ]; then #didnt find @: so try for diff version => R:190106/1825Z 15992@LU9DCE.TOR.BA.ARG.SOAM LinBPQ6.0.17
                echo "Didnt find ver1 trying ver2..."
                TMP_WP=($(echo $WP | tr " " "\n"))
                TMP_WP=($(echo ${TMP_WP[1]} | tr "@" "\n"))
                FROMBBS="@${TMP_WP[1]}"
                echo "newBBS= $FROMBBS"
                FOUND_WP=1
        else
         FROMBBS="@$FROMBBS"
         echo "new WP = $FROMBBS"
         FOUND_WP=1
        fi

        if [ $FOUND_WP -eq 0 ]; then
        #no HRoute found
          echo "no WP BBS found"
          FROMBBS=""
        fi

   fi


   if [ "$first3" == "/EX" ] && [ $IN_MSG -eq 1 ]; then  # END of message so process
        IN_MSG=0
        echo "SP $FROM_CALL$FROMBBS < $BBS_NAME@$BBS_NAME$BBS_HR" >> $MAIL_FILE
        echo "PING Reply from $BBS_NAME" >> $MAIL_FILE
        echo -e "\nPing received by $BBS_NAME at $(date)\n" >> $MAIL_FILE
        echo -e $ALL_MSG >> $MAIL_FILE
        echo -e "\n*** PING V0.01 (25-Feb-2020) for xBPQ by G7TAJ ***\n" >> $MAIL_FILE
        echo "/EX" >> $MAIL_FILE

        fromcall=""
        FROMBBS=""
        FOUND_WP=0
   fi

   if [ "$first3" == "SP " ] && [ $IN_MSG -eq 0 ]; then
        parts=($(echo $line | tr " " "\n"))
        echo "From - ${parts[5]}"
        FROM_CALL=${parts[5]}
        IN_MSG=1
        FOUND_WP=0
   fi


   if [[ "$line" == *"ack"* ]] &&  [ $IN_MSG -eq 1 ]; then
     echo "Found ACK!"
     ACK=1
   fi
   if  [ $IN_MSG -eq 1 ]  && [ "$first3" != "SP " ]; then
        ALL_MSG="$ALL_MSG> $line\n"
   fi

done < "$EXPORT_DIR/$LOG"

rm "$EXPORT_DIR/$LOG"
