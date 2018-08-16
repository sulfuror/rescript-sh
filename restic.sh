#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
ENDCOLOR="\033[0m"

#Set repo password
export RESTIC_PASSWORD='CHANGEME'

#Set repo path
export RESTIC_REPOSITORY='/PATH/TO/REPO'
echo -e $YELLOW"[Unlock Repo]"$ENDCOLOR
restic unlock

#Backup Home directory excluding any unwanted directories
#Script will not Backup Downloads
#Script backs all Home directory
echo -e $YELLOW"[Taking a Snapshot]"$ENDCOLOR
restic backup ~/ --tag YOURTAG --verbose	\
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
echo -e $RED"[Forget Old Snapshots]"$ENDCOLOR
restic forget 		\
--keep-hourly 8		\
--keep-daily 7 		\
--keep-weekly 4		\
--keep-monthly 6   	\
--keep-yearly 10	\

#Prune removed snapshots
echo -e $RED"[Prune Old Snapshots]"$ENDCOLOR
restic prune
echo -e $GREEN"[Latest Snapshots Size]"$ENDCOLOR
restic stats latest
echo -e $GREEN"[Deduplicated Size for Latest Snapshot]"$ENDCOLOR
restic stats --mode raw-data latest
echo -e $GREEN"[Original Files Size]"$ENDCOLOR
restic stats
echo -e $GREEN"[Deduplicated Size for All Snapshots]"$ENDCOLOR
restic stats --mode raw-data

#reset credentials
export RESTIC_PASSWORD='CHANGEME'

echo -e $GREEN"[Finished!]"$ENDCOLOR

exit 0
