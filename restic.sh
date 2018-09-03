#!/usr/bin/env bash

YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
ENDCOLOR="\033[0m"
LOCK="./.restic_sh.lock"
DATEFILE="./.datefile_restic"

# This part is where you need to change the values; you need to set your restic password
# (password for the repository), the directory for your repository, the backup directory
# (by default the backup directory is your Home directory), the destination name of your
# backup (local, S3, B2, Wasabi, remote host, etc.), your tag (commented by; default if used 
# just uncomment deleting the "#" before "TAG") your "keep" and "excludes" policies.

RESTIC_PASSWORD="CHANGE_ME" #Put your restic password between the ''#
RESTIC_REPO="/path/to/your/repo" #Put your repository directory#
BACKUP_DIR="$HOME" #This is what you're backing up#
DESTINATION="Local" #Put the name of your backup destination (S3, Google Drive, External Drive, etc.)#
#TAG="YOURTAG" #Change YOURTAG to your tag#
KEEP_HOURLY="8" #Put the number of hourly backups you want to keep#
KEEP_DAILY="7" #Put the number of daily backups you want to keep#
KEEP_WEEKLY="4" #Put the number of weekly backups you want to keep#
KEEP_MONTHLY="12" #Put the number of montly backups you want to keep#
KEEP_YEARLY="10" #Put the number of yearly backups you want to keep#
CLEAN="7" #Put the number your cleanup policy (this will run forget, check and prune according to your choice)#

# Excludes:
# Your Downloads directory, Trash and Caches are excluded by default;
# you can edit them if you want. If you want to add more directories or files
# to be excluded of your Snapshots you can add them writing the pattern or
# full directory between the '' that you want to exclude. If you don't want
# to exclude more than it is by default, ignore this part.

EXCLUDE01="" 
EXCLUDE02=""
EXCLUDE03=""
EXCLUDE04=""
EXCLUDE05=""
EXCLUDE06=""
EXCLUDE07=""
EXCLUDE08=""
EXCLUDE09=""
EXCLUDE10=""
EXCLUDE11=""
EXCLUDE12=""
EXCLUDE13=""
EXCLUDE14=""
EXCLUDE15=""

# AFTER THIS LINE YOU DON'T REALLY NEED TO DO ANYTHING ELSE, YOU'RE DON NOW
# PUT THE SCRIPT TO WORK (remember to give the right to execute with 'chmod +x restic.sh')
# AND GO BACK TO YOUR LIFE
# =============================================================================== #
#                  H E R E   B E G I N S   T H E   S C R I P T
# =============================================================================== #
SECONDS=0
# Export Password and Repo
export RESTIC_PASSWORD=$RESTIC_PASSWORD
export RESTIC_REPOSITORY=$RESTIC_REPO

# If there is no date file create one
if [ -e "$DATEFILE" ]; then
  >/dev/null
else
  touch ./.datefile_restic
  date -R > "$DATEFILE"
fi

# Bail if script is already running
if [ -e "$LOCK" ]; then
  echo -e $YELLOW"Date:"$ENDCOLOR "$(date)" $YELLOW"Message:"$ENDCOLOR "Backup is already running..."
  exit 
fi
touch ./.restic_sh.lock
trap "rm -rf $LOCK" EXIT INT KILL TERM QUIT

echo -e "======================================================================"
echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
echo -e "======================================================================"
echo -e $YELLOW"Start:"$ENDCOLOR "$(date)" $YELLOW"Destination:"$ENDCOLOR "$DESTINATION"

echo -e "----------------------------------------------------------------------"

# Unlock if neccesary
if [ -e $RESTIC_REPO/locks/* ]; then
  echo -e $YELLOW"[Unlocking repo...]"$ENDCOLOR
  restic unlock
fi

# Backup and exclusions
echo -e $YELLOW"[Taking a Snapshot]"$ENDCOLOR
restic backup $BACKUP_DIR --tag "$TAG"		\
--verbose					\
--exclude-caches				\
--exclude='/home/*/.cache/*'			\
--exclude='/home/*/.local/share/Trash/*'	\
--exclude=$EXCLUDE01				\
--exclude=$EXCLUDE02				\
--exclude=$EXCLUDE03				\
--exclude=$EXCLUDE04				\
--exclude=$EXCLUDE05				\
--exclude=$EXCLUDE06				\
--exclude=$EXCLUDE07				\
--exclude=$EXCLUDE08				\
--exclude=$EXCLUDE09				\
--exclude=$EXCLUDE10				\
--exclude=$EXCLUDE11				\
--exclude=$EXCLUDE12				\
--exclude=$EXCLUDE13				\
--exclude=$EXCLUDE14				\
--exclude=$EXCLUDE15				\

if [ -z "$EXCLUDE01" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE01"
fi

if [ -z "$EXCLUDE02" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE02"
fi

if [ -z "$EXCLUDE03" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE03"
fi

if [ -z "$EXCLUDE04" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE04"
fi

if [ -z "$EXCLUDE05" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE05"
fi

if [ -z "$EXCLUDE06" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE06"
fi

if [ -z "$EXCLUDE07" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE07"
fi

if [ -z "$EXCLUDE08" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE08"
fi

if [ -z "$EXCLUDE09" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE09"
fi

if [ -z "$EXCLUDE10" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE10"
fi

if [ -z "$EXCLUDE11" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluding:"$ENDCOLOR"$EXCLUDE11"
fi

if [ -z "$EXCLUDE12" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE12"
fi

if [ -z "$EXCLUDE13" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE13"
fi

if [ -z "$EXCLUDE14" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE14"
fi

if [ -z "$EXCLUDE15" ]; then
    >/dev/null
  else
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE15"
fi

echo -e $YELLOW"[Snapshots List]"$ENDCOLOR
restic snapshots

# Check and Clean Repo Based on Your Choice of Days (line 26)
NOW=$(date +"%s")
NEXT=$(date -f "$DATEFILE" "+%s")
RESULT=$(($NEXT-$NOW))

if test -f $DATEFILE ; then
  if test "$NOW" -lt "$NEXT" ; then     
     echo -e $YELLOW"[Repo will be checked and clenaed in "$(($RESULT / 86400 ))" days "$((($RESULT / 3600) % 24))" hours and "$((($RESULT / 60) % 60))" minutes]"$ENDCOLOR
  else
     echo -e $YELLOW"[Checking for Errors in Repo...]"$ENDCOLOR
     restic check
     echo -e $YELLOW"[Cleaning Repo...]"$ENDCOLOR
     restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY --prune
     date -d now+"$CLEAN"days > "$DATEFILE"
     echo -e $YELLOW"[Done Cleaning; Next Cleaning Will Be Done in $CLEAN days..]"$ENDCOLOR
  fi
fi

# Stats
echo -e "----------------------------------------------------------------------"
echo -e $YELLOW"[Latest Snapshots Size]"$ENDCOLOR
restic stats latest
echo -e $YELLOW"[Deduplicated Size for Latest Snapshot]"$ENDCOLOR
restic stats --mode raw-data latest
echo -e $YELLOW"[Original Files Size]"$ENDCOLOR
restic stats
echo -e $YELLOW"[Deduplicated Size for All Snapshots]"$ENDCOLOR
restic stats --mode raw-data
# Time and Runtime
echo -e "----------------------------------------------------------------------"
echo -e $YELLOW"End:"$ENDCOLOR "$(date)" "         " $YELLOW"Duration:"$ENDCOLOR "$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo -e "======================================================================"
echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
echo -e "======================================================================"

#reset credentials
export RESTIC_PASSWORD=$RESTIC_PASSWORD

exit 0