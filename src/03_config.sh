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
# CLEAN: determine when it will execute forget, prune and check (i.e.: 7minutes, 7hours, 7days); by default is set to 7 days.
# CONFIRMATION_EMAIL: set to "yes" to receive email with output when job finished successfully.
# DESTINATION: display name of your destination in output instead of path (i.e.: Wasabi, B2, etc.).
# EMAIL: put your email address to receive emails with output when something fails (when using cron only).
# EXCLUDE_FILE: set "yes" to use the exclude file generated for backups (by default is set to yes; if blank it will read the exclusion file for previous versions comptability).
# EXCLUDE_CACHE: set "yes" to use "--exclude-cache" flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
# HOST: use a custom hostname for your snapshots.
# LOGGING: set to "yes" to save a log with output when using the automatic function (by default is set to yes).
# LOG_RETENTION: number of days to keep logs (e.g., 30). Leave blank to keep all logs forever.
# ONE_FILE_SYSTEM: set to "yes" to use "--one-file-system" flag for backups.
# POST_CMD: command to run after the automatic backup finishes successfully.
# PRE_CMD: command to run before the automatic backup starts.
# RESTIC_COMPRESSION: set to "auto", "max" or "off" to configure data compression (requires restic 0.14.0+).
# SHOW_SNAPS: set to "yes" to show a list of snapshots at the end of the backup.
# SHOW_STATS: set to "yes" to calculate and display repository stats at the end.
# SKIP_OFFICE: set to yes to temporarily exclude open (in use) "office" documents.
# TAG: tag your snapshots.
CLEAN="7days"
CONFIRMATION_EMAIL=""
DESTINATION=""
EMAIL=""
EXCLUDE_FILE="yes"
EXCLUDE_CACHE="yes"
HOST=""
LOGGING="yes"
LOG_RETENTION=""
ONE_FILE_SYSTEM=""
POST_CMD=""
PRE_CMD=""
RESTIC_COMPRESSION="auto"
SHOW_SNAPS="yes"
SHOW_STATS="yes"
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

function _list_files {
  local title="$1"
  local pattern="${2:-}"
  local sedpat="$3"
  echo "$ui_line_eq"
  printf " %-20s \n" "$title"
  echo "$ui_line_eq"
  echo " [1] Back to Main Menu"
  echo " [2] Exit             "
  echo "$ui_line_dash"
  find "$config_dir" -maxdepth 1 -type f -exec basename {} \; | grep -e "$pattern" | sed -e "s/$sedpat//"
  echo "$ui_line_eq"
}

function config_menu {
  echo "$ui_line_eq"
  echo "       Options        "
  echo "$ui_line_eq"
  echo " [1] Edit Existing    "
  echo " [2] New Repository   "
  echo " [3] Delete Config    "
  echo " [4] Back to Main Menu"
  echo " [5] Exit             "
  echo "$ui_line_eq"
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
  _list_files "Config Files" "\.conf" "\.conf$"
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
  chmod 600 "$new_repo"
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
  _list_files "Config Files" "\.conf" "\.conf$"
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
  echo "$ui_line_eq"
  echo "  Exclusions Options  "
  echo "$ui_line_eq"
  echo " [1] Edit Existing    "
  echo " [2] Build Exclusions "
  echo " [3] Back to Main Menu"
  echo " [4] Exit             "
  echo "$ui_line_eq"
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
  _list_files "Exclusion Files" "-exclusions" "-exclusions$"
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

function _build_exclusions_action {
  local excl_cmd="$1"
  clear
  _list_files "Exclusion Files" "-exclusions" "-exclusions$"
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
            "$excl_cmd" > "$config_dir/$excl_file-exclusions"
            clear
            echo "Done building exclusion list for [$excl_file]."
            build_exclusions
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
}

function build_exclusions {
  echo "$ui_line_eq"
  echo "    Build Options     "
  echo "$ui_line_eq"
  echo " [1] For Home Dir     "
  echo " [2] For System Dir   "
  echo " [3] Back             "
  echo " [4] Exit             "
  echo "$ui_line_eq"
  read -rp "Select an option and press Enter [ 1 - 4 ]: " excl_bld
  case "$excl_bld" in
    1|home) _build_exclusions_action "long_exclusions" ;;
    2|system) _build_exclusions_action "sys_exclusions" ;;
    3|back) clear ; exclusion_menu ;;
    4|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid action indicated..." ; build_exclusions ;;
  esac
}

# ============================================================== #
# Install & Update																							 #
# ============================================================== #
