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
# You MUST set these values. "KEEP" values CANNOT be left blank; if you are not
# going to use "KEEP" policies the value must be set to "0".
RESTIC_PASSWORD="CHANGE_ME"
RESTIC_REPO="/PATH/TO/YOUR/REPO"
BACKUP_DIR="$HOME"
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"

# Optional values; The "DESTINATION" value is just use in this script to display
# in output the name of your destination (e.g.: Google Drive, Amazon, B2, Wasabi, 
# etc.). The "TAG" value will tag your snapshots with any name/tag you want.
# The "CLEAN" value determine when it will execute the forget, prune and check
# commands; this value must be set in days and by default the number 7 means
# it will do these tasks every seven (7) days. These values CAN be left blank
# if you are not planning on use them.
CLEAN="7"
TAG=""
DESTINATION=""

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

# AFTER THIS LINE YOU DO NOT NEED TO DO ANYTHING ELSE, YOU'RE DONE NOW
# PUT THE SCRIPT TO WORK (remember to give the right to execute with 
# 'chmod 700 rescript.sh') AND GO BACK TO YOUR LIFE
# =============================================================================== #
#                  H E R E   B E G I N S   T H E   S C R I P T
# =============================================================================== #
YELLOW="\033[33m"
ENDCOLOR="\033[0m"
LOCK="$HOME/.rescript/lock/$(basename "$0").lock"
DATEFILE="$HOME/.rescript/logs/datefile-$(basename "$0")"
SECONDS=0

# Export Password and Repo
export RESTIC_PASSWORD=$RESTIC_PASSWORD
export RESTIC_REPOSITORY=$RESTIC_REPO

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Create a rescript directories
if [[ ! -d "$HOME/.rescript" ]]; then
  mkdir -p "$HOME/.rescript"
fi
if [[ ! -d "$HOME/.rescript/logs" ]]; then
  mkdir -p "$HOME/.rescript/logs"
fi
if [[ ! -d "$HOME/.rescript/lock" ]]; then
  mkdir -p "$HOME/.rescript/lock"
fi

# If there is no date file create one
if [[ ! -z "$CLEAN" ]] ; then
  if [[ ! -e "$DATEFILE" ]]; then
    touch "$DATEFILE"
    date -R > "$DATEFILE"
  fi
fi
# ------------------------------------------------------------------------------- #
Version="rescript.sh-v1.4"
Usage='Author		: Sulfuror, Copyright (c) 2018 <sulfuror@gmail.com>
License		: BSD 2-clause "Simplified" License
Version		: rescript.sh-v1.4
Description	: rescript.sh is a shell script created to manage
		  backups made with restic program.

"restic is a backup program which allows saving multiple revisions 
of files and directories in an encrypted repository 
stored on different backends."

For more information about restic visit https://restic.net

Note that these commands only work when you have already set
the required values correctly.

Usage:
	./rescript.sh [command]

Available Commands:
	check			Check the repository for errors
	init			Initialize a new repository
	prune			Remove unneeded data from the repository
	snapshots		List all snapshots
	unlock			Remove locks other processes created
	rebuild-index		Build a new index file
	stats			Scan the repository and show basic statistics

Automatic Options:
	-b, -backup		Make a backup	
	-c, -cleanup		Forget and prune
	-d, -deep-check		Check repository with --read-data flag
	-h, -help		Help for this script
	-m, -mount		Mount your restic repo
	-n, -next-cleanup	Display when it will do the next cleanup
	-v, -version		Version of this script
	-s, -stats		Stats [original and deduplicated size]
	-u, -unlock		Remove lock created by script

User options [all user options require an argument]:
	-f			forget: Remove snapshots from the repository
	-g			find: Find a file or directory
	-k			keys: Manage keys [list|add|passwd]
	-l			ls: List files in a snapshot	
	-r			Restore a snapshot

For more information about the usage check out the following link:
https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
'
# ------------------------------------------------------------------------------- #
# Options
while getopts ":bcdf:g:hk:l:mnr:suv" o
  do
      case "$o" in
	b|backup)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		echo -e "======================================================================"
		echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
		echo -e "======================================================================"
		echo -e "$YELLOW""Start:""$ENDCOLOR" "$(date)"
		echo -e "----------------------------------------------------------------------"
		echo -e "$YELLOW""Backing up to $DESTINATION...""$ENDCOLOR"
		restic backup "$BACKUP_DIR" --tag "$TAG" --verbose --exclude-caches --exclude="/home/*/.cache/*" --exclude="/home/*/.local/share/Trash/*" --exclude="$EXCLUDE01" --exclude="$EXCLUDE02" --exclude="$EXCLUDE03" --exclude="$EXCLUDE04" --exclude="$EXCLUDE05" --exclude="$EXCLUDE06" --exclude="$EXCLUDE07" --exclude="$EXCLUDE08" --exclude="$EXCLUDE09" --exclude="$EXCLUDE10" --exclude="$EXCLUDE11" --exclude="$EXCLUDE12" --exclude="$EXCLUDE13" --exclude="$EXCLUDE14" --exclude="$EXCLUDE15"
		echo -e "----------------------------------------------------------------------"
		echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)" "         " "$YELLOW""Duration:""$ENDCOLOR" "$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"	
		echo -e "======================================================================"
		echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
		echo -e "======================================================================"
	        ;;
	c|cleanup)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		if [[ "$KEEP_HOURLY" -gt "0" || "$KEEP_DAILY" -gt "0" || "$KEEP_WEEKLY" -gt "0" || "$KEEP_MONTHLY" -gt "0" || "$KEEP_YEARLY" -gt "0" ]] ; then
			echo -e "======================================================================"
	  		echo -e "|- - - - - - - > [ S T A R T I N G    C L E A N U P ] < - - - - - - -|"
			echo -e "======================================================================"
			echo -e "$YELLOW""Start:""$ENDCOLOR" "$(date)"
			echo -e "----------------------------------------------------------------------"
			echo -e "$YELLOW""Cleaning up $DESTINATION...""$ENDCOLOR"
		        restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY
		        restic prune --cleanup-cache
			NOW=$(date +"%s")
			NEXT=$(date -f "$DATEFILE" "+%s")
			RESULT=$((NEXT-NOW))
			if test "$CLEAN" -gt "0" ; then
			  if test "$RESULT" -lt "0" ; then
			    echo -e "$YELLOW""Repo will be checked and cleaned in the next run...""$ENDCOLOR"
			  else
			    if test "$((RESULT / 86400))" -lt "2" ; then
			      echo -e "$YELLOW""Next check and cleanup in "$((RESULT / 86400 ))" day "$(((RESULT / 3600) % 24))" hours and "$(((RESULT / 60) % 60))" minutes...""$ENDCOLOR"
			    else
			      echo -e "$YELLOW""Next check and cleanup in "$((RESULT / 86400 ))" days "$(((RESULT / 3600) % 24))" hours and "$(((RESULT / 60) % 60))" minutes...""$ENDCOLOR"
			    fi
			  fi
			fi
			echo -e "----------------------------------------------------------------------"
			echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)" "         " "$YELLOW""Duration:""$ENDCOLOR" "$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"
			echo -e "======================================================================"
			echo -e "| - - - - - - - - > [ C L E A N U P    E N D E D ] < - - - - - - - - |"
			echo -e "======================================================================"
		else
			echo -e "$YELLOW""You have not indicated any policy value...""$ENDCOLOR"
			echo "If you want to use -c, -cleanup option you need to set the [KEEP] variables."
			echo "For more information about the Usage check out the following link:"
			echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
		fi
		;;
	d|deep-check)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		restic check --read-data
		;;
	f) 
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		echo "Forgetting snapshot ID $OPTARG"
		restic forget "$OPTARG"
		;;
	g)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		restic find "$OPTARG"
		;;
	h|help)
		echo "$Usage"
      		;;
	k)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		restic key "$OPTARG" 
		;;
	l)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		restic ls "$OPTARG"
		;;
	m|mount)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		rmount="$HOME/$(basename "$0")-$(date +%s)"
		mkdir "$rmount"
		restic mount "$rmount"
		rm -rf "$rmount"
		;;
	n|next-cleanup)
		if [[ -z "$CLEAN" || "$CLEAN" -lt "1" ]] ; then
		  echo -e "$YELLOW""You have not indicated any policy for the CLEAN value...""$ENDCOLOR"
		  echo "The scrip will run check, forget and prune every time it runs"
		  echo "unless you change the CLEAN variable at the beginning of this script."
		  echo "The number indicated in the CLEAN variable must be in days."
		  echo "For more information about the usage check out the following link:"
		  echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
		else
		NOW=$(date +"%s")
		NEXT=$(date -f "$DATEFILE" "+%s")
		RESULT=$((NEXT-NOW))
		DAYS=$((RESULT / 86400))
		HOURS=$(((RESULT / 3600) % 24))
		MINUTES=$(((RESULT / 60) % 60))
		  if [[ "$DAYS" -gt "0" ]] ; then
		    echo -e "$YELLOW""Next check and cleanup in $DAYS days $HOURS hours and $MINUTES minutes...""$ENDCOLOR"
		  elif [[ "$HOURS" -gt "0" ]] ; then
		    echo -e "$YELLOW""Next check and cleanup in $HOURS hours and $MINUTES minutes...""$ENDCOLOR"
		  elif [[ "$MINUTES" -gt "0" ]] ; then
		    echo -e "$YELLOW""Next check and cleanup in $MINUTES minutes...""$ENDCOLOR"
		  else
		    echo -e "$YELLOW""Repo will be checked and cleaned in the next run...""$ENDCOLOR"
		  fi
		fi
		;;
	r)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		if [ -z "$OPTARG" ] ; then
		  echo "You need to indicate which snapshot you want to restore..."
		fi
		restic_restore="$HOME/restic-restore-ID-$OPTARG"
		mkdir "$restic_restore"
		echo -e "======================================================================"
		echo -e "|- - - - - - - > [ S T A R T I N G    R E S T O R E ] < - - - - - - -|"
		echo -e "======================================================================"
		echo -e "$YELLOW""Start:""$ENDCOLOR" "$(date)"
		echo -e "----------------------------------------------------------------------"
		echo -e "$YELLOW""Restoring $OPTARG snapshot from $DESTINATION...""$ENDCOLOR"
		restic restore "$OPTARG" --verify --target "$restic_restore"
		echo -e "----------------------------------------------------------------------"
		echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)" "         " "$YELLOW""Duration:""$ENDCOLOR" "$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"
		echo -e "======================================================================"
		echo -e "| - - - - - - > [ R E S T O R E    C O M P L E T E D ] < - - - - - - |"
		echo -e "======================================================================"
		;;
	v|version)
	        echo "$Version"
        	;;
	s|stats)
		if [ -e "$LOCK" ]; then
		  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
		  echo -e "If you are sure $(basename "$0") is not running, type"
		  echo -e " "
		  echo -e "	$(basename "$0") -u"
		  echo -e "OR"
		  echo -e "	$(basename "$0") -unlock"
		  echo -e " "
		  echo -e "This will remove the lock for $(basename "$0")"
		  exit 
		fi
		touch "$LOCK"
		trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
		echo -e "$YELLOW""Latest Snapshots Size...""$ENDCOLOR"
		restic stats latest
		echo -e "$YELLOW""Deduplicated Size for Latest Snapshot...""$ENDCOLOR"
		restic stats --mode raw-data latest
		echo -e "$YELLOW""Original Files Size...""$ENDCOLOR"
		restic stats
		echo -e "$YELLOW""Deduplicated Size for All Snapshots...""$ENDCOLOR"
		restic stats --mode raw-data
		;;
	u|unlock)
		if [[ ! -e "$LOCK" ]]; then
			echo -e "$YELLOW""No locks found...""$ENDCOLOR"
		   else
			rm -rf "$LOCK"
			echo -e "$YELLOW""Script unlocked...""$ENDCOLOR"
		fi
		;;
	\?)
	        echo "Unknown option $OPTARG"
		echo "$Usage"
	        ;;
	:)
		echo "No argument value was indicated for option $OPTARG"
		echo "$Usage"
	        ;;
	*)
	        echo "Unknown error while processing options"
		echo "$Usage"
	        ;;
      esac
    exit
  done
shift $((OPTIND - 1))

# Commands
command="$1"
if [[ -n "$command" ]];then
  for command in "$@"
  do restic "$1"
  done
  exit
fi

# Bail if script is already running
if [ -e "$LOCK" ]; then
  echo -e "$YELLOW""WARNING:""$ENDCOLOR" "$(basename "$0") is already running..."
  echo -e "If you are sure $(basename "$0") is not running, type"
  echo -e " "
  echo -e "	$(basename "$0") -u"
  echo -e "OR"
  echo -e "	$(basename "$0") -unlock"
  echo -e " "
  echo -e "This will remove the lock for $(basename "$0")"
  exit 
fi

touch "$LOCK"
trap 'rm -rf "$LOCK"' INT QUIT TERM EXIT
# ------------------------------------------------------------------------------- #

echo -e "======================================================================"
echo -e "| - - - - - - - > [ S T A R T I N G    B A C K U P ] < - - - - - - - |"
echo -e "======================================================================"
echo -e "$YELLOW""Start:""$ENDCOLOR" "$(date)" "        " "$YELLOW""Destination:""$ENDCOLOR" "$DESTINATION"

echo -e "----------------------------------------------------------------------"

# Backup and exclusions
echo -e "$YELLOW""[Taking a Snapshot...]""$ENDCOLOR"
restic backup "$BACKUP_DIR" --tag "$TAG"	\
--verbose					\
--exclude-caches				\
--exclude="/home/*/.cache/*"			\
--exclude="/home/*/.local/share/Trash/*"	\
--exclude="$EXCLUDE01"				\
--exclude="$EXCLUDE02"				\
--exclude="$EXCLUDE03"				\
--exclude="$EXCLUDE04"				\
--exclude="$EXCLUDE05"				\
--exclude="$EXCLUDE06"				\
--exclude="$EXCLUDE07"				\
--exclude="$EXCLUDE08"				\
--exclude="$EXCLUDE09"				\
--exclude="$EXCLUDE10"				\
--exclude="$EXCLUDE11"				\
--exclude="$EXCLUDE12"				\
--exclude="$EXCLUDE13"				\
--exclude="$EXCLUDE14"				\
--exclude="$EXCLUDE15"				\

if [ ! -z "$EXCLUDE01" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE01"
fi

if [ ! -z "$EXCLUDE02" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE02"
fi

if [ ! -z "$EXCLUDE03" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE03"
fi

if [ ! -z "$EXCLUDE04" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE04"
fi

if [ ! -z "$EXCLUDE05" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE05"
fi

if [ ! -z "$EXCLUDE06" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE06"
fi

if [ ! -z "$EXCLUDE07" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE07"
fi

if [ ! -z "$EXCLUDE08" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE08"
fi

if [ ! -z "$EXCLUDE09" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE09"
fi

if [ ! -z "$EXCLUDE10" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE10"
fi

if [ ! -z "$EXCLUDE11" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE11"
fi

if [ ! -z "$EXCLUDE12" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE12"
fi

if [ ! -z "$EXCLUDE13" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE13"
fi

if [ ! -z "$EXCLUDE14" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE14"
fi

if [ ! -z "$EXCLUDE15" ]; then
    echo -e "$YELLOW""Excluded:""$ENDCOLOR""$EXCLUDE15"
fi

echo -e "$YELLOW""[Snapshots List...]""$ENDCOLOR"
restic snapshots

# Check and Clean Repo Based on User's Policy
if [[ -f "$DATEFILE" || "$CLEAN" -gt "0" ]]; then
  NOW=$(date +"%s")
  NEXT=$(date -f "$DATEFILE" "+%s")
  RESULT=$((NEXT-NOW))
  DAYS=$((RESULT / 86400))
  HOURS=$(((RESULT / 3600) % 24))
  MINUTES=$(((RESULT / 60) % 60))
  if test "$NOW" -lt "$NEXT" ; then
    if [[ "$DAYS" -gt "0" ]] ; then
      echo -e "$YELLOW""[Next check and cleanup in $DAYS days $HOURS hours and $MINUTES minutes...]""$ENDCOLOR"
    elif [[ "$HOURS" -gt "0" ]] ; then
      echo -e "$YELLOW""[Next check and cleanup in $HOURS hours and $MINUTES minutes...]""$ENDCOLOR"
    elif [[ "$MINUTES" -gt "0" ]] ; then
      echo -e "$YELLOW""[Next check and cleanup in $MINUTES minutes...]""$ENDCOLOR"
    else
      echo -e "$YELLOW""[Repo will be checked and cleaned in the next run...]""$ENDCOLOR"
    fi
  else 
    if [[ "$KEEP_HOURLY" -gt "0" || "$KEEP_DAILY" -gt "0" || "$KEEP_WEEKLY" -gt "0" || "$KEEP_MONTHLY" -gt "0" || "$KEEP_YEARLY" -gt "0" ]] ; then
      echo -e "$YELLOW""[Cleaning Repo...]""$ENDCOLOR"
      restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY
      restic prune
      echo -e "$YELLOW""[Checking for Errors in Repo...]""$ENDCOLOR"
      restic check --cleanup-cache
      if [[ "$CLEAN" -gt "0" ]] ; then
        echo -e "$YELLOW""[Done Cleaning; Next Check and Cleanup Will Be Done in $CLEAN days...]""$ENDCOLOR"
      fi
    fi
  fi
else 
    if [[ "$KEEP_HOURLY" -gt "0" || "$KEEP_DAILY" -gt "0" || "$KEEP_WEEKLY" -gt "0" || "$KEEP_MONTHLY" -gt "0" || "$KEEP_YEARLY" -gt "0" ]] ; then
      echo -e "$YELLOW""[Cleaning Repo...]""$ENDCOLOR"
      restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY
      restic prune
      echo -e "$YELLOW""[Checking for Errors in Repo...]""$ENDCOLOR"
      restic check --cleanup-cache
    fi
fi

if [[ -f "$DATEFILE" ]] ; then
  date -d now+"$CLEAN"days > "$DATEFILE"
fi


# Stats
echo -e "----------------------------------------------------------------------"
echo -e "$YELLOW""[Latest Snapshots Size...]""$ENDCOLOR"
restic stats latest
echo -e "$YELLOW""[Deduplicated Size for Latest Snapshot...]""$ENDCOLOR"
restic stats --mode raw-data latest
echo -e "$YELLOW""[Original Files Size...]""$ENDCOLOR"
restic stats
echo -e "$YELLOW""[Deduplicated Size for All Snapshots...]""$ENDCOLOR"
restic stats --mode raw-data
# Time and Runtime
echo -e "----------------------------------------------------------------------"
echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)" "         " "$YELLOW""Duration:""$ENDCOLOR" "$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"
echo -e "======================================================================"
echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
echo -e "======================================================================"

#reset credentials
export RESTIC_PASSWORD=$RESTIC_PASSWORD

exit 0