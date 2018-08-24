#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
ENDCOLOR="\033[0m"

echo -e "======================================================================"
echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
echo -e "======================================================================"
echo -e $YELLOW"Start:"$ENDCOLOR "$(date)" $YELLOW"Destination:"$ENDCOLOR "WRITE_BACKUP_DESTINATION_NAME"
SECONDS=0
echo -e "----------------------------------------------------------------------"

#Set repo password
export RESTIC_PASSWORD='CHANGEME'

#Set repo path
export RESTIC_REPOSITORY='/PATH/TO/REPO'

#Bail if restic is already running
if pidof -x restic >/dev/null; then
    echo "Restic is already running"
    exit
fi

echo -e $YELLOW"[Unlock Repo]"$ENDCOLOR
restic unlock

#Backup Home directory excluding any unwanted directories
#Script will not Backup Downloads
#Script backs all Home directory
echo -e $YELLOW"[Taking a Snapshot]"$ENDCOLOR
restic backup ~/ --tag YOURTAG --verbose    \
--exclude='~/Downloads'                     \
--exclude='~/.local/share/Trash'            \
--exclude='~/.dbus'                         \
--exclude='~/.cache'                        \

#Check if data is correctly in repo
echo -e $YELLOW"[Checking for Errors in Repo]"$ENDCOLOR
restic check
#Print snapshots
echo -e $YELLOW"[Snapshots List]"$ENDCOLOR
restic snapshots

#Remove old repos based on backup strategy
echo -e $YELLOW"[Forget Old Snapshots]"$ENDCOLOR
restic forget 		\
--keep-hourly 8		\
--keep-daily 7 		\
--keep-weekly 4		\
--keep-monthly 12   	\
--keep-yearly 10	\

#Prune removed snapshots
echo -e $YELLOW"[Prune Old Snapshots]"$ENDCOLOR
restic prune
#Stats
echo -e "----------------------------------------------------------------------"
echo -e $YELLOW"[Latest Snapshots Size]"$ENDCOLOR
restic stats latest
echo -e $YELLOW"[Deduplicated Size for Latest Snapshot]"$ENDCOLOR
restic stats --mode raw-data latest
echo -e $YELLOW"[Original Files Size]"$ENDCOLOR
restic stats
echo -e $YELLOW"[Deduplicated Size for All Snapshots]"$ENDCOLOR
restic stats --mode raw-data
#Time and Runtime
echo -e "----------------------------------------------------------------------"
echo -e $YELLOW"End:"$ENDCOLOR "$(date)" "         " $YELLOW"Duration:"$ENDCOLOR "$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo -e "======================================================================"
echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
echo -e "======================================================================"

#reset credentials
export RESTIC_PASSWORD='CHANGEME'

exit 0