#!/bin/bash
# =============================================================================== #
#                   I N F O R M A T I O N    N E E D E D                          #
# =============================================================================== #
# This part is where you need to change the values; you need to set your restic
# password (password for the repository), the directory for your repository, 
# the backup directory (by default the backup directory is your Home directory), 
# the destination name of your backup (local, S3, B2, Wasabi, remote host, etc.), 
# your tag (empty by default if used) and your "keep" and "excludes" policies.
# ------------------------------------------------------------------------------- #
#                              R E P O    I N F O                                 #
# ------------------------------------------------------------------------------- #

RESTIC_PASSWORD="CHANGE_ME"
RESTIC_REPO="/PATH/TO/YOUR/REPO"
BACKUP_DIR="$HOME"
DESTINATION="Local Backup"
TAG=""
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"
CLEAN="7"
UNLOCK="no"

# ------------------------------------------------------------------------------- #
#                                 E X C L U D E S                                 #
# ------------------------------------------------------------------------------- #
# Your Downloads directory, Trash and Caches are excluded by default;
# If you want to add more directories or files to be excluded of your
# Snapshots you can add them writing the pattern or full directory 
# between the "" that you want to exclude. If you don't want
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

# AFTER THIS LINE YOU DON'T REALLY NEED TO DO ANYTHING ELSE, YOU'RE DONE NOW
# PUT THE SCRIPT TO WORK (remember to give the right to execute with 
# 'chmod 700 restic.sh') AND GO BACK TO YOUR LIFE
# =============================================================================== #
#                  H E R E   B E G I N S   T H E   S C R I P T
# =============================================================================== #
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
ENDCOLOR="\033[0m"
LOCK="$HOME/.local/tmp/$(basename $0).lock"
DATEFILE="$HOME/.local/tmp/datefile-$(basename $0)"
SECONDS=0

# Export Password and Repo
export RESTIC_PASSWORD=$RESTIC_PASSWORD
export RESTIC_REPOSITORY=$RESTIC_REPO

# Create a /tmp directory
if [ -d $HOME/.local/tmp ]; then
  >/dev/null
else
  mkdir $HOME/.local/tmp
fi

# If there is no date file create one
if [ -e "$DATEFILE" ]; then
  >/dev/null
else
  touch $DATEFILE
  date -R > "$DATEFILE"
fi

# Bail if script is already running
if [ -e "$LOCK" ]; then
  echo -e $YELLOW"Date:"$ENDCOLOR "$(date)" $YELLOW"Message:"$ENDCOLOR "$(basename $0) is already running..."
  exit 
fi
touch $LOCK
trap "rm -rf $LOCK" EXIT INT KILL TERM QUIT

# ------------------------------------------------------------------------------- #
Version="restic.sh-v1.2"
Usage='Author		: Sulfuror, Copyright (c) 2018
License		: BSD 2-clause "Simplified" License
Version		: restic.sh-v1.2
Description	: restic.sh is a shell script created to manage
		  backups made with restic program.

"restic is a backup program which allows saving multiple revisions 
of files and directories in an encrypted repository 
stored on different backends."

For more information about restic visit https://restic.net

Note that these commands only work when you have already set
the required values correctly.

Usage:
	./restic.sh [command]

Available Commands:
	check		Check the repository for errors
	init		Initialize a new repository
	prune		Remove unneeded data from the repository
	snapshots	List all snapshots
	unlock		Remove locks other processes created

Options:
	-b, -backup	Make a backup	
	-c, -cleanup	Forget and prune
	-h, -help	Help for this script
	-m, -mount	Mount your restic repo
	-r, -restore	Restore latest snapshot
	-v, -version	Version of this script
'
# ------------------------------------------------------------------------------- #
# Options
while getopts ":-bchmrv" optname
  do
    case "$optname" in
      b|backup)
	echo -e "======================================================================"
	echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
	echo -e "======================================================================"
	echo -e $YELLOW"Start:"$ENDCOLOR "$(date)"
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"Backing up to $DESTINATION..."$ENDCOLOR
        restic backup $BACKUP_DIR --tag "$TAG" --verbose --exclude-caches --exclude='/home/*/.cache/*' --exclude='/home/*/.local/share/Trash/*' --exclude=$EXCLUDE01 --exclude=$EXCLUDE02 --exclude=$EXCLUDE03 --exclude=$EXCLUDE04 --exclude=$EXCLUDE05 --exclude=$EXCLUDE06 --exclude=$EXCLUDE07 --exclude=$EXCLUDE08 --exclude=$EXCLUDE09 --exclude=$EXCLUDE10 --exclude=$EXCLUDE11 --exclude=$EXCLUDE12 --exclude=$EXCLUDE13 --exclude=$EXCLUDE14 --exclude=$EXCLUDE15
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"End:"$ENDCOLOR "$(date)" "         " $YELLOW"Duration:"$ENDCOLOR "$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"	
	echo -e "======================================================================"
	echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
	echo -e "======================================================================"
	exit 0;
        ;;
      c|cleanup)
	echo -e "======================================================================"
	echo -e "|- - - - - - - > [ S T A R T I N G    C L E A N U P ] < - - - - - - -|"
	echo -e "======================================================================"
	echo -e $YELLOW"Start:"$ENDCOLOR "$(date)"
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"Cleaning up $DESTINATION..."$ENDCOLOR
        restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY --prune
	NOW=$(date +"%s")
	NEXT=$(date -f "$DATEFILE" "+%s")
	RESULT=$(($NEXT-$NOW))
	echo -e $YELLOW"Next check and cleanup in "$(($RESULT / 86400 ))" days "$((($RESULT / 3600) % 24))" hours and "$((($RESULT / 60) % 60))" minutes..."$ENDCOLOR
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"End:"$ENDCOLOR "$(date)" "         " $YELLOW"Duration:"$ENDCOLOR "$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"		
	echo -e "======================================================================"
	echo -e "| - - - - - - - - > [ C L E A N U P    E N D E D ] < - - - - - - - - |"
	echo -e "======================================================================"
        exit 0;
        ;;
      h|help)
        echo "$Usage"
        exit 0;
        ;;
      m|mount)
	mkdir $HOME/restic-mount
	restic -r $RESTIC_REPO mount $HOME/restic-mount
	rm -rf $HOME/restic-mount
	exit 0;
	;;
      r|restore)
	mkdir $HOME/restic-restore
	echo -e "======================================================================"
	echo -e "|- - - - - - - > [ S T A R T I N G    R E S T O R E ] < - - - - - - -|"
	echo -e "======================================================================"
	echo -e $YELLOW"Start:"$ENDCOLOR "$(date)"
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"Restoring backup from $DESTINATION..."$ENDCOLOR
	restic -r $RESTIC_REPO restore latest --target $HOME/restic-restore
	echo -e "----------------------------------------------------------------------"
	echo -e $YELLOW"End:"$ENDCOLOR "$(date)" "         " $YELLOW"Duration:"$ENDCOLOR "$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"		
	echo -e "======================================================================"
	echo -e "| - - - - - - > [ R E S T O R E    C O M P L E T E D ] < - - - - - - |"
	echo -e "======================================================================"
	exit 0;
	;;
      v|version)
        echo "$Version"
        exit 0;
        ;;
      ?)
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      :)
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done
shift $(($OPTIND - 1))

# Commands
check=$1
init=$2
prune=$3
snapshots=$4
unlock=$5

if [[ -n "$check" ]];then
  for check in "$@"
  do restic $1
  done
  exit
fi

if [[ -n "$init" ]];then
  for init in "$@"
  do restic $2
  done
  exit
fi

if [[ -n "$prune" ]];then
  for prune in "$@"
  do restic $3
  done
  exit
fi

if [[ -n "$snapshots" ]];then
  for snapshots in "$@"
  do restic $4
  done
  exit
fi

if [[ -n "$unlock" ]];then
  for unlock in "$@"
  do restic $5
  done
  exit
fi
# ------------------------------------------------------------------------------- #

echo -e "======================================================================"
echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
echo -e "======================================================================"
echo -e $YELLOW"Start:"$ENDCOLOR "$(date)" "        " $YELLOW"Destination:"$ENDCOLOR "$DESTINATION"

echo -e "----------------------------------------------------------------------"

# Unlock if neccesary
if [ $UNLOCK == yes ]; then
  if [ -e $RESTIC_REPO/locks/* ]; then
    echo -e $YELLOW"[Unlocking repo...]"$ENDCOLOR
    restic unlock
  fi
fi

# Backup and exclusions
echo -e $YELLOW"[Taking a Snapshot...]"$ENDCOLOR
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
    echo -e $YELLOW"Excluded:"$ENDCOLOR"$EXCLUDE11"
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

echo -e $YELLOW"[Snapshots List...]"$ENDCOLOR
restic snapshots

# Check and Clean Repo Based on User's Policy
NOW=$(date +"%s")
NEXT=$(date -f "$DATEFILE" "+%s")
RESULT=$(($NEXT-$NOW))

if test -f $DATEFILE ; then
  if test "$NOW" -lt "$NEXT" ; then     
     echo -e $YELLOW"[Repo will be checked and cleaned in "$(($RESULT / 86400 ))" days "$((($RESULT / 3600) % 24))" hours and "$((($RESULT / 60) % 60))" minutes...]"$ENDCOLOR
  else
     echo -e $YELLOW"[Checking for Errors in Repo...]"$ENDCOLOR
     restic check
     echo -e $YELLOW"[Cleaning Repo...]"$ENDCOLOR
     restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY --prune
     date -d now+"$CLEAN"days > "$DATEFILE"
     echo -e $YELLOW"[Done Cleaning; Next Cleaning Will Be Done in $CLEAN days...]"$ENDCOLOR
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