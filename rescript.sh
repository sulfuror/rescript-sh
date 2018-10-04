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
Version="rescript.sh-v1.5"
Usage='Author		: Sulfuror, Copyright (c) 2018 <sulfuror@gmail.com>
License		: BSD 2-clause "Simplified" License
Version		: rescript.sh-v1.5
Description	: rescript.sh is a shell script created to manage
		  backups made with restic program.

"restic is a backup program which allows saving multiple revisions 
of files and directories in an encrypted repository 
stored on different backends."

For more information about restic visit https://restic.net

Note that these commands only work when you have already set
the required values correctly.

Available commands:
	check			Check the repository for errors
	help			Help for this script
	init			Initialize a new repository
	prune			Remove unneeded data from the repository
	snapshots		List all snapshots
	unlock			Remove locks other processes created
	rebuild-index		Build a new index file
	stats			Scan the repository and show basic statistics
Commands usage:
	./rescript.sh [command]

Automatic options:
	-b, -backup		Make a backup	
	-c, -cleanup		Forget and prune [using your policies]
	-d, -deep-check		Check repository with --read-data flag
	-h, -help		Help for this script
	-m, -mount		Mount your restic repo
	-n, -next-cleanup	Display when it will do the next cleanup
	-v, -version		Version of this script
	-u, -unlock		Remove lock created by script
Automatic options usage:
	./rescript.sh [-o|-option]

User options [all user options require an argument]:
	-f			forget: Remove snapshots from the repository
	-g			find: Find a file or directory
	-k			keys: Manage keys [list|add|remove|passwd]
	-l			ls: List files in a snapshot
	-p			List snapshots with the following flags:
	-r			Restore a snapshot
	-s			Scan the repository and show basic statistics
		--help		This flag will display help for every
				user option
User options usage:
	./rescript.sh [-o] [option|--help]

For more information about the usage check out the following link:
https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
'
# ------------------------------------------------------------------------------- #
# Options
while getopts ":bcdf:g:hk:l:mnp:r:s:uv" o
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
		echo -e "$YELLOW""Date and Time:""$ENDCOLOR" "$(date)"
		echo -e "$YELLOW""System:""$ENDCOLOR" "$(cat /etc/issue.net) $(uname -o) $(uname -r)"
		echo -e "$YELLOW""Hostname:""$ENDCOLOR" "$HOSTNAME"
		if [[ "$DESTINATION" ]] ; then
		  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$DESTINATION"
		else
		  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$BACKUP_DIR"
		fi
		echo -e "----------------------------------------------------------------------"
		restic backup "$BACKUP_DIR" --tag "$TAG" --verbose --exclude-caches --exclude="/home/*/.cache/*" --exclude="/home/*/.local/share/Trash/*" --exclude="$EXCLUDE01" --exclude="$EXCLUDE02" --exclude="$EXCLUDE03" --exclude="$EXCLUDE04" --exclude="$EXCLUDE05" --exclude="$EXCLUDE06" --exclude="$EXCLUDE07" --exclude="$EXCLUDE08" --exclude="$EXCLUDE09" --exclude="$EXCLUDE10" --exclude="$EXCLUDE11" --exclude="$EXCLUDE12" --exclude="$EXCLUDE13" --exclude="$EXCLUDE14" --exclude="$EXCLUDE15"
		echo -e "----------------------------------------------------------------------"
		echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)"
		HRS=$((SECONDS / 3600))
		MIN=$(((SECONDS / 60) % 60))
		SEC=$((SECONDS % 60))
		if [[ "$HRS" -gt "0" ]] ; then
		  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$HRS hours $MIN minues $SEC seconds"
		elif [[ "$MIN" -gt "0" ]] ; then
		  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$MIN minutes $SEC seconds"
		else
		  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$SEC seconds"
		fi
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
			echo -e "$YELLOW""Date and Time:""$ENDCOLOR" "$(date)"
			echo -e "$YELLOW""System:""$ENDCOLOR" "$(cat /etc/issue.net) $(uname -o) $(uname -r)"
			echo -e "$YELLOW""Hostname:""$ENDCOLOR" "$HOSTNAME"
			if [[ "$DESTINATION" ]] ; then
			  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$DESTINATION"
			else
			  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$BACKUP_DIR"
			fi
			echo -e "----------------------------------------------------------------------"
		        restic forget --keep-hourly $KEEP_HOURLY --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY
		        restic prune --cleanup-cache
			if [[ -f "$DATEFILE" || "$CLEAN" -gt "0" ]] ; then
			  NOW=$(date +"%s")
			  NEXT=$(date -f "$DATEFILE" "+%s")
			  RESULT=$((NEXT-NOW))
			  DAYS=$((RESULT / 86400))
			  HOURS=$(((RESULT / 3600) % 24))
			  MINUTES=$(((RESULT / 60) % 60))
			  if [[ "$DAYS" -gt "0" ]] ; then
			    echo -e "$YELLOW""[Next check and cleanup in $DAYS days $HOURS hours and $MINUTES minutes...]""$ENDCOLOR"
			  elif [[ "$HOURS" -gt "0" ]] ; then
			    echo -e "$YELLOW""[Next check and cleanup in $HOURS hours and $MINUTES minutes...]""$ENDCOLOR"
			  elif [[ "$MINUTES" -gt "0" ]] ; then
			    echo -e "$YELLOW""[Next check and cleanup in $MINUTES minutes...]""$ENDCOLOR"
			  else
			    echo -e "$YELLOW""[Repo will be checked and cleaned in the next run...]""$ENDCOLOR"
			  fi
			fi
			echo -e "----------------------------------------------------------------------"
			echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)"
			HRS=$((SECONDS / 3600))
			MIN=$(((SECONDS / 60) % 60))
			SEC=$((SECONDS % 60))
			if [[ "$HRS" -gt "0" ]] ; then
			  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$HRS hours $MIN minues $SEC seconds"
			elif [[ "$MIN" -gt "0" ]] ; then
			  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$MIN minutes $SEC seconds"
			else
			  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$SEC seconds"
			fi
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
		while [[ $OPTARG ]] ; do
		  if [[ "$OPTARG" == "--help" ]] ; then
		    echo "[-f] is for [forget] command in restic"
		    echo "Usage:"
		    echo "	./rescript.sh -f [snapshot-ID]"
		  else
		    echo "Forgetting snapshot-ID $OPTARG"
		    restic forget "$OPTARG"
		  fi
		exit
		done
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
		while [[ $OPTARG == "--help" ]] ; do
		  echo "[-g] is for [find] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -g [pattern]"
		  echo "Usage with flags:"
		  echo "	./rescript.sh -g [flag] [host|path|snapshot|tag] [pattern]"
		  echo "Available flags:"
		  echo "	--host		only consider snapshots for this"
		  echo "			host, when no snapshot ID is given"
		  echo "	--long		use a long listing format showing"
		  echo "			size and mode"
		  echo "	--path		only consider snapshots wich include"
		  echo "			this (absolute) path, when no"
		  echo "			snapshot-ID is given"
		  echo "	--snapshot	snapshot-ID to search in"
		  echo "	--tag		only consider snapshots wich include"
		  echo "			this taglist, when no snapshot-ID"
		  echo "			is given"
		  echo "You can combine [--long] flag with any other flag"
		  echo "e.g.:"
		  echo "	./rescript.sh -g [flag] [host|path|snapshot|tag] --long [pattern]"
		exit
		done
		while [[ $OPTARG == "--host" || $OPTARG == "--path" || $OPTARG == "--snapshot" || $OPTARG == "--tag" ]] ; do
		  if [[ -z "$3" ]] ; then 
		    echo "No [$OPTARG] indicated"		    
		  elif [[ "$4" == "--long" ]] ; then
		    restic find "$OPTARG" "$3" "$4" "$5"
		  else
		    restic find "$OPTARG" "$3" "$4"
		  fi
		exit
		done
		while [[ $OPTARG ]] ; do
		  if [[ "$OPTARG" == "--long" ]] ; then
		    restic find "$OPTARG" "$3"
		  else
		    restic find "$OPTARG"
		  fi
		exit
		done
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
		while [[ $OPTARG == "--help" ]] ; do
		  echo "[-k] is for [key] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -k [list|add|remove|passwd] [ID]"
		  echo "Available options:"
		  echo "	add		add a key"
		  echo "	list		list all keys in your repo"
		  echo "	passwd		change a password for a key"
		  echo "	remove		remove a key from your repo"
		  echo "Available flags:"
		  echo "	--help		help for -l"
		exit
		done
		while [[ $OPTARG == "remove" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No key to [$OPTARG] indicated"
		  else
		    restic key "$OPTARG" "$3"
		  fi
		exit
		done
		while [[ $OPTARG ]] ; do
		  restic key "$OPTARG"
		exit
		done		
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
		while [[ $OPTARG == "--help" ]] ; do
		  echo "[-l] is for [ls] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -l [snapshot-ID]"
		  echo "Usage with flags:"
		  echo "	./rescript.sh -l [flag] [snapshot-ID]"
		  echo "Available flags:"
		  echo "	--help		help for -l"
		  echo "	--host		only consider snapshots for this"
		  echo "			host, when no snapshot ID is given"
		  echo "	--long		use a long listing format showing"
		  echo "			size and mode"
		  echo "	--path		only consider snapshots wich include"
		  echo "			this (absolute) path, when no"
		  echo "			snapshot-ID is given"
		  echo "	--tag		only consider snapshots wich include"
		  echo "			this taglist, when no snapshot-ID"
		  echo "			is given"
		exit
		done
		while [[ "$OPTARG" == "--host" || "$OPTARG" == "--long" || "$OPTARG" == "--path" || "$OPTARG" == "--tag" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No [$OPTARG] indicated"
		  elif [[ "$4" == "--long" ]] ; then
		    restic ls "$OPTARG" "$3" "$4" "$5"
		  else
		    restic ls "$OPTARG" "$3" "$4"
		  fi
		exit
		done
		while [[ "$OPTARG" ]] ; do
		  restic ls "$OPTARG"
		exit
		done
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
	p)
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
		while [[ "$OPTARG" == "--help" ]] ; do
		  echo "[-p] is for [snapshots] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -p [flag] [host|path|tag]"
		  echo "Available flags:"
		  echo "	--compact	use compact format"
		  echo "	--cleanup-cache	auto remove old cache directories"
		  echo "	--help		help for -p"
		  echo "	--host		only consider snapshots for this host"
		  echo "	--last		only show the last snapshot for each"
		  echo "			host and path [does not need an argument]"
		  echo "	--path		only consider snapshots for this path"
		  echo "	--tag		only consider snapshots which include this"
		  echo "			taglist"
		exit
		done
		while [[ $OPTARG == "--host" || $OPTARG == "--path" || $OPTARG == "--tag" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No [$OPTARG] indicated"
		  else
		    restic snapshots "$OPTARG" "$3"
		  fi
		exit
		done
		while [[ $OPTARG ]] ; do
		  restic snapshots "$OPTARG"
		exit
		done
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
		while [[ "$OPTARG" == "--help" ]] ; do
		  echo "[-r] is for [restore] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -r [snapshot-ID]"
		  echo "Usage with flags:"
		  echo "	./rescript.sh -r [flag] [host|path|tag]"
		  echo "Available flags:"
		  echo "	--help		help for -r"
		  echo "	--host		only consider snapshots for this host"
		  echo "			when snapshot-ID is [latest]"
		  echo "	--path		only consider snapshots which include"
		  echo "			this (absolute) path for snapshot-ID [latest]"
		  echo "	--tag		only consider snapshots which include this"
		  echo "			taglist for snapshot-ID [latest]"
		exit
		done
		while [[ "$OPTARG" == "--host" || "$OPTARG" == "--tag" || "$OPTARG" == "--path" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No [$OPTARG] indicated"
		  else
		    echo -e "======================================================================"
		    echo -e "|- - - - - - - > [ S T A R T I N G    R E S T O R E ] < - - - - - - -|"
		    echo -e "======================================================================"
		    echo -e "$YELLOW""Date and Time:""$ENDCOLOR" "$(date)"
		    echo -e "$YELLOW""System:""$ENDCOLOR" "$(cat /etc/issue.net) $(uname -o) $(uname -r)"
		    echo -e "$YELLOW""Hostname:""$ENDCOLOR" "$HOSTNAME"
		    if [[ "$DESTINATION" ]] ; then
		      echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$DESTINATION"
		    else
		      echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$BACKUP_DIR"
		    fi
		    echo -e "----------------------------------------------------------------------"
		    if [[ "$DESTINATION" ]] ; then
		      echo -e "$YELLOW""Restoring latest snapshot [$OPTARG: $3] from:""$ENDCOLOR" "$DESTINATION..."
		    else
		      echo -e "$YELLOW""Restoring latest snapshot [$OPTARG: $3] from:""$ENDCOLOR" "$BACKUP_DIR"
		    fi
		    if [[ "$OPTARG" == "--path" ]] ; then
		      restic_restore="$HOME/restore-latest-by-path-$(date +%s)"
		    else
		      restic_restore="$HOME/restore-latest-$3-$(date +%s)"
		    fi
		    restic restore --verify "$OPTARG" "$3" latest --target "$restic_restore"
		    echo -e "----------------------------------------------------------------------"
		    echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)"
		    HRS=$((SECONDS / 3600))
		    MIN=$(((SECONDS / 60) % 60))
		    SEC=$((SECONDS % 60))
		    if [[ "$HRS" -gt "0" ]] ; then
		      echo -e "$YELLOW""Duration:""$ENDCOLOR" "$HRS hours $MIN minues $SEC seconds"
		    elif [[ "$MIN" -gt "0" ]] ; then
		      echo -e "$YELLOW""Duration:""$ENDCOLOR" "$MIN minutes $SEC seconds"
		    else
		      echo -e "$YELLOW""Duration:""$ENDCOLOR" "$SEC seconds"
		    fi
		    echo -e "======================================================================"
		    echo -e "| - - - - - - > [ R E S T O R E    C O M P L E T E D ] < - - - - - - |"
		    echo -e "======================================================================"
		  fi
		exit
		done
		while [[ "$OPTARG" ]] ; do
		  echo -e "======================================================================"
		  echo -e "|- - - - - - - > [ S T A R T I N G    R E S T O R E ] < - - - - - - -|"
		  echo -e "======================================================================"
		  echo -e "$YELLOW""Date and Time:""$ENDCOLOR" "$(date)"
		  echo -e "$YELLOW""System:""$ENDCOLOR" "$(cat /etc/issue.net) $(uname -o) $(uname -r)"
		  echo -e "$YELLOW""Hostname:""$ENDCOLOR" "$HOSTNAME"
		  if [[ "$DESTINATION" ]] ; then
		    echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$DESTINATION"
		  else
		    echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$BACKUP_DIR"
		  fi
		  echo -e "----------------------------------------------------------------------"
		  if [[ "$DESTINATION" ]] ; then
		    if [[ "$3" ]] ; then
		      echo -e "$YELLOW""Restoring latest snapshot [$OPTARG: $3] from:""$ENDCOLOR" "$DESTINATION..."
		    else
		      echo -e "$YELLOW""Restoring $OPTARG snapshot from:""$ENDCOLOR" "$DESTINATION..."
		    fi
		  else
		    if [[ "$3" ]] ; then
		      echo -e "$YELLOW""Restoring latest snapshot [$OPTARG: $3] from:""$ENDCOLOR" "$BACKUP_DIR"
		    else
		      echo -e "$YELLOW""Restoring $OPTARG snapshot from:""$ENDCOLOR" "$BACKUP_DIR"
		    fi
		  fi
		  restic_restore="$HOME/restore-$OPTARG-$(date +%s)"
		  restic restore --verify "$OPTARG" --target "$restic_restore"
		  echo -e "----------------------------------------------------------------------"
		  echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)"
		  HRS=$((SECONDS / 3600))
		  MIN=$(((SECONDS / 60) % 60))
		  SEC=$((SECONDS % 60))
		  if [[ "$HRS" -gt "0" ]] ; then
		    echo -e "$YELLOW""Duration:""$ENDCOLOR" "$HRS hours $MIN minues $SEC seconds"
		  elif [[ "$MIN" -gt "0" ]] ; then
		    echo -e "$YELLOW""Duration:""$ENDCOLOR" "$MIN minutes $SEC seconds"
		  else
		    echo -e "$YELLOW""Duration:""$ENDCOLOR" "$SEC seconds"
		  fi
		  echo -e "======================================================================"
		  echo -e "| - - - - - - > [ R E S T O R E    C O M P L E T E D ] < - - - - - - |"
		  echo -e "======================================================================"
		exit
		done
		;;
	v|version)
	        echo "$Version"
        	;;
	s)
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
		while [[ "$OPTARG" == "--help" ]] ; do
		  echo "[-s] is for [stats] command in restic"
		  echo "Usage:"
		  echo "	./rescript.sh -s [snapshot-ID]"
		  echo "Usage with flags:"
		  echo "	./rescript.sh -s [--host] [host]"
		  echo "Usage with mode flag:"
		  echo "	./rescript.sh -s [--mode] [mode]"		  
		  echo "Available flags:"
		  echo "	--cleanup-cache	auto remove old cache directories"
		  echo "	--help		help for -s"
		  echo "	--host		filter latest snapshot by this hostname"
		  echo "	--mode		modes for counting data"
		  echo "Available modes:"
		  echo "	restore-size		(default) Counts the size of the"
		  echo "				restored files"
		  echo "	files-by-contents	Counts total size of files, where"
		  echo "				a file isconsidered unique if it"
		  echo "				has unique contents"
		  echo "	raw-data		Counts the size of blobs in the"
		  echo "				repository, regardless of how many"
		  echo "				files reference them"
		  echo "	blobs-per-file		A combination of files-by-contents"
		  echo "				and raw-data"
		exit
		done
		while [[ "$OPTARG" == "--host" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No [$OPTARG] indicated"
		  elif [[ "$4" == "--mode" ]] ; then
		    restic stats "$OPTARG" "$3" "$4" "$5"
		  else
		    restic stats "$OPTARG" "$3"
		  fi
		exit
		done
		while [[ "$OPTARG" == "--mode" ]] ; do
		  if [[ -z "$3" ]] ; then
		    echo "No [$OPTARG] indicated"
		    echo "Available modes:"
		    echo "	restore-size		(default) Counts the size of the"
		    echo "				restored files"
		    echo "	files-by-contents	Counts total size of files, where"
		    echo "				a file isconsidered unique if it"
		    echo "				has unique contents"
		    echo "	raw-data		Counts the size of blobs in the"
		    echo "				repository, regardless of how many"
		    echo "				files reference them"
		    echo "	blobs-per-file		A combination of files-by-contents"
		    echo "				and raw-data"
		  elif [[ "$5" ]] ; then
		    restic stats "$OPTARG" "$3" "$4" "$5"
		  elif [[ -z "$5" ]] ; then
		    restic stats "$OPTARG" "$3" "$4"
		  else
		    restic stats "$OPTARG" "$3"
		  fi
		exit
		done
		while [[ "$OPTARG" ]] ; do
		  restic stats "$OPTARG"
		exit
		done
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
	        echo "Unknown option [-$OPTARG]; use [-h] or [help] for available commands and options"
	        ;;
	:)
		echo "You have not indicated any option for [-$OPTARG]"
		echo "	-f requires a snapshot-ID to forget [use -f --help"
		echo "	   for usage]"
		echo "	-g requires a file or directory to find [use -g --help for"
		echo "	   usage and available flags]"
		echo "	-k requires one of these four options: list, add, remove,"
		echo "	   passwd [use -k --help for usage]"
		echo "	-l requires a snapshot-ID to list [use -l --help for usage]"
		echo "	-p requires a flag [use -p --help for usage and"
		echo "	   available flags]"
		echo "	-r requires a snapshot-ID to restore [use -r --help for"
		echo "	   usage and available flags]"
		echo "	-s requires a flag [use -k --help for usage and available flags]"
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
if [[ -n "$command" ]] ; then
  if [[ "$command" == "help" ]] ; then
    echo "$Usage"
    exit
  elif [[ "$command" == "version" ]] ; then
    echo "$Version"
    exit
  else
    for command in "$@"
    do restic "$1"
    done
    exit
  fi
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
echo -e "$YELLOW""Date and Time:""$ENDCOLOR" "$(date)"
echo -e "$YELLOW""System:""$ENDCOLOR" "$(cat /etc/issue.net) $(uname -o) $(uname -r)"
echo -e "$YELLOW""Hostname:""$ENDCOLOR" "$HOSTNAME"
if [[ "$DESTINATION" ]] ; then
  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$DESTINATION"
else
  echo -e "$YELLOW""Backup Destination:""$ENDCOLOR" "$BACKUP_DIR"
fi
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

echo -e "----------------------------------------------------------------------"
# Snapshot List
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
  if [[ "$NOW" -lt "$NEXT" ]] ; then
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
echo -e "$YELLOW""End:""$ENDCOLOR" "$(date)"
HRS=$((SECONDS / 3600))
MIN=$(((SECONDS / 60) % 60))
SEC=$((SECONDS % 60))
if [[ "$HRS" -gt "0" ]] ; then
  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$HRS hours $MIN minues $SEC seconds"
elif [[ "$MIN" -gt "0" ]] ; then
  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$MIN minutes $SEC seconds"
else
  echo -e "$YELLOW""Duration:""$ENDCOLOR" "$SEC seconds"
fi
echo -e "======================================================================"
echo -e "| - - - - - - - - > [ B A C K U P      E N D E D ] < - - - - - - - - |"
echo -e "======================================================================"

#reset credentials
export RESTIC_PASSWORD=$RESTIC_PASSWORD

exit 0