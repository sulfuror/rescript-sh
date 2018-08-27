#!/usr/bin/env bash
#
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
ENDCOLOR="\033[0m"
LOCK="$HOME/.restic_sh.lock"

# This part is where you need to change the values; you need to set your restic password
# (password for the repository), the directory for your repository, the backup directory
# (by default the backup directory is your Home directory), the destination name of your
# backup (local, S3, B2, Wasabi, remote host, etc.), your tag (commented by; default if used 
# just uncomment deleting the "#" before "TAG") your "keep" and "excludes" policies.

RESTIC_PASSWORD='CHANGE_ME' #Put your restic password between the ''#
RESTIC_REPO='/path/to/your/repo' #Put your repository directory#
BACKUP_DIR='~/' #This is what you're backing up#
DESTINATION='Local' #Put the name of your backup destination (S3, Google Drive, External Drive, etc.)#
#TAG='--tag YOURTAG' #Change YOURTAG to your tag; DON'T DELETE THE "--tag" PART IF YOU WANT TO USE A TAG#
KEEP_HOURLY='8' #Put the number of hourly backups you want to keep#
KEEP_DAILY='7' #Put the number of daily backups you want to keep#
KEEP_WEEKLY='4' #Put the number of weekly backups you want to keep#
KEEP_MONTHLY='12' #Put the number of montly backups you want to keep#
KEEP_YEARLY='10' #Put the number of yearly backups you want to keep#

# You chose if you want to unlock your repo before backing up or not;
# this is optional and the reason why this is in this script is 
# in the README.md file. By default commented; if you want to use it
# just uncomment by deleting the '#' symbol after the "UNLOCK" word.

#UNLOCK='restic unlock'

# Excludes:
# Your Downloads directory, Trash and Caches are excluded by default;
# you can edit them if you want. If you want to add more directories or files
# to be excluded of your Snapshots you can add them writing the pattern or
# full directory between the '' that you want to exclude. If you don't want
# to exclude more than it is by default, ignore this part.

EXCLUDE01='' 
EXCLUDE02=''
EXCLUDE03=''
EXCLUDE04=''
EXCLUDE05=''
EXCLUDE06=''
EXCLUDE07=''
EXCLUDE08=''
EXCLUDE09=''
EXCLUDE10=''

# AFTER THIS LINE YOU DON'T REALLY NEED TO DO ANYTHING ELSE, YOU'RE DON NOW
# PUT THE SCRIPT TO WORK (remember to give the right to execute with 'chmod +x restic.sh')
# AND GO BACK TO YOUR LIFE

# Bail if script is already running
if [ -e "$LOCK" ]; then
  echo -e $YELLOW"Date:"$ENDCOLOR "$(date)" $YELLOW"Message:"$ENDCOLOR "Backup is already running..."
  exit 
fi

touch $HOME/.restic_sh.lock

trap "rm -rf $LOCK" EXIT INT KILL TERM QUIT

echo -e "======================================================================"
echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
echo -e "======================================================================"
echo -e $YELLOW"Start:"$ENDCOLOR "$(date)" $YELLOW"Destination:"$ENDCOLOR "$DESTINATION"
SECONDS=0
echo -e "----------------------------------------------------------------------"

# Repo password
export RESTIC_PASSWORD=$RESTIC_PASSWORD

# Repo path
export RESTIC_REPOSITORY=$RESTIC_REPO

$UNLOCK

# Backup Home directory excluding any unwanted directories
echo -e $YELLOW"[Taking a Snapshot]"$ENDCOLOR
restic backup $BACKUP_DIR $TAG			\
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

# Check if data is correctly in repo
echo -e $YELLOW"[Checking for Errors in Repo]"$ENDCOLOR
restic check

# List snapshots
echo -e $YELLOW"[Snapshots List]"$ENDCOLOR
restic snapshots

# Forget snapshots according to backup policy
echo -e $YELLOW"[Forget Old Snapshots]"$ENDCOLOR
restic forget 		                        \
--keep-hourly $KEEP_HOURLY                      \
--keep-daily $KEEP_DAILY                        \
--keep-weekly $KEEP_WEEKLY                      \
--keep-monthly $KEEP_MONTHLY                    \
--keep-yearly $KEEP_YEARLY                      \

# Prune forgotten snapshots
echo -e $YELLOW"[Prune Old Snapshots]"$ENDCOLOR
restic prune
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
