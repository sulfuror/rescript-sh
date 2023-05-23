#!/usr/bin/env bash
# ============================================================== #
version="4.7"
function usage {
cat <<EOF
Name        : rescript
Author      : Sulfuror, Copyright (c) 2018 <sulfuror@gmail.com>
URL         : https://gitlab.com/sulfuror/rescript.sh
License     : BSD 2-Clause License
Version     : $version
Description : rescript is a bash shell wrapper for restic

Information about restic: https://restic.net

This script will run backup, snapshots, forget, prune, check and
stats commands automatically by just indicating the name given
to your configuration file (repo_name). e.g.:

  rescript [repo_name]

Usage:
  rescript [config_command]
  rescript [repo_name] [command] [flags] ...
  rescript [repo_name] [restic_command] [flags] ...
  
Configuration commands:
  config                Rescript configuration.
  editor                Change default text editor used by rescript.
  help                  Display rescript usage.
  install               Install rescript.
  update                Check/install new rescript version.
  version               Display rescript version.
  
Commands:
  archive               Creates new snapshot with deleted files.
  backup                Take a snapshot.
  changes               Display changes between latest snapshots.
  checkout              Check repository with random subset number.
  cleanup               Apply retention policies and prune.
  env                   Display values in your configurations.
  info                  Display stats for latest and all snapshots.
  logs                  List, view or remove your log files.
  mounter               Mount a restic repo.
  restorer              Restore a restic snapshot.
  snaps                 List snapshots in your repository (compact mode).
  unlocker              Remove lock created by rescript.

Glogal flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

Commands usage:
  rescript help [command]

Make use of global flags with any restic command as follows:
  rescript [repo_name] -delqt -- [restic_command] [flags] ...

EOF
}
# ============================================================== #
yellow="\033[33m"
endcolor="\033[0m"
repo="$1"

# Rescript directories and files
rescript_dir="$HOME/.rescript"
config_dir="$rescript_dir/config"
lock_dir="$rescript_dir/lock"
logs_dir="$rescript_dir/logs"
tmplog=$(mktemp)
excludes="$config_dir/$1-exclusions"
lock="$lock_dir/$repo.lock"
config_file="$config_dir/$repo.conf"
unix_name=$(uname -s)

if [[ -d "/tmp" ]] ; then
  tmp_dir="/tmp"
else
  tmp_dir="$TMPDIR"
fi

shopt -s nocasematch

function ctrl_c {
  echo ""
  echo "################ Proccess interrupted ################"
  echo ""
  exit 130
}

trap ctrl_c INT

# Create a rescript directories if they are not present
if [[ ! -d "$rescript_dir" ]]; then
  mkdir -p "$rescript_dir"
fi
if [[ ! -d "$config_dir" ]]; then
  mkdir -p "$config_dir"
fi
if [[ ! -d "$lock_dir" ]]; then
  mkdir -p "$lock_dir"
fi
if [[ ! -d "$logs_dir" ]]; then
  mkdir -p "$logs_dir"
fi
# Create "editor" file if not present
if [[ ! -f "$config_dir/.editor" ]] ; then
  touch "$config_dir/.editor"
fi
rescript_editor="$(cat "$config_dir/.editor")"
# Set PATH so it includes user's private bin if it exists (cron jobs may require this)
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

tput_columns=$(tput cols 2>/dev/null)

if [[ "$tput_columns" -gt "0" ]] ; then
  if [[ "$tput_columns" -gt "80" ]] ; then
    cols="80"
  else
    cols="$(tput cols)"
  fi
else
  cols="80"
fi

if [[ -t 1 ]] ; then
  int="true"
else
  int="false"
fi

function job_done {
  if [[ -z "$cmd" ]] ; then
    cmd="backup"
  fi
  if [[ "$CONFIRMATION_EMAIL" = "y" || "$CONFIRMATION_EMAIL" = "yes" ]] ; then
    if [[ -n "$EMAIL" ]] ; then
      if [[ "$(command -v mail)" ]] ; then
        if [[ "$int" = "false" ]] ; then
          if [[ -e "$log" ]] ; then
            logmessage="Logfile: $log"
            catlog=$(sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$log")
          else
            logmessage="Output for this job:"
            catlog=$(sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$tmplog")
          fi
          if [[ "$time_flag" = "true" ]] ; then
            echo -e "$logmessage" "\n" "$catlog" | mail -s "rescript: [$repo] $cmd finished successfully!" $EMAIL
          else
            echo -e "Date: $(date +%a\ %b\ %d\ %Y\ %r)" "\nSystem: $(opsys)" "\nHostname: $rhost" "\nRepository Location: $dest" "\nRestic Version: $(restic version | awk '{print $2}')" "\n" "\n$logmessage" "\n$(printf "%${cols}s\n" "" | tr ' ' -)" "\n$catlog" "\n$(printf "%${cols}s\n" "" | tr ' ' -)" "\nEnd: $(date +%a\ %b\ %d\ %Y\ %r)" "\nDuration: $(duration)"  | mail -s "rescript: [$repo] $cmd finished successfully!" $EMAIL
          fi
        fi
      else
        echo "[rescript] can't send emails; install [mailutils] package to do so."
      fi
    fi
  fi
}

function report_errors {
  if [[ -z "$cmd" ]] ; then
    cmd="backup"
  fi
  if [[ -n "$error_message" ]] ; then
    if [[ "$ping_code" -gt "0" ]] ; then
      echo -e "$error_message"
    else
      echo ""
      echo -e "WARNING!"
      echo -e "$error_message"
    fi
    if [[ -n "$EMAIL" ]] ; then
      if [[ "$(command -v mail)" ]] ; then
        if [[ "$int" = "false" ]] ; then
          time_end
          if [[ -e "$log" ]] ; then
            logmessage="Logfile: $log"
            catlog=$(sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$log")
          else
            logmessage="Output for this job:"
            catlog=$(sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$tmplog")
          fi
          if [[ "$time_flag" = "true" ]] ; then
            echo -e "$logmessage" "\n" "$catlog" | mail -s "rescript: [$repo] $cmd failed!" $EMAIL
          else
            echo -e "Date: $(date +%a\ %b\ %d\ %Y\ %r)" "\nSystem: $(opsys)" "\nHostname: $rhost" "\nRepository Location: $dest" "\nRestic Version: $(restic version | awk '{print $2}')" "\n" "\n$logmessage" "\n$(printf "%${cols}s\n" "" | tr ' ' -)" "\n$catlog" "\n$(printf "%${cols}s\n" "" | tr ' ' -)" "\nEnd: $(date +%a\ %b\ %d\ %Y\ %r)" "\nDuration: $(duration)"  | mail -s "rescript: [$repo] $cmd failed!" $EMAIL
          fi
          exit "$exit_code"
        fi
      else
        echo "[rescript] can't send emails; install [mailutils] package to do so."
      fi
    fi
  fi
}

function latest_error {
  exec 6>&-
  if [[ "$exit_code" != "0" ]] ; then
    if [[  -n "$rest_cmd" ]] ; then
      error_message="[$rest_cmd] failed; exit code $exit_code"
      report_errors
      time_end
      exit "$exit_code"
    elif [[ "$(echo "$latest_cmd" | awk '{print $1}')" = "restic" || "$(echo "$latest_cmd" | awk '{print $1}')" = *"restic" ]] ; then
      error_message="[$(echo "$latest_cmd" | awk '{print $2}')] failed; exit code $exit_code"
      report_errors
      time_end
      exit "$exit_code"
    else
      error_message="[$(echo "$latest_cmd" | awk '{print $1}')] failed; exit code $exit_code"
      report_errors
      time_end
      exit "$exit_code"
    fi
  fi
}

function opsys {
  case "$unix_name" in
    Linux|GNU)
      if [[ "$(uname -o)" = "Android" ]] ; then
        os="$(uname -o)"
        os_vers="$(getprop ro.build.version.release)"
        echo -e "$os" "$os_vers"
      else
        if [[ $(command -v lsb_release) ]] ; then
          lsb_release -ds
        else
          cat /etc/issue.net
        fi
      fi
      ;;
    FreeBSD|NetBSD|OpenBSD)
      uname -rs
      ;;
    Darwin)
      os="$(sw_vers -productName)"
      os_vers="$(sw_vers -productVersion)"
      echo -e "$os" "$os_vers"
      ;;
    *)
      echo -e "Unknown OS"
      ;;
  esac
}

function duration {
  declare -a dur
  d="$((SECONDS/60/60/24))"
  h="$((SECONDS/60/60%24))"
  m="$((SECONDS/60%60))"
  s="$((SECONDS%60))"
  days="days"
  hrs="hours"
  min="minutes"
  sec="seconds"
  if [[ "$d" = "1" ]] ; then
    days="day"
  fi
  if [[ "$h" = "1" ]] ; then
    hrs="hour"
  fi
  if [[ "$m" = "1" ]] ; then
    min="minute"
  fi
  if [[ "$s" = "1" ]] ; then
    sec="second"
  fi
  if [[ "$d" -gt "0" ]] ; then
    dur+=( "$d $days" )
  fi
  if [[ "$h" -gt "0" ]] ; then
    dur+=( "$h $hrs" )
  fi
  if [[ "$m" -gt "0" ]] ; then
    dur+=( "$m $min" )
  fi
  if [[ "$s" -gt "0" ]] ; then
    dur+=( "$s $sec" )
  fi
  ndur=$(echo ${#dur[@]})
  case "$ndur" in
    4) echo "${dur[0]}, ${dur[1]}, ${dur[2]} and ${dur[3]}" ;;
    3) echo "${dur[0]}, ${dur[1]} and ${dur[2]}" ;;
    2) echo "${dur[0]} and ${dur[1]}" ;;
    1) echo "${dur[0]}" ;;
    0) echo "Too fast!" ;;
  esac
}
# ============================================================== #
# Menu                                                           #
# ============================================================== #
# Select Editor Menu
function select_editor {
  clear
  echo "======================"
  echo "  Select Text Editor  "
  echo "======================"
  echo " [1] Nano             "
  echo " [2] Vim              "
  echo " [3] Gedit            "
  echo " [4] Mousepad         "
  echo " [5] Leafpad          "
  echo " [6] Pluma            "
  echo " [7] Kate             "
  echo " [8] Xed              "  
  echo " [9] Other            "
  echo " [10] Exit            "
  echo "======================"
  read -rp "Select the Text Editor you want to use [ 1 - 9 ]: " texteditor
  case "$texteditor" in
    1|nano) echo "nano" > "$config_dir/.editor"; echo "You have selected [Nano] as your default text editor." ;;
    2|vim) echo "vim" > "$config_dir/.editor"; echo "You have selected [Vim] as your default text editor." ;;
    3|gedit) echo "gedit" > "$config_dir/.editor" ; echo "You have selected [Gedit] as your default text editor." ;;
    4|mousepad) echo "mousepad" > "$config_dir/.editor" ; echo "You have selected [Mousepad] as your default text editor." ;;
    5|leafpad) echo "leafpad" > "$config_dir/.editor" ; echo "You have selected [Leafpad] as your default text editor." ;;
    6|pluma) echo "pluma" > "$config_dir/.editor" ; echo "You have selected [Pluma] as your default text editor." ;;
    7|kate) echo "kate" > "$config_dir/.editor" ; echo "You have selected [Kate] as your default text editor." ;;
    8|xed) echo "xed" > "$config_dir/.editor" ; echo "You have selected [Xed] as your default text editor." ;;
    9|other) read -rp "Type the executable name of the Text Editor you want to use: " othertextedit ; echo "$othertextedit" > "$config_dir/.editor" ; echo "You have selected [$othertextedit] as your default text editor." ;;
    10|exit) echo "Exiting..." ; exit ;;
    *) echo "[$texteditor] is not a valid option. If you want to set your" ; echo "own text editor, type [9] or [other] to write your own." ; exit ;;
  esac
}

# Main menu
function main_menu {
  echo "======================"
  echo "        Menu          "
  echo "======================"
  echo " [1] Configuration    "
  echo " [2] Exclusions       "
  echo " [3] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 3 ]: " main
  case "$main" in
    1|configuration) clear ; config_menu ;;
    2|exclusions) clear ; exclusion_menu ;;
    3|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid option..." ; main_menu ;;
  esac
}

# Configuration menu
function config_file {
cat <<EOF
# =============================================================================== #
#                   R E S C R I P T    C O N F I G U R A T I O N                  #
# =============================================================================== #
# You need to set your restic password (password for the repository), the
# directory for your repository, the backup directory (by default the backup
# directory is your Home directory), your tag (empty by default if used) and
# your "keep" and "excludes" policies.
# ------------------------------------------------------------------------------- #
# REQUIRED VALUES
# ------------------------------------------------------------------------------- #
# Set restic password, repository location/directory and backup directory.
RESTIC_PASSWORD=""
RESTIC_REPO=""
BACKUP_DIR="$HOME"

# Keep Policies (leave blank if not used)
KEEP_LAST=""
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"
KEEP_WITHIN=""
KEEP_TAG=""

# AWS, B2, Azure, Google Cloud Credentials; for other not listed here you can
# the values here (leave blank if not used).
AWS_ID=""
AWS_KEY=""
AZURE_NAME=""
AZURE_KEY=""
B2_ID=""
B2_KEY=""
GOOGLE_ID=""
GOOGLE_CREDENTIALS=""

# ------------------------------------------------------------------------------- #
# OPTIONAL VALUES
# ------------------------------------------------------------------------------- #
# ARCHIVE: set to "yes" to execute the "archive" command when using "rescript [repo_name]" only.
# CLEAN: determine when it will execute forget, prune and check (i.e.: 7minutes, 7hours, 7days); by default is set to 7 days.
# CONFIRMATION_EMAIL: set to "yes" to receive email with output when job finished successfully.
# DESTINATION: display name of your destination in output instead of path (i.e.: Wasabi, B2, etc.).
# EMAIL: put your email address to receive emails with output when something fails (when using cron only).
# EXCLUDE_FILE: set "yes" to use the exclude file generated for backups (by default is set to yes; if blank it will read the exclusion file for previous versions comptability).
# EXCLUDE_CACHE: set "yes" to use "--exclude-cache" flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
# HOST: use a custom hostname for your snapshots.
# KEEP_ARCHIVE: set to "yes" to keep all snapshots tagged with "archive" (by default is set to yes).
# LOGGING: set to "yes" to save a log with output when using the automatic function (by default is set to yes).
# ONE_FILE_SYSTEM: set to "yes" to use "--one-file-system" flag for backups.
# SKIP_OFFICE: set to yes to temporarily exclude open (in use) "office" documents.
# TAG: tag your snapshots.
ARCHIVE=""
CLEAN="7days"
CONFIRMATION_EMAIL=""
DESTINATION=""
EMAIL=""
EXCLUDE_FILE="yes"
EXCLUDE_CACHE="yes"
HOST=""
KEEP_ARCHIVE="yes"
LOGGING="yes"
ONE_FILE_SYSTEM=""
SKIP_OFFICE=""
TAG=""
EOF
}

function simple_exclusions {
cat <<EOF
# These are the default rescript exclusions:
$HOME/.cache/*
$HOME/.local/share/Trash/*
$HOME/.rescript/lock/*
$HOME/.Trash
$HOME/.Private
$HOME/.ecryptfs

# Write your custom exclusions below:
EOF
}

function long_exclusions {
cat <<EOF
# These are the default rescript exclusions for your home directory:
$HOME/.cache/*
$HOME/.local/share/Trash/*
$HOME/.rescript/lock/*
$HOME/.gvfs
$HOME/.dbus
$HOME/.local/share/gvfs-metadata
$HOME/.Private
$HOME/.Trash
$HOME/.cddb
$HOME/.aptitude
$HOME/.adobe
$HOME/.bash_history
$HOME/.dropbox
$HOME/.dropbox-dist
$HOME/.macromedia
$HOME/.xsession-errors
$HOME/.recently-used
$HOME/.recently-used.xbel
$HOME/.local/share/recently-used*
$HOME/.thumbnails/*
$HOME/.Xauthority
$HOME/.ICEauthority
$HOME/.gksu.lock
$HOME/.pulse
$HOME/.pulse-cookie
$HOME/.esd_auth
$HOME/.ecryptfs
$HOME/.mozilla
$HOME/.config/google-chrome
$HOME/.config/chromium
$HOME/.opera
$HOME/.npm
$HOME/.gnupg/rnd
$HOME/.gnupg/random_seed
$HOME/.gnupg/.#*
$HOME/.gnupg/*.lock
$HOME/.gnupg/gpg-agent-info-*
$HOME/.config/**/Cache
$HOME/.config/**/GPUCache
$HOME/.config/**/ShaderCache
$HOME/snap/**/.config/**/Cache
$HOME/snap/**/.config/**/GPUCache
$HOME/snap/**/.config/**/ShaderCache
$HOME/Downloads
*.lock
*.bak
*.backup
*.backup*
*~

# Write your custom exclusions below:
EOF
}

function sys_exclusions {
cat <<EOF
# These are the default rescript exclusions for your system:
/home/*
/proc/*
/sys/*
/dev/*
/run/*
/mnt/*
/media/*
/etc/mtab
/var/cache/apt/archives/*.deb
lost+found/*
/tmp/*
/var/tmp/*
/var/backups/*

# Write your custom exclusions below:
EOF
}

function config_menu {
  echo "======================"
  echo "       Options        "
  echo "======================"
  echo " [1] Edit Existing    "
  echo " [2] New Repository   "
  echo " [3] Delete Config    "
  echo " [4] Back to Main Menu"
  echo " [5] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 5 ]: " cfgopt
  case "$cfgopt" in
    1|edit) clear ; edit_config_files ;;
    2|new) new_config_file ;;
    3|delete) clear ; delete_config_file ;;
    4|back) clear ; main_menu ;;
    5|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid selection; try again..." ; config_menu ;;
  esac
}

function edit_config_files {
  echo "======================"
  echo "     Config Files     "
  echo "======================"
  echo " [1] Back to Main Menu"
  echo " [2] Exit             "
  echo "----------------------"
  ls "$config_dir" | grep -e '.conf' | sed -e 's/\.conf$//'
  echo "======================"
  read -rp "Write the name of the repo file to open or one of the options above [ 1 - 2 ]: " conf
  case "$conf" in
    1|back) clear ; config_menu ;;
    2|exit) echo "Exiting..." ; exit ;;
    *)
      if [[ -e "$config_dir/$conf.conf" ]] ; then
        "$rescript_editor" "$config_dir/$conf.conf" 2> /dev/null
        clear
        edit_config_files
      else
        clear
        echo "There is no repo called [$conf]; try again with the correct name."
        edit_config_files
      fi
      ;;
  esac
}  

function new_config_file {
  new_repo="$config_dir/.new"
  touch "$new_repo"
  trap 'rm -rf "$new_repo"' INT QUIT TERM EXIT
  config_file > "$new_repo"
  chmod 700 "$new_repo"
  read -rp "Write the name for your new repository (case sensitive): " repo_name
  if [[ $repo_name ]] ; then
    mv "$new_repo" "$config_dir/$repo_name.conf"
    touch "$config_dir/$repo_name-exclusions"
    touch "$config_dir/$repo_name-datefile"
    touch "$config_dir/$repo_name-datefile"
    simple_exclusions > "$config_dir/$repo_name-exclusions"
    date -R > "$config_dir/$repo_name-datefile"
    echo "[$repo_name] config file have been created. If this is a new repository,"
    echo "you must run [rescript $repo_name init] to initialize your new repository"
    echo "before executing any other command. You also need to edit your new config"
    echo "file to proceed."
    read -rp "Would you like to open [$repo_name] config file now? y/n " answer
    case $answer in
      y|yes) "$rescript_editor" "$config_dir/$repo_name.conf" 2> /dev/null ; clear ; config_menu ;;
      n|no) echo "Remember to configure your repo file before continuing!" ; exit ;;
      *) clear ; echo "Invalid action..." ; config_menu ;;
    esac
  else
    rm -rf "$new_repo"
    echo "Exiting..."
    exit
  fi
}

function delete_config_file {
  echo "======================"
  echo "     Config Files     "
  echo "======================"
  echo " [1] Back to Main Menu"
  echo " [2] Exit             "
  echo "----------------------"
  ls "$config_dir" | grep -e '.conf' | sed -e 's/\.conf$//'
  echo "======================"
  read -rp "Type the name of the repo file you wish to delete or one of the optinos above [ 1 - 2 ]: " del
  case $del in
    1|back) clear ; config_menu ;;
    2|exit) echo "Exiting..." ; exit ;;
    *)
      if [[ -f "$config_dir/$del.conf" ]] ; then
        read -rp "Are you sure you want to delete [$del]? y/n: " ans
        case $ans in
          y|yes) rm -rf "$config_dir/$del.conf" ; rm -rf "$config_dir/$del-exclusions" ; rm -rf "$config_dir/$del-datefile" ; clear ; echo "[$del] repository configuration have been removed." ; delete_config_file ;;
          n|no) clear ; delete_config_file ;;
          exit) echo "Exiting..." ; exit ;;
          *) echo "No valid action indicated; exiting..." ; exit ;;
        esac
      else
        clear
        echo "There is no configuration files called [$del}; try again..."
        delete_config_file
      fi
      ;;
  esac
}

# Exclusions menu
function exclusion_menu {
  echo "======================"
  echo "  Exclusions Options  "
  echo "======================"
  echo " [1] Edit Existing    "
  echo " [2] Build Exclusions "
  echo " [3] Back to Main Menu"
  echo " [4] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 4 ]: " excl_opt
  case $excl_opt in
    1|edit) clear ; edit_exclusions ;;
    2|build) clear ; build_exclusions ;;
    3|back) clear ; main_menu ;;
    4|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid action indicated..." ; exclusion_menu ;;
  esac
}

function edit_exclusions {
  echo "======================"
  echo "   Exclusion Files    "
  echo "======================"
  echo " [1] Back             "
  echo " [2] Exit             "
  echo "----------------------"
  ls "$config_dir" | grep -e '-exclusions' | sed -e 's/\-exclusions$//'
  echo "======================"
  read -rp "Type the name of the exclusions file you wish to open or one of the options above [ 1 - 2 ]: " excl_edit
  case "$excl_edit" in
    1|back) clear ; exclusion_menu ;;
    2|exit) echo "Exiting..." ; exit ;;
    *)
      if [[ -e "$config_dir/$excl_edit-exclusions" ]] ; then
        "$rescript_editor" "$config_dir/$excl_edit-exclusions" 2> /dev/null
        clear
        edit_exclusions
      else
        clear
        echo "There is no exclusion file called [$excl_edit]; try again..."
        edit_exclusions
      fi
      ;;
  esac
}

function build_exclusions {
  echo "======================"
  echo "    Build Options     "
  echo "======================"
  echo " [1] For Home Dir     "
  echo " [2] For System Dir   "
  echo " [3] Back             "
  echo " [4] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 4 ]: " excl_bld
  case "$excl_bld" in
    1|home)
      clear
      echo "======================"
      echo " Exclusion Files List "
      echo "======================"
      echo " [1] Back             "
      echo " [2] Exit             "
      echo "----------------------"    
      ls "$config_dir" | grep -e '-exclusions' | sed -e 's/\-exclusions$//'
      echo "======================"
      read -rp "Type the name of the exclusion file you want to build or one of the options above [ 1 - 2 ]: " excl_file
      case "$excl_file" in
        1|back) clear ; build_exclusions ;;
        2|exit) echo "Exiting..." ; exit ;;
        *)
          if [[ -e "$config_dir/$excl_file-exclusions" ]] ; then 
            echo "This action will override your existing [$excl_file] exclusion file."
            read -rp "Are you sure you want to proceed? y/n: " ans_excl
            case "$ans_excl" in
              y|yes)
                if [[ -e "$config_dir/$excl_file-exclusions" ]] ; then
              	  long_exclusions > "$config_dir/$excl_file-exclusions"
              	  clear
              	  echo "Done building exclusion list for [$excl_file]."
              	  build_exclusions
                else
              	  clear
              	  echo "There is no exclusion file called [$excl_file]; try again with the correct name."
              	  build_exclusions
                fi
                ;;
              n|no) clear ; echo "No changes made." ; build_exclusions ;;
              *) clear ; echo "No valid option; no changes made." ; build_exclusions ;;
            esac
          else
            clear
            echo "There is no exclusion file called [$excl_file]."
            build_exclusions
          fi            
          ;;
      esac
      ;;
    2|system)
      clear
      echo "======================"
      echo " Exclusion Files List "
      echo "======================"
      echo " [1] Back             "
      echo " [2] Exit             "
      echo "----------------------"    
      ls "$config_dir" | grep -e '-exclusions' | sed -e 's/\-exclusions$//'
      echo "======================"
      read -rp "Type the name of the exclusion file you want to build or one of the options above [ 1 - 2 ]: " excl_file
      case "$excl_file" in
        1|back) clear ; build_exclusions ;;
        2|exit) echo "Exiting..." ; exit ;;
        *)
          if [[ -e "$config_dir/$excl_file-exclusions" ]] ; then 
            echo "This action will override your existing [$excl_file] exclusion file."
            read -rp "Are you sure you want to proceed? y/n: " ans_excl
            case "$ans_excl" in
              y|yes)
                if [[ -e "$config_dir/$excl_file-exclusions" ]] ; then
              	  sys_exclusions > "$config_dir/$excl_file-exclusions"
              	  clear
              	  echo "Done building exclusion list for [$excl_file]."
              	  build_exclusions
                else
  	              clear
              	  echo "There is no exclusion file called [$excl_file]; try again with the correct name."
              	  build_exclusions
                fi
                ;;
              n|no) clear ; echo "No changes made." ; build_exclusions ;;
              *) clear ; echo "No valid option; no changes made." ; build_exclusions ;;
            esac
          else
            clear
            echo "There is no exclusion file called [$excl_file]."
            build_exclusions
          fi
          ;;
      esac
      ;;
    3|back) clear ; exclusion_menu ;;
    4|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid action indicated..." ; build_exclusions ;;
  esac
}

# ============================================================== #
# Install & Update																							 #
# ============================================================== #
function install {
  echo "======================"
  echo "     Installation     "
  echo "======================"
  echo " [1] System-wide      "
  echo " [2] For this user    "
  echo " [3] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 4 ]: " installation
  case "$installation" in
    1|system)
      chmod 755 "$(basename $0)"
      if [[ "$(whoami)" = "root" ]] ; then
        if [[ "$unix_name" = "Darwin" ]] ; then
          cp "$(basename $0)" /usr/local/bin/rescript
        else
          cp "$(basename $0)" /usr/bin/rescript
        fi
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      else
        echo "You must be [root] for system-wide installation. e.g.:"
        echo "  sudo ./rescript install"
        echo ""
        echo "Nothing done; exiting..."
        exit
      fi
      ;;
    2|user)
      chmod 700 "$(basename $0)"
      if [[ -d "$HOME/bin" ]] ; then
        cp "$(basename $0)" "$HOME/bin/rescript"
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      elif [[ -d "$HOME/.local/bin" ]] ; then
        cp "$(basename $0)" "$HOME/.local/bin/rescript"
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      else
        echo "There is no [$HOME/.local/bin] directory present."
        read -rp "Do you wish to create it now? y/n: " ans_install
        case $ans_install in
          y|yes)
            mkdir -p "$HOME/.local/bin"
            cp "$(basename $0)" "$HOME/.local/bin/rescript"
            echo "Installation successful!"
            echo "Run [rescript config] to configure your repository."
            echo ""
            echo "Remember to include $HOME/.local/bin in your PATH."
            exit
            ;;
          n|no)
            echo "Nothing done; exiting..."
            exit
            ;;
          *)
            echo "No valid action indicated; exiting..."
            exit
            ;;
        esac
      fi
      ;;
    3|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid action indicated..." ; install ;;
  esac
}

function update {
  if [[ ! $(command -v wget) ]] ; then
    echo "***$(basename $0) warning***"
    echo "[wget] not found..."
    echo ""
    echo "[$repo] works with [wget] to download the updated script."
    echo "Please, install [wget] to proceed."
    exit
  fi
  if [[ -d "/tmp" ]] ; then
    tmp_dir="/tmp"
  else
    tmp_dir="$TMPDIR"
  fi
  wget -P "$tmp_dir" https://gitlab.com/sulfuror/rescript.sh/raw/master/rescript 2> /dev/null
  rescript_latest="$tmp_dir/rescript"
  trap 'rm -rf "$rescript_latest" 2> /dev/null' INT QUIT TERM EXIT

  if [[ "$(sed '3!d' "$(command -v rescript)")" = "$(sed '3!d' "$rescript_latest")" ]] ; then
    echo "You are already running rescript $version, which is the latest version."
    exit 0
  else
    chmod 755 "$rescript_latest"
    read -rp "rescript version $(sed '3!d' "$rescript_latest" | sed -e 's/version=//g') is available; do you want to install it? (y/n): " updater
    case "$updater" in
      y|yes)
        if [[ $(command -v rescript) == /usr/bin/rescript || $(command -v rescript) == /bin/rescript || $(command -v rescript) == /usr/local/bin/rescript ]] ; then
          if [[ "$(whoami)" = "root" ]] ; then
            mv "$rescript_latest" "$(command -v rescript)"
            echo "Rescript have been updated to the latest version!"
          else
            echo "Rescript is located at $(command -v rescript)."
            echo "To update in this location you need to run [update] again as [root]:"
            echo ""
            echo "  sudo rescript update"
            echo "" 
            echo "Nothing done... exiting."
            exit 0
          fi
        else
          chmod 700 "$rescript_latest"
          mv "$rescript_latest" "$(command -v rescript)"
          echo "Rescript have been updated to the latest version!"
        fi
        ;;
      *)
        echo "Nothing done... exiting."
        exit 0
        ;;
    esac
  fi
}

# ============================================================== #
# Commands Help																									 #
# ============================================================== #
function archive-help {
cat <<EOF
[archive] is a special feature that uses [diff], [restore]
and [backup]

This command check for differences between the latest two
snapshots, then restores only deleted files from the latest
snapshot and finally creates a new backup with a tag named
[archive]. This function is also available as a flag for
[backup] and [cleanup] commands (-a|--archive).

Usage:
  rescript [repo_name] archive [flags] ...

Command flags:
  -H, --host hostname   Only consider snapshots for this host.
  -i, --info            Display stats for latest and all snapshots.

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

EOF
}

function backup-help {
cat <<EOF
[backup] is for [backup] command in restic

This command will take a new snapshot using the values set
in your configuration file.

Usage:
  rescript [repo_name] backup [flags]

Command flags:
  -a, --archive         Creates new snapshot with deleted files.
  -C, --check           Check for errors in repository.
  -c, --cleanup         Apply retention policies and prune.
  -D, --dry-run         Do not backup anything, just print what
                        would be done (this option uses [du]).
  -i, --info            Display stats for latest and all snapshots.
  -S, --skip-office     Temporarily exclude open (in-use) 'Office'
                        documents (.xlsx, .docx, .ods, odt, etc.).

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

Make use of restic flags/options as follows:
  rescript [repo_name] backup [flags] -- [restic_flags/options] ...

EOF
}

function cleanup-help {
cat <<EOF
[cleanup] is for [forget] and [prune] commands in restic

This command will apply the [forget] policies set in your
configuration file and then execute [prune] to actually
delete the data that has been forgotten.

Usage:
  rescript [repo_name] cleanup [flags] [options]

Command flags:
  -a, --archive         Creates new snapshot with deleted files.
  -C, --check           Check for errors in repository.
  -i, --info            Display stats for latest and all snapshots.
  -n, --next            Display next scheduled; works only if
                        CLEANUP variable is set.
      --reset           Remove "datefile"; it resets the dates for
                        the CLEAN option in your configuration file.

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

Make use of restic flags/options as follows:
  rescript [repo_name] cleanup [flags] -- [restic_flags/options] ...

EOF
}

function changes-help {
cat <<EOF
[changes] is for [diff] command in restic

This command will automatically select the two most recent
snapshots and compare them.

Usage:
  rescript [repo_name] changes [flags] [options]

Command flags:
  -H, --host hostname   Only consider snapshots for this host.
  -m, --metadata        Print changes in metadata.
  -p, --path path       Only consider snapshots which include
                        this [absolute] path.
  -T, --tag tagname     Only consider snapshots which include this
                        taglist.

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

EOF
}

function config-help {
cat <<EOF
[config] is an interactive command to make easy the to set up rescript
configuration and exclusions files. You can create, edit, list
and open your configuration and exclusions files.

Usage:
  rescript config

Global flags:
  -h, --help            Display usage.

EOF
}

function editor-help {
cat <<EOF
[editor] is to select or change the default text editor
to be used to open the rescript configuration and
exclusion files. This will list the most common text editors
used and also have an option to write the executable name
of your favorite text editor if not listed.

Usage:
  rescript editor

Global flags:
  -h, --help            Display usage.

EOF
}

function env-help {
cat <<EOF
[env] is to display the variables values in your
configuration file.

Usage:
  rescript [repo_name] env

Command flags:
  -v, --var VARNAME     Display varname value chosen.

Global flags:
  -h, --help            Display usage.

EOF
}

function info-help {
cat <<EOF
[info] is for [stats] command in restic

This command will display restore and deduplicated (raw-data)
size of latest and all snapshots in a custom format.

Usage:
  rescript [repo_name] info [flags]

Command flags:
  -H, --host hostname   Only consider snapshots for this host.

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -t, --time            Display output with date, time and durantion.

EOF
} 

function install-help {
cat <<EOF
[install] is to simply copy the script to your PATH directory
inside your HOME. If there is no PATH in your HOME then rescript
will ask you if you want to create one. If the answer is yes then
it will create a [/bin] directory inside your [./local] directory.
If the answer is no then it will exit. If you don't want to use
rescript from your PATH then remember to use it indicating the
complete path where the script is located; if you have set another
location for your PATH then just copy the script and put it there.

Usage:
  rescript install

Global flags:
  -h, --help            Display usage.

EOF
}

function logs-help {
cat <<EOF
[logs] is for log files saved by rescript

Usage:
  rescript [repo_name] logs
OR
  rescript [repo_name] logs [flag] [logfile]

Command flags:
  -c, --cat logfile     Display output of selected log file.
  -r, --remove logfile  Remove all log files (use 'all' to remove
                        all logs related to the repository).

Global flags:
  -h, --help            Display usage.

NOTE: if you don't indicate a logfile when using [--remove]
it will delete all logfiles related to the [repo_name].

EOF
}

function mounter-help {
cat <<EOF
[mounter] is to automatically mount your repository in your HOME
directory. This will create a temporary directory where the
repository will be mounted. After you quit the [mount] process
the temporary directory will be removed.

Usage:
  rescript [repo_name] mounter

Global flags:
  -h, --help            Display usage.

Make use of restic flags/options as follows:
  rescript [repo_name] mounter -- [restic_flags/options] ...

EOF
}

function checkout-help {
cat <<EOF
[checkout] is for [check --read-data-subset RANDOM/10] in restic

This command will execute [check --read-data-subset]
selecting a random number between 1-10 out of 10 groups.

Usage:
  rescript [repo_name] checkout [flags]

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

EOF
}

function restorer-help {
cat <<EOF
[restorer] is for [restore] command in restic

This command will create a new directory in your /home/sulfuror
directory containing the restored files. The new directory will
be named with a unique name so it will not conflict with your
existing directories.

Usage:
  rescript [repo_name] restorer [flags] [host|path|snapshot ID|tag]

Command flags:
  -H, --host hostname   Only consider snapshots for this host
                        when snapshot-ID is [latest].
  -p, --path path       Only consider snapshots which include
                        this [absolute] path for snapshot-ID [latest].
  -s, --snapshot ID     Indicate snapshot-ID to restore.
  -T, --tag tagname     Only consider snapshots which include this
                        taglist for snapshot-ID [latest].

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

EOF
}

function snaps-help {
cat <<EOF
[snaps] is is for [snapshots] command in restic

This is nothing more than [snapshots --compact] in restic.
You can use any restic available flags for [snapshots] command
but it will always display snapshots in compact mode.

Usage:
  rescript [repo_name] snaps [flags] [options]

Global flags:
  -d, --debug           Debug script.
  -e, --email           Force to send email with output.
  -h, --help            Display usage.
  -l, --log             Create log file with command output.
  -q, --quiet           Silence output.
  -t, --time            Display output with date, time and durantion.

Make use of restic flags/options as follows:
  rescript [repo_name] snaps [flags] -- [restic_flags/options] ...

EOF
}

function unlocker-help {
cat <<EOF
[unlocker] is to remove the temporary lock created by rescript.
When rescript is running it will create a temporary lock file
to prevent the interruption of other processes that could be active
at the moment of executing another command within the same instance
(e.g. scheduled jobs). If you are sure there are not any other
processes running in the backgroup, then you can safely remove the
created by rescript using this command.

Usage:
  rescript [repo_name] unlocker

Global flags:
  -h, --help            Display usage.
  -q, --quiet           Silence output.

EOF
}

function update-help {
cat <<EOF
[update] is to update the rescript script itself.

Usage:
  rescript update

If script is located in /usr/bin:
  sudo rescript update

Global flags:
  -h, --help            Display usage.

EOF
}

# ============================================================== #
# Rescript Commands                                              #
# ============================================================== #
if [[ ! "$1"  ]] ; then
  echo "You need to indicate the name of your repository or a"
  echo "command; type [rescript help] for usage."
  exit
fi
case "$1" in
  archive|backup|changes|checkout|cleanup)
    if [[ "$2" ]] ; then
      case "$2" in
        -h|--help|help)
          $1-help
          exit 0
          ;;
        *)
          echo "Invalid option [$2]..."
          echo ""
          $1-help
          exit 1
          ;;
      esac
    fi
    echo "You have not indicated any repo for [$1]..."
    echo ""
    $1-help
    exit 1
    ;;
  config)
    if [[ "$2" ]] ; then
      case "$2" in
        -h|--help|help)
          config-help
          exit 0
          ;;
        *)
          echo "Invalid option [$2]..."
          echo ""
          config-help
          exit 1
          ;;
      esac
    fi
    if [[ -z "$rescript_editor" ]] ; then
      select_editor
      echo "Please type [rescript config] again to set/edit"
      echo "your configuration/exclusion files."
      exit
    fi
    clear
    main_menu
    exit
    ;;
  editor)
    if [[ "$2" ]] ; then
      case "$2" in
        -h|--help|help)
          editor-help
          exit 0
          ;;
        *)
          echo "Invalid option [$2]..."
          echo ""
          editor-help
          exit 1
          ;;
      esac
    fi
    select_editor
    exit
    ;;
  -h|--help|help)
    if [[ ! "$2" ]] ; then
      usage
      exit  
    fi
    case "$2" in
      archive|backup|changes|checkout|cleanup|config|editor|env|info|install|logs|mounter|restorer|snaps|unlocker|update)
        $2-help
        exit 1
        ;;
      *)  
        echo "You have not indicated a valid option..."
        usage | sed -ne '/Usage/,/EOF/p'
        exit 1
        ;;
    esac
    ;;
  install)
    if [[ "$2" ]] ; then
      case "$2" in
        -h|--help|help)
          install-help
          exit 0
          ;;
        *)
          echo "Invalid option [$2]..."
          echo ""
          install-help
          exit 1
          ;;
      esac
    fi
    clear
    install
    exit
    ;;
  logs)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    logs-help
    exit
    ;;
  mounter)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    mounter-help
    exit
    ;;
  restorer)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    restorer-help
    exit
    ;;
  snaps)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    snaps-help
    exit
    ;;
  unlocker)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    unlocker-help
    exit
    ;;
  update)
    if [[ "$2" ]] ; then
      case "$2" in
        -h|--help|help)
          update-help
          exit 0
          ;;
        *)
          echo "Invalid option [$2]..."
          echo ""
          update-help
          exit 1
          ;;
      esac
    fi
    update
    exit
    ;;
  -v|--version|version)
    usage | sed -ne '/Name/,/Version/p'
    echo ""
    echo -e 'Redistribution and use in source and binary forms, with or without \nmodification, are permitted provided that the BSD 2-Clause License \nconditions are met.'
    exit
    ;;
  *)
    if [[ ! -e "$config_dir/$1.conf" && ! -e "$config_dir/$1.conf.gpg" ]] ; then
      echo "There is no repo or command for [$1]. Indicate a valid"
      echo "repo name or command to proceed. Use [rescript help] for usage."
      exit
    fi
    ;;
esac

# ============================================================== #
# Functions                                                      #
# ============================================================== #
source "$config_file"
export RESTIC_REPOSITORY="$RESTIC_REPO"
export B2_ACCOUNT_ID="$B2_ID"
export B2_ACCOUNT_KEY="$B2_KEY"
export AWS_ACCESS_KEY_ID="$AWS_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_KEY"
export AZURE_ACCOUNT_NAME="$AZURE_NAME"
export AZURE_ACCOUNT_KEY="$AZURE_KEY"
export GOOGLE_PROJECT_ID="$GOOGLE_ID"
export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_CREDENTIALS"
if [[ "$RESCRIPT_PASS" ]] ; then
  export RESTIC_PASSWORD="$RESCRIPT_PASS"
else
  export RESTIC_PASSWORD="$RESTIC_PASSWORD"
fi
SECONDS=0

case "$2" in
  init) restic init ; exit 0 ;;
esac

case "$RESTIC_REPO" in
  sftp*) ping_target=${RESTIC_REPO#sftp*@} ; ping_target=${ping_target%:*} ; ping -c 1 "$ping_target" > /dev/null ; ping_code="$?" ;;
  rclone*) ping_target=${RESTIC_REPO#rclone:} ; rclone about "$ping_target" > /dev/null ; ping_code="$?" ;;
  /*) dir "$RESTIC_REPO" 2>/dev/null 1>/dev/null ; ping_code="$?" ;;
esac

if [[ "$ping_code" -gt "0" ]] ; then
  error_message="Cannot access to: $RESTIC_REPO \nPlease check your connection. If your repository is not \ninitializated run [rescript $repo init]."
  report_errors
  exit "$ping_code"
fi

if [[ -n "$DESTINATION" ]] ; then
  dest=$DESTINATION
else
  dest=$RESTIC_REPO
fi

if [[ -n "$HOST" ]] ; then
  rhost="$HOST"
else
  rhost=$(hostname)
fi

declare -a policies

# Set variables for functions
if [[ -n "$KEEP_LAST" && "$KEEP_LAST" -gt "0" ]] ; then
  policies+=(--keep-last $KEEP_LAST)
fi
if [[ -n "$KEEP_HOURLY" && "$KEEP_HOURLY" -gt "0" ]] ; then
  policies+=(--keep-hourly $KEEP_HOURLY)
fi
if [[ -n "$KEEP_DAILY" && "$KEEP_DAILY" -gt "0" ]] ; then
  policies+=(--keep-daily $KEEP_DAILY)
fi
if [[ -n "$KEEP_WEEKLY" && "$KEEP_WEEKLY" -gt "0" ]] ; then
  policies+=(--keep-weekly $KEEP_WEEKLY)
fi
if [[ -n "$KEEP_MONTHLY" && "$KEEP_MONTHLY" -gt "0" ]] ; then
  policies+=(--keep-monthly $KEEP_MONTHLY)
fi
if [[ -n "$KEEP_YEARLY" && "$KEEP_YEARLY" -gt "0" ]] ; then
  policies+=(--keep-yearly $KEEP_YEARLY)
fi
if [[ -n "$KEEP_WITHIN" ]] ; then
  policies+=(--keep-within $KEEP_WITHIN)
fi
if [[ -n "$KEEP_TAG" ]] ; then
  policies+=(--keep-tag $KEEP_TAG)
fi
if [[ "$KEEP_ARCHIVE" = "yes" ]] ; then
  policies+=(--keep-tag archive)
fi

# Archive directories
archiver="$tmp_dir/archive"
archiver_latest="$tmp_dir/archive_latest"
archiver_old="$tmp_dir/archive_old"

function archive {
  if [[ ! $(command -v rsync) ]] ; then
    echo "***$(basename "$0") warning***"
    echo "[rsync] not found..."
    echo ""
    echo "[$cmd] works with [rsync] to merge data into one directory."
    echo "Please, install [rsync] to proceed."
    exit
  fi
  if [[ "$cmd" != "archive" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ -n "$host_flag" ]] ; then
    host_archive="$host_flag"
  else
    host_archive="$rhost"
  fi
  if [[ "$cmd" = "archive" ]] ; then
    logger
    time_start
  fi
  debug_start
  echo "Starting archive..."
  echo -ne 'Retrieving snapshots data     : [#######-------------](33%)\r'
  check_snapshots=$(restic snapshots --compact --host "$host_archive")
  latest_cmd=$prev_cmd exit_code="$?"
  echo -ne 'Retrieving snapshots data     : [##############------](66%)\r'
  check_archives=$(restic snapshots --compact --host "$host_archive" --tag "archive" --path "/tmp/archive")
  latest_cmd=$prev_cmd exit_code="$?"
  echo -ne 'Retrieving snapshots data     : [####################](100%)\r'
  echo -ne '\n'
  if [[ ! "$(echo "$check_snapshots" | tail -1 | awk '{print $1}')" ]] ; then
    echo "There is no host named [$host_archive] in your repository."
    exit 1
  elif [[ "$(echo "$check_snapshots" | tail -1 | awk '{print $1}')" -lt "2" ]] ; then
    echo "There is only $(echo "$check_snapshots" | tail -1 | awk '{print $1}') snapshot available... unable to proceed."
    echo "Listing snapshots..."
    echo "$check_snapshots"
    debug_stop
    if [[ "$info_flag" = "true" && "$cmd" = "archive" ]] ; then
      statinfo
    fi
    if [[ "$cmd" = "archive" ]] ; then
      time_end
    fi
    exit 0
  elif [[ "$(echo "$check_snapshots" | tail -1 | awk '{print $1}')" = "2" && "$(echo "$check_archives" | tail -1 | awk '{print $1}')" -gt "0" ]] ; then
    echo "There are no files to archive..."
    debug_stop
    if [[ "$info_flag" = "true" && "$cmd" = "archive" ]] ; then
      statinfo
    fi
    if [[ "$cmd" = "archive" ]] ; then
      time_end
    fi
    exit 0
  fi
  echo -ne 'Checking for files to archive : [#####---------------](25%)\r'
  prevsnap=$(echo "$check_snapshots" | tail -4 | head -1 | awk '{print $1}')
  echo -ne 'Checking for files to archive : [##########----------](50%)\r'
  latesnap=$(echo "$check_snapshots" | tail -3 | head -1 | awk '{print $1}')
  echo -ne 'Checking for files to archive : [###############-----](75%)\r'
  rescript_archive=$(restic diff "$prevsnap" "$latesnap" | grep -e '-    /' | sed -e 's/^-    //g')
  latest_cmd=$prev_cmd exit_code="$?"
  if [[ "$exit_code" -gt "0" ]] ; then
    latest_error
  fi
  echo -ne 'Checking for files to archive : [####################](100%)\r'
  echo -ne '\n'
  wait
  if [[ -z "$rescript_archive" ]] ; then
    echo "There are no files to archive..."
    debug_stop
    if [[ "$info_flag" = "true" && "$cmd" = "archive" ]] ; then
      statinfo
    fi
    if [[ "$cmd" = "archive" ]] ; then
      time_end
    fi
  else
    if [[ "$(echo "$rescript_archive" | grep -c "/")" = "1" ]] ; then
      echo "There is $(echo "$rescript_archive" | grep -c "/") file deleted from the latest snapshot:"
    else
      echo "There are $(echo "$rescript_archive" | grep -c "/") files deleted from the latest snapshot:"
    fi
    cat -n <(echo "$rescript_archive")
    echo -ne 'Restoring deleted files       : [####----------------](20%)\r'
    eval "filter=( $(echo "$rescript_archive" | sed 's/^/--include="/' | sed 's/$/"/') )"
    wait
    restic restore "${filter[@]}" --verify "$prevsnap" -t "$archiver_latest" >> /dev/null 2>&1 &
    latest_cmd=$prev_cmd exit_code="$?"
      if [[ "$exit_code" -gt "0" ]] ; then
        archive_cleanup
        latest_error
      fi
    wait
    echo -ne 'Restoring deleted files       : [########------------](40%)\r'
    if [[ "$(echo "$check_archives" | tail -1 | awk '{print $1}')" -gt "0" ]] ; then
      restic restore --host "$host_archive" --tag "archive" --path "$tmp_dir/archive" --verify latest -t "$archiver_old" >> /dev/null 2>&1
      latest_cmd=$prev_cmd exit_code="$?"
      if [[ "$exit_code" -gt "0" ]] ; then
        archive_cleanup
        latest_error
      fi
    fi
    wait
    echo -ne 'Restoring deleted files       : [############--------](60%)\r'
    restic forget --host "$host_archive" --tag "archive" --path "$tmp_dir/archive" --keep-last="1" >> /dev/null 2>&1
    latest_cmd=$prev_cmd exit_code="$?"
    if [[ "$exit_code" -gt "0" ]] ; then
      archive_cleanup
      latest_error
    fi
    wait
    echo -ne 'Restoring deleted files       : [################----](80%)\r'
    restic forget --host "$host_archive" --tag "archive" --path "$tmp_dir/archive" latest >> /dev/null 2>&1
    latest_cmd=$prev_cmd exit_code="$?"
    if [[ "$exit_code" -gt "0" ]] ; then
      archive_cleanup
      latest_error
    fi
    wait
    echo -ne 'Restoring deleted files       : [####################](100%)\r'
    echo -ne '\n'
    if [[ -d "$archiver_old" ]] ; then
      echo -ne 'Merging data                  : [#######-------------](33%)\r'
      rsync -a $archiver_old/tmp/archive/* $archiver >> /dev/null 2>&1
      latest_cmd=$prev_cmd exit_code="$?"
      if [[ "$exit_code" -gt "0" ]] ; then
        archive_cleanup
        latest_error
      fi
      wait
      echo -ne 'Merging data                  : [##############------](33%)\r'
      rsync -a $archiver_latest/* $archiver >> /dev/null 2>&1
      latest_cmd=$prev_cmd exit_code="$?"
      if [[ "$exit_code" -gt "0" ]] ; then
        archive_cleanup
        latest_error
      fi
      wait
      echo -ne 'Merging data                  : [####################](100%)\r'
      echo -ne '\n'
    else
      echo -ne 'Merging data                  : [##########----------](50%)\r'
      rsync -a $archiver_latest/* $archiver >> /dev/null 2>&1
      latest_cmd=$prev_cmd exit_code="$?"
      if [[ "$exit_code" -gt "0" ]] ; then
        archive_cleanup
        latest_error
      fi
      wait
      echo -ne 'Merging data                  : [####################](100%)\r'
      echo -ne '\n'
    fi
    echo -ne 'Archiving deleted files       : [##########----------](50%)\r'
    restic backup --time "2015-$(date +%m-%d) $(date +%H:%M:%S)" --tag archive --host "$host_archive" "$archiver" >> /dev/null 2>&1
    latest_cmd=$prev_cmd exit_code="$?"
    if [[ "$exit_code" -gt "0" ]] ; then
      archive_cleanup
      latest_error
    fi
    wait
    echo -ne 'Archiving deleted files       : [####################](100%)\r'
    echo -ne '\nArchive Completed!\n'
    debug_stop
    archive_cleanup
    if [[ "$info_flag" = "true" && "$cmd" = "archive" ]] ; then
      statinfo
    fi
    if [[ "$cmd" = "archive" ]] ; then
      time_end
    fi
  fi
}

function archive_cleanup {
  if [[ -d "$archiver" ]] ; then
    rm -rf "${archiver:?}"
  fi
  if [[ -d "$archiver_latest" ]] ; then
    rm -rf "${archiver_latest:?}"
  fi
  if [[ -d "$archiver_old" ]] ; then
    rm -rf "${archiver_old:?}"
  fi
}

function automatic {
  rescript_lock
  case "$LOGGING" in
    y|yes)
      log_flag="true"
      ;;
  esac
  logger
  time_flag="true"
  time_start
  # Backup
  case "$SKIP_OFFICE" in
    y|yes)
      echo -e "$yellow""[Taking a Snapshot...]""$endcolor" ; skip_flag="true" ; backup ;;
    *)
      echo -e "$yellow""[Taking a Snapshot...]""$endcolor" ; backup ;;
  esac
  exclusions=$(grep -E -v -n -c '(^#|^\s*$|^\s*\t*#)' "$excludes")
  if [[ "$exclusions" -gt "0" ]] ; then
    echo -e "$yellow""There are $exclusions exclusion rules...""$endcolor"
  fi
  printf "%${cols}s\n" "" | tr ' ' -
  # Snapshot List
  echo -e "$yellow""[Snapshots List...]""$endcolor"
  snaps
  printf "%${cols}s\n" "" | tr ' ' -
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  case "$ARCHIVE" in
    y|yes) echo -e "$yellow""[Starting archive...]""$endcolor" ; archive ; printf "%${cols}s\n" "" | tr ' ' - ;;
  esac
  # Check and Clean Repo Based on User's Policy
  if [[ -f "$config_dir/$repo-datefile" || -n "$CLEAN" ]]; then
    if [[ ! -f "$config_dir/$repo-datefile" ]] ; then
      touch "$config_dir/$repo-datefile"
    fi
    now_next
    if [[ "$now" -lt "$next" ]] ; then
      cleanup-next
    else 
      if [[ -n "${policies[*]}" ]] ; then
        echo -e "$yellow""[Cleaning Repo...]""$endcolor"
        cleanup
        printf "%${cols}s\n" "" | tr ' ' -
        echo -e "$yellow""[Checking for Errors in Repo...]""$endcolor"
        restic check --cleanup-cache
        latest_cmd=$prev_cmd exit_code="$?"
        latest_error
        printf "%${cols}s\n" "" | tr ' ' -
        if [[ -n "$CLEAN" ]] ; then
          case "$unix_name" in
            Linux|GNU)
              date -d now+"$CLEAN" 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
            *)
              gdate -d now+"$CLEAN" 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
          esac
          exit_code="$?"
          if [[ "$exit_code" -gt "0" ]] ; then
            echo -e "$yellow""WARNING: \nCLEAN is set to $CLEAN in your configuration file; please use the correct syntax as follows:"$endcolor" \n1. CLEAN=""$CLEAN"days"     <---setup cleanup every $CLEAN days\n2. CLEAN=""$CLEAN"hours"    <---setup cleanup every $CLEAN hours\n3. CLEAN=""$CLEAN"minutes"  <---setup cleanup every $CLEAN minutes"
          else
            echo -e "$yellow""[Done Cleaning; Next Cleanup and Check Will Be Done in $(echo "$CLEAN" | sed 's/[a-z]//g') $(echo "$CLEAN" | sed 's/[0-9]//g')...]""$endcolor"
          fi
        fi
      fi
    fi
  else 
      if [[ -n "${policies[*]}" ]] ; then
        echo -e "$yellow""[Cleaning Repo...]""$endcolor"
        cleanup
        printf "%${cols}s\n" "" | tr ' ' -
        echo -e "$yellow""[Checking for Errors in Repo...]""$endcolor"
        restic check --cleanup-cache
        latest_cmd=$prev_cmd exit_code="$?"
        latest_error
      fi
  fi
  # Stats
  statinfo
  # Time and Runtime
  time_end
  if [[ -n "$CLEAN" && -z "${policies[*]}" ]] ; then
    echo "[rescript] noted that your CLEAN variable is $CLEAN, so [rescript] assumes that"
    echo "you want to perform a 'cleanup' (forget, prune and check) every $(echo "$CLEAN" | sed 's/[a-z]//g') $(echo "$CLEAN" | sed 's/[0-9]//g') but"
    echo "it can't execute it if you have not set the KEEP variables; please set your"
    echo "desired KEEP values in order to perform the 'cleanup' every $(echo "$CLEAN" | sed 's/[a-z]//g') $(echo "$CLEAN" | sed 's/[0-9]//g'). If you"
    echo "don't want [rescript] to 'cleanup' your repo automatically every $(echo "$CLEAN" | sed 's/[a-z]//g') $(echo "$CLEAN" | sed 's/[0-9]//g'),"
    echo "just leave the CLEAN variable blank in your cofiguration file and this"
    echo "message will not appear again."
    echo ""
    echo "For more info about this subject:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
  fi
}

function backup {
  declare -a bu_opts
  if [[ "$EXCLUDE_CACHE" = "yes" || "$EXCLUDE_CACHE" = "y" || -z "$EXCLUDE_CACHE" ]] ; then
    bu_opts+=( --exclude-caches )
  fi
  if [[ "$EXCLUDE_FILE" = "yes" || "$EXCLUDE_FILE" = "y" || -z "$EXCLUDE_FILE" ]] ; then
    bu_opts+=( --exclude-file="$excludes" )
  fi
  if [[ "$ONE_FILE_SYSTEM" = "yes" || "$ONE_FILE_SYSTEM" = "y" ]] ; then
    bu_opts+=( --one-file-system )
  fi
  if [[ -n "$HOST" ]] ; then
    bu_opts+=( --host="$HOST" )
  fi
  if [[ -n "$TAG" ]] ; then
    bu_opts+=( --tag="$TAG" )
  fi
  if [[ "$cmd" != "backup" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ "$cmd" = "backup" ]] ; then
    logger
    time_start
  fi
  debug_start
  if [[ "$skip_flag" = "true" ]] ; then
    restic backup --verbose ${bu_opts[@]} --exclude-file=<(find $BACKUP_DIR -iname ".~lock.*" 2> /dev/null | sed -e 's/.~lock.//g' | sed -e 's/#//g') --exclude=".~lock.*" ${rest[@]} $BACKUP_DIR
  else
    restic backup --verbose ${bu_opts[@]} ${rest[@]} $BACKUP_DIR
  fi
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  if [[ "$archive_flag" = "true" ]] ; then
    archive
  fi
  if [[ "$cleanup_flag" = "true" ]] ; then
    echo "Starting cleanup..."
    cleanup
  fi
  if [[ "$check_flag" = "true" && "$cmd" = "backup" ]] ; then
    echo "Starting check..."
    restic check
  fi
  if [[ "$info_flag" = "true" && "$cmd" = "backup" ]] ; then
    statinfo
  fi
  if [[ "$cmd" = "backup" ]] ; then
    time_end
  fi
}


function statinfo {
  if [[ "$cmd" != "info" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  if [[ "$cmd" = "info" ]] ; then
    logger
    time_start
  fi
  if [[ -n "$host_flag" ]] ; then
    rhost="$host_flag"
  fi
  if [[ "$cmd" != "info" ]] ; then
    printf "%${cols}s\n" "" | tr ' ' -
  fi
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  debug_start
  echo -ne 'Processing stats              : [####----------------](20%)\r'
  latest_host_stat=$(restic stats --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  echo -ne 'Processing stats              : [########------------](40%)\r'
  host_stat=$(restic stats --mode raw-data --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  echo -ne 'Processing stats              : [############--------](60%)\r'
  stat_restore_size=$(restic stats | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  echo -ne 'Processing stats              : [################----](80%)\r'
  stat_raw_data=$(restic stats --mode raw-data | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  debug_stop
  echo -ne 'Processing stats              : [####################](100%)\r'
  printf "%-$((cols/4))s %$((cols/3))s %$((cols/3))s\n" "Summarized Info" "Restore Size" "Deduplicated Size"
  printf "%${cols}s\n" "" | tr ' ' -
  printf "%-$((cols/4))s %$((cols/3))s %$((cols/3))s\n" "Latest Snapshot" "$latest_host_stat" "$host_stat"
  printf "%-$((cols/4))s %$((cols/3))s %$((cols/3))s\n" "All Snapshots" "$stat_restore_size" "$stat_raw_data"
  if [[ "$cmd" = "info" ]] ; then
    time_end
  fi
}

function changes {
  if [[ "$cmd" != "changes" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ "$cmd" = "changes" ]] ; then
    logger
    time_start
  fi
  if [[ -n "$path_flag" ]] ; then
    path="--path $path_flag"
  fi
  if [[ -n "$tag_flag" ]] ; then
    tag="--tag $tag_flag"
  fi
  if [[ -n "$host_flag" ]] ; then
    host="--host $host_flag"
  else
    host="--host $rhost"
  fi
  opts=(
    $path
    $tag
    $host
  )
  if [[ "$metadata_flag" = "true" ]] ; then
    add_meta="--metadata"
  fi
  echo -ne 'Retrieving snapshots          : [##########----------](50%)\r'
  debug_start
  snapshots=$(restic snapshots --compact ${opts[@]})
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  previous_snapshot=$(echo "$snapshots" | tail -4 | head -1 | awk '{print $1}')
  latest_snapshot=$(echo "$snapshots" | tail -3 | head -1 | awk '{print $1}')
  echo -ne 'Retrieving snapshots          : [####################](100%)\r'
  echo -ne '\n'
  if [[ -z "$previous_snapshot" || -z "$latest_snapshot" ]] ; then
    echo "It seems the repository does not have snapshots to compare with; if any option was indicated, please check if the hostname, tagname or path were misspelled."
    time_end
    exit 1
  fi
  debug_start
  restic diff "$previous_snapshot" "$latest_snapshot" $add_meta
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  time_end
}

function cleanup {
  if [[ "$cmd" != "cleanup" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ "$cmd" = "cleanup" ]] ; then
    logger
    time_start
  fi
  if [[ "$cmd" = "cleanup" && "$archive_flag" = "true" ]] ; then
    archive
  fi
  if [[ -n "${policies[*]}" ]] ; then
    debug_start
    restic forget "${policies[@]}" ${rest[@]}
    latest_cmd=$prev_cmd exit_code="$?"
    debug_stop
    latest_error
    debug_start
    restic prune --cleanup-cache
    latest_cmd=$prev_cmd exit_code="$?"
    debug_stop
    latest_error
    if [[ -f "$config_dir/$repo-datefile" || -n "$CLEAN" ]] ; then
      if [[ "$cmd" = "cleanup" ]] ; then
        cleanup-next
      fi
    fi
  else
    echo -e "$yellow""You have not indicated any policy value...""$endcolor"
    echo "If you want to use [cleanup] option you need to set the [KEEP] variables."
    echo "For more information about the Usage check out the following link:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
  fi
  if [[ "$check_flag" = "true" && "$cmd" = "cleanup" ]] ; then
    echo "Starting check..."
    restic check
  fi
  if [[ "$info_flag" = "true"  && "$cmd" = "cleanup" ]] ; then
    statinfo
  fi
  if [[ "$cmd" = "cleanup" ]] ; then
    time_end
  fi
}

function cleanup-next {
  if [[ ! -f "$config_dir/$repo-datefile" ]] ; then
    touch "$config_dir/$repo-datefile"
  fi
  now_next
  result=$((next-now))
  days=$((result / 86400))
  hours=$(((result / 3600) % 24))
  minutes=$(((result / 60) % 60))
  if [[ "$days" = "1" ]] ; then
    d="day"
  else
    d="days"
  fi
  if [[ "$hours" = "1" ]] ; then
    h="hour"
  else
    h="hours"
  fi
  if [[ "$minutes" = "1" ]] ; then
    m="minute"
  else
    m="minutes"
  fi
  if [[ "$days" -gt "0" ]] ; then
    if [[ "$hours" -gt "0" ]] ; then
        if [[ "$minutes" -gt "0" ]] ; then
          echo -e "$yellow""Next cleanup and check in $days $d, $hours $h and $minutes $m...""$endcolor"
        else
          echo -e "$yellow""Next cleanup and check in $days $d and $hours $h...""$endcolor"
        fi
    elif [[ "$minutes" -gt "0" ]] ; then
      echo -e "$yellow""Next cleanup and check in $days $d and $minutes $m...""$endcolor"
    else
      echo -e "$yellow""Next cleanup and check in $days $d...""$endcolor"
    fi
  elif [[ "$hours" -gt "0" ]] ; then
    if [[ "$minutes" -gt "0" ]] ; then
      echo -e "$yellow""Next cleanup and check in $hours $h and $minutes $m...""$endcolor"
    else
      echo -e "$yellow""Next cleanup and check in $hours $h...""$endcolor"
    fi
  elif [[ "$minutes" -gt "0" ]] ; then
    echo -e "$yellow""Next cleanup and check in $minutes $m...""$endcolor"
  else
    echo -e "$yellow""Repo will be cleaned and checked in the next run...""$endcolor"
  fi
}

function debug_start {
  if [[ "$debug_flag" = "true" ]] ; then
    set -xv
  fi
}

function debug_stop {
  if [[ "$debug_flag" = "true" ]] ; then
    set +xv
  fi
}

function env_conf {
  if [[ "$var_flag" ]] ; then
    upper_var=$(echo "$var_flag" | tr '[:lower:]' '[:upper:]')
    search=$(sed '/^#/ d' < "$config_dir/$repo.conf" | sed '/^\s*$/d' | grep "$upper_var")
    if [[ -z "$search" ]] ; then
      echo "There is no var named [$var_flag]..."
      echo ""
      env-help
      exit 1
    else
      echo "$search"
    fi
  else
    sed '/^#/ d' < "$config_dir/$repo.conf" | sed '/^\s*$/d'
  fi
}

function logs {
  if [[ "$catlogs" = "false" && "$removelogs" = "false" ]] ; then
    if ls "$logs_dir/$repo"-* 1> /dev/null 2>&1 ; then
      ls $logs_dir/ | grep -e "$repo"
      echo ""
      echo "Your logs are saved at $logs_dir"
      exit 0
    else
      echo "There are no log files to list for [$repo]."
      exit 0
    fi
  elif [[ "$catlogs" = "true" && "$removelogs" = "true" ]] ; then
    echo "You cannot use '--cat' and '--remove' at the same time"
    echo ""
    logs-help
    exit 1
  fi
  if [[ "$catlogs" = "true" ]] ; then
    cat "$logs_dir/$logfile"
  elif [[ "$removelogs" = "true" ]] ; then
    if [[ "$logfile" = "all" ]] ; then
      if ls "$logs_dir/$repo"-* 1> /dev/null 2>&1 ; then
        rm -rfv "${logs_dir:?}/$repo"-*
        echo "Log files removed for [$repo]."
        exit 0
      else
        echo "There are no log files to remove for [$repo]."
        exit 0
      fi
    else
      if ls "$logs_dir/$logfile" 1> /dev/null 2>&1 ; then
        rm -rfv "${logs_dir:?}/$logfile"
        echo "[$logfile] removed."
        exit 0
      else
        echo "There are is log file called [$logfile]."
        exit 1
      fi
    fi
  else
    echo "Something is not right."
    exit 1
  fi
}

function logger {
  if [[ "$log_flag" = "true" ]] ; then
    if [[ ! "$cmd" ]] ; then
      log="$logs_dir/$repo-log-$(date +%Y-%m-%d-%H:%M).log"
    else
      log="$logs_dir/$repo-$cmd-log-$(date +%Y-%m-%d-%H:%M).log"
    fi
    exec > >(tee -a "$log") 2>&1
  else
    exec > >(tee -a "$tmplog") 2>&1
  fi
}

function mounter {
  rescript_lock
  rmount="$HOME/$repo-repo-$(date +%s)"
  mkdir "$rmount"
  restic mount ${rest[@]} "$rmount"
  rm -rf "$rmount"
}

function non_opt {
  case "$cmd" in
  archive|backup|changes|checkout|cleanup|env|info|logs|mounter|restorer|snaps|unlocker)
    echo ""
    $cmd-help
    exit 1
    ;;
  *)
    echo ""
    usage | sed -ne '/Usage/,/EOF/p'
    exit 1
    ;;
  esac
}

function now_next {
  case "$unix_name" in
    Linux|GNU)
      now=$(date +"%s")
      next=$(date -f "$config_dir/$repo-datefile" "+%s")
      ;;
    *)
      now=$(gdate +"%s")
      next=$(gdate -f "$config_dir/$repo-datefile" "+%s")
      ;;
  esac
}

function random-check {
  rescript_lock
  if [[ "$cmd" = "checkout" ]] ; then
    logger
    time_start
  fi
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  debug_start
  restic check --read-data-subset $((RANDOM % 10 + 1))/10
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  if [[ "$cmd" = "checkout" ]] ; then
    time_end
  fi
}

function rescript_lock {
  if [ -e "$lock" ]; then
    logger
    echo "WARNING: [$repo] repo is already running..."
    echo "If you are sure $repo is not running, type"
    echo " "
    echo "  rescript $repo unlocker"
    echo " "
    echo "This will remove the lock for [$repo] repository."
    echo ""
    echo "Lock file info:"
    stat "$lock_dir/$repo.lock"
    latest_cmd="$cmd"
    exit_code="1"
    latest_error
  else
    touch "$lock"
    trap 'rm -rf "${lock:?}" ; rm -rf "${tmplog:?}"' INT QUIT TERM EXIT
  fi
}

function restic_alone {
  rescript_lock
  logger
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  time_start
  debug_start
  restic ${rest[@]}
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  rest_cmd=$(echo "${rest[@]}" | awk '{print $1}')
  case "$rest_cmd" in
    --repo=*) rest_cmd=$(echo "${rest[@]}" | awk '{print $2}') ;;
    -r*|--repo*) rest_cmd=$(echo "${rest[@]}" | awk '{print $3}') ;;
  esac
  latest_error
  time_end
}

function restorer {
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ "$host_flag" ]] ; then
    restore_dir="$HOME/restore-latest-host-"$host_flag"_$(date +%s)"
    restore_opts="--host $host_flag"
  elif [[ "$path_flag" ]] ; then
    restore_dir="$HOME/restore-latest-by-path_$(date +%s)"
    restore_opts="--path $path_flag"
  elif [[ "$tag_flag" ]] ; then
    restore_dir="$HOME/restore-latest-tag-"$tag_flag"_$(date +%s)"
    restore_opts="--tag $tag_flag"
  else
    restore_dir="$HOME/restore-ID-"$snap_flag"_$(date +%s)"
    snap_id="$snap_flag"
  fi
  if [[ "$cmd" = "restorer" ]] ; then
    logger
    time_start
  fi
  echo -e "$yellow""Restoring from:""$endcolor" "$dest..."
  if [[ "$snap_id" ]] ; then
    debug_start
    restic restore $snap_id --target $restore_dir --verify
    latest_cmd=$prev_cmd exit_code="$?"
    debug_stop
    latest_error
  else
    debug_start
    restic restore latest --target $restore_dir $restore_opts --verify
    latest_cmd=$prev_cmd exit_code="$?"
    debug_stop
    latest_error
  fi
  report_errors
  if [[ "$cmd" = "restorer" ]] ; then
    time_end
  fi
}

function snaps {
  if [[ "$cmd" != "snaps" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
  if [[ "$cmd" = "snaps" ]] ; then
    logger
    time_start
  fi
  debug_start
  restic snapshots --compact ${rest[@]}
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  if [[ "$cmd" = "snaps" ]] ; then
    time_end
  fi
}

function time_start {
  if [[ ! "$cmd" ]] ; then
    title="STARTING SCRIPT"
  else
    title="starting $cmd"
  fi
  if [[ "$time_flag" = "true" ]] ; then
    printf "%${cols}s\n" "" | tr ' ' =
    printf "%$(((cols + ${#title}) / 2))s\n" "$title" | tr '[:lower:]' '[:upper:]'
    printf "%${cols}s\n" "" | tr ' ' =
    echo -e "$yellow""Date and Time:""$endcolor" "$(date +%a\ %b\ %d\ %Y\ %r)"
    echo -e "$yellow""System:""$endcolor" "$(opsys)"
    echo -e "$yellow""Hostname:""$endcolor" "$rhost"
    echo -e "$yellow""Repository Location:""$endcolor" "$dest"
    echo -e "$yellow""Restic Version:""$endcolor" "$(restic version | awk '{print $2}')"
    printf "%${cols}s\n" "" | tr ' ' -
  fi
}

function time_end {
  if [[ ! "$cmd" ]] ; then
    footer="SCRIPT ENDED"
  else
    footer="$cmd ended"
  fi
  if [[ "$time_flag" = "true" ]] ; then
    printf "%${cols}s\n" "" | tr ' ' -
    echo -e "$yellow""End:""$endcolor" "$(date +%a\ %b\ %d\ %Y\ %r)"
    echo -e "$yellow""Duration:""$endcolor" "$(duration)"
    printf "%${cols}s\n" "" | tr ' ' =
    printf "%$(((${cols} + ${#footer}) / 2))s\n" "$footer" | tr '[:lower:]' '[:upper:]'
    printf "%${cols}s\n" "" | tr ' ' =
  fi
}

function unlocker {
  if [[ ! -e "$lock" ]]; then
    echo "No locks found..."
  else
    rm -rf "${lock:?}"
    echo "Script unlocked..."
  fi
}

# ============================================================== #
# Call Commands and Functions Related to a Repository            #
# ============================================================== #
if [[ ! $(command -v restic) ]] ; then
  echo "***$(basename $0) warning***"
  echo "[restic] not found..."
  echo ""
  echo "This script is made to work with [restic]. Please, install"
  echo "[restic] package to proceed. If you have [restic] binary"
  echo "saved in some custom directory, move it to '/usr/bin' or"
  echo "to your PATH so this script can recognize it. If you need"
  echo "to install [restic] and you are using Debian or some Debian"
  echo "based distribution like Ubuntu, you can add the [rescript]"
  echo "PPA with the following commands:"
  echo ""
  echo "  sudo add-apt-repository ppa:sulfuror/restic-tools"
  echo "  sudo apt update"
  echo "  sudo apt install restic"
  echo ""
  echo "You can also download the standalone binary in the [restic]"
  echo "release page: https://github.com/restic/restic/releases"
  exit
fi
if [[ ! "$2" ]] ; then
  automatic
  job_done
  exit 0
fi
case "$unix_name" in
  Darwin)
    if [[ -d "/usr/local/opt/gnu-getopt/bin" ]] ; then
      getopt="/usr/local/opt/gnu-getopt/bin/getopt"
    else
      getopt=$(command -v getopt)
    fi
    output="/dev/stdout" ;;
  Linux) 
    if [[ "$(uname -o)" = "Android" ]] ; then
      output="/proc/self/fd/1"
    else
      output="/dev/stdout"
    fi
    getopt=$(command -v getopt) ;;
  *) getopt=$(command -v getopt) ; output="/dev/stdout" ;;
esac
cmd="$2"
options=( "${@:3}" )
archive_flag="false"
check_flag="false"
cleanup_flag="false"
debug_flag="false"
info_flag="false"
log_flag="false"
metadata_flag="false"
skip_flag="false"
time_flag="false"
catlogs="false"
removelogs="false"
case "$cmd" in
  archive) short_opts="dehH:ilqt" ; long_opts="debug,email,help,host:,info,log,quiet,time" ;;
  backup) short_opts="acCdeDhilqtS" ; long_opts="archive,check,cleanup,debug,email,dry-run,help,info,log,quiet,skip-office,time" ;;
  changes) short_opts="dehH:lmp:qT:t" ; long_opts="debug,email,help,host:,log,metadata,path:,quiet,tag:,time" ;;
  checkout) short_opts="dehlqt" ; long_opts="debug,email,help,log,quiet,time" ;;
  cleanup) short_opts="aCdehilnqt" ; long_opts="archive,check,debug,email,help,info,log,next,quiet,reset,time" ;;
  env) short_opts="hv:" ; long_opts="help,var:" ;;
  info) short_opts="dehH:lt" ; long_opts="debug,email,help,host:,log,time" ;;
  logs) short_opts="c:hr:" ; long_opts="cat:,help,remove:" ;;
  mounter) short_opts="h" ; long_opts="help" ;;
  restorer) short_opts="delhH:p:qs:T:t" ; long_opts="debug,email,help,host:,log,path:,quiet,snapshot:,tag:,time" ;;
  snaps) short_opts="dehlqt" ; long_opts="debug,email,help,log,quiet,time" ;;
  unlocker) short_opts="hq" ; long_opts="help,quiet" ;;
esac
case "$cmd" in
  archive|backup|changes|checkout|cleanup|env|info|logs|mounter|restorer|snaps|unlocker)
  case "$unix_name" in
    Darwin)
      if [[ -d "/usr/local/opt/gnu-getopt/bin" ]] ; then
        get_opt=$($getopt -o $short_opts -l $long_opts -n "$(basename $0)" -- ${options[@]}) || non_opt
      else
        get_opt=$($getopt $short_opts "${options[@]}") || non_opt
      fi
      ;;
    FreeBSD|NetBSD|OpenBSD) get_opt=$($getopt $short_opts ${options[@]}) || non_opt ;;
    *) get_opt=$($getopt -o $short_opts -l $long_opts -n "$(basename $0)" -- ${options[@]}) || non_opt ;;
  esac
esac
exec 6>&1
case "$cmd" in
  archive)
    shopt -u nocasematch
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help ) $cmd-help ; exit 0 ;;
        -H|--host) shift ; host_flag="$1" ; shift ;;
        -i|--info) shift ; info_flag="true" ;;
        -l|--log) shift ; log_flag="true" ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ;  break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    archive > $output
    ;;
  backup)
    shopt -u nocasematch
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -a|--archive) shift ; archive_flag="true" ;;
        -C|--check) shift ; check_flag="true" ;;
        -c|--cleanup) shift ; cleanup_flag="true" ;;
        -d|--debug) shift ; debug_flag="true" ;;
        -D|--dry-run)
          shift
          trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG
          echo 'This is a "dry-run" to display files and total size that would be added to'
          echo 'your repository. This actually does nothing in your repository. Size'
          echo 'displayed here and actual size once the data is in the repository'
          echo 'may vary due to restic deduplication.'
          echo ''
          du -hc $BACKUP_DIR --exclude-from="$excludes" 2> /dev/null
          latest_cmd=$prev_cmd exit_code="$?"
          echo ''
          echo '"Dry-run" ended.'
          latest_error
          exit 0
          ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help ) $cmd-help ; exit 0 ;;
        -i|--info) shift ; info_flag="true"  ;;
        -l|--log) shift ; log_flag="true" ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -t|--time) shift ; time_flag="true" ;;
        -S|--skip-office) shift ; skip_flag="true" ;;
        --) shift ; rest=( "$@" ) ; break ;;
        *) echo "Invalid option [$1]..." ; echo ""; $cmd-help; exit 1 ;;
      esac
    done
    backup > $output
    ;;
  changes)
    shopt -u nocasematch
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help ) $cmd-help ; exit 0 ;;
        -H|--host) shift ; host_flag="$1" ; shift ;;
        -l|--log) shift ; log_flag="true" ;;
        -m|--metadata) shift ; metadata_flag="true" ;;
        -p|--path) shift ; path_flag="$1"; shift ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -T|--tag) shift ; tag_flag="$1"; shift ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    changes > $output
    ;;
  checkout)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help) $cmd-help ; exit 0 ;;
        -l|--log) shift ; log_flag="true" ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; random-check-help ; exit 1 ;;
      esac
    done
    random-check > $output
    ;;
  cleanup)
    shopt -u nocasematch
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -a|--archive) shift ; archive_flag="true" ;;
        -C|--check) shift ; check_flag="true" ;;
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help ) $cmd-help ; exit 0 ;;
        -i|--info) shift ; info_flag="true" ;;
        -l|--log) shift ; log_flag="true" ;;
        -n|--next)
          if [[ -z "$CLEAN" ]] ; then
            echo -e "$yellow""You have not indicated any policy for the CLEAN value...""$endcolor"
            echo "The scrip will run check, forget and prune every time it runs"
            echo "unless you change the CLEAN variable at the beginning of this script."
            echo "The number indicated in the CLEAN variable must be in days."
            echo "For more information about the usage check out the following link:"
            echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
            exit
          else
            cleanup-next
            exit
          fi
          ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        --reset)
          if [[ -f "$config_dir/$repo-datefile" ]] ; then
            echo -e "$yellow""Removing datefile for [$repo]:""$endcolor"
            rm -v "${config_dir:?}/$repo-datefile"
            exit 0
          else
            echo -e "$yellow""There is no datefile for [$repo]... nothing to do.""$endcolor"
            exit 0
          fi
          ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; rest=( "$@" ) ; break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    cleanup > $output
    ;;
  env)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -h|--help) $cmd-help ; exit 0 ;;
        -v|--var) shift ; var_flag="$1" ; shift ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo ""; $cmd-help ; exit 1 ;;
      esac
    done
    env_conf
    ;;
  -h|--help|help)
    usage
    ;;
  info)
    shopt -u nocasematch
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help) $cmd-help ; exit 0 ;;
        -H|--host) shift ; host_flag="$1" ; shift ;;
        -l|--log) shift ; log_flag="true" ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo ""; $cmd-help ; exit 1 ;;
      esac
    done
    statinfo
    ;;
  logs)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -c|--cat) shift ; catlogs="true" ; logfile="$1" ; shift ;;
        -h|--help) $cmd-help ; exit 0 ;;
        -r|--remove) shift ; removelogs="true" ; logfile="$1" ; shift ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo ""; $cmd-help ; exit 1 ;;
      esac
    done
    logs
    ;;
  mounter)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -h|--help) $cmd-help ; exit 0 ;;
        --) shift ; rest=( "$@" ) ; break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    mounter
    ;;
  restorer)
    shopt -u nocasematch
    if [[ ! "$3" ]] ; then
      echo "You have not indicated any option..."
      echo ""
      restorer-help
      exit 1
    elif [[ "$3" != -* ]] ; then
      echo "[$3] is not a valid option..."
      echo ""
      restorer-help
      exit 1
    fi
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help) $cmd-help ; exit 0 ;;
        -H|--host) shift ; host_flag="$1" ; shift ;;
        -l|--log) shift ; log_flag="true" ;;
        -p|--path) shift ; path_flag="$1" ; shift ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -s|--snapshot) shift ; snap_flag="$1" ; shift ;;
        -T|--tag) shift ; tag_flag="$1" ; shift ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..." ; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    restorer > $output
    ;;
  snaps)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -d|--debug) shift ; debug_flag="true" ;;
        -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
        -h|--help) $cmd-help ; exit 0 ;;
        -l|--log) shift ; log_flag="true" ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        -t|--time) shift ; time_flag="true" ;;
        --) shift ; rest=( "$@" ) ; break ;;
        *) echo "Invalid option [$1]..."; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    snaps > $output
    ;;
  unlocker)
    eval set -- "$get_opt"
    while true ;
    do
      case "$1" in
        -h|--help) $cmd-help ; exit 0 ;;
        -q|--quiet) shift ; output="/dev/null" ;;
        --) shift ; break ;;
        *) echo "Invalid option [$1]..."; echo "" ; $cmd-help ; exit 1 ;;
      esac
    done
    unlocker > $output
    ;;
  *)
    rest=( "${@:2}" )
    case "$cmd" in
      -d*|--debug|-e*|--email|-l*|--log|-t*|--time|-q*|--quiet)
        case "$(uname -s)" in
          Darwin)
            if [[ -d "/usr/local/opt/gnu-getopt/bin" ]] ; then
              get_opt=$($getopt -o delqt -l debug,email,log,quiet,time -n "$(echo -e "$(basename $0) $cmd")" -- "${@:2}") || exit 1
            else
              get_opt=$($getopt delqt "${@:2}") || exit 1
            fi
            ;;
          FreeBSD|NetBSD|OpenBSD) get_opt=$($getopt delqt "${@:2}") || exit 1 ;;
          *) get_opt=$($getopt -o delqt -l debug,email,log,quiet,time -n "$(echo -e "$(basename $0) $cmd")" -- "${@:2}") || exit 1 ;;
        esac
        eval set -- "$get_opt"
        while true ;
        do
          case "$1" in
            -d|--debug) shift ; debug_flag="true" ;;
            -e|--email) shift ; int="false" ; CONFIRMATION_EMAIL="y" ;;
            -l|--log) shift ; log_flag="true" ; cmd="$1" ;;
            -q|--quiet) shift ; output="/dev/null" ;;
            -t|--time) shift ; time_flag="true" ; cmd="$1" ;;
            --) shift ; rest=( "$@" ) ; cmd="$1" ;
              if [[ "$cmd" = "--repo="* ]] ; then
                  cmd="$2"
              elif [[ "$cmd" = "-r" || "$cmd" = "--repo" ]] ; then
                  cmd="$3"
              fi
              break ;;
            *) echo "Invalid option [$1]..." ; echo "" ; usage | sed -ne '/Usage/,/EOF/p' ; exit 1 ;;
          esac
        done
        ;;
    esac
    restic_alone > $output
    ;;
esac

job_done

shopt -u nocasematch

exit $exit_code
