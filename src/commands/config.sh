# ============================================================== #
#                        COMMAND: CONFIG                         #
# ============================================================== #

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
  local cfgopt
  echo "$ui_line_eq"
  echo "       Options        "
  echo "$ui_line_eq"
  echo " [1] Edit Existing    "
  echo " [2] New Repository   "
  echo " [3] Edit Global Config"
  echo " [4] Delete Config    "
  echo " [5] Back to Main Menu"
  echo " [6] Exit             "
  echo "$ui_line_eq"
  read -rp "Select an option and press Enter [ 1 - 6 ]: " cfgopt
  case "$cfgopt" in
    1|edit) clear ; edit_config_files ;;
    2|new) new_config_file ;;
    3|global) 
      if [[ ! -f "$config_global" ]]; then
        global_config_template > "$config_global"
        chmod 600 "$config_global"
      fi
      "$rescript_editor" "$config_global"
      clear ; config_menu ;;
    4|delete) clear ; delete_config_file ;;
    5|back) clear ; main_menu ;;
    6|exit) echo "Exiting..." ; exit ;;
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
        "$rescript_editor" "$config_dir/$conf.conf"
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
  trap 'rm -f "$new_repo" 2>/dev/null; cleanup_on_exit; exit 130' INT QUIT TERM
  trap 'rm -f "$new_repo" 2>/dev/null; cleanup_on_exit' EXIT
  config_file > "$new_repo"
  chmod 600 "$new_repo"
  read -rp "Write the name for your new repository (case sensitive): " repo_name
  if [[ $repo_name ]] ; then
    mv "$new_repo" "$config_dir/$repo_name.conf"
    touch "$config_dir/$repo_name-exclusions"
    simple_exclusions > "$config_dir/$repo_name-exclusions"
    echo "[$repo_name] config file has been created. If this is a new repository,"
    echo "you must run [rescript $repo_name init] to initialize your new repository"
    echo "before executing any other command. You also need to edit your new config"
    echo "file to proceed."
    read -rp "Would you like to open [$repo_name] config file now? y/n " answer
    case $answer in
      y|yes) "$rescript_editor" "$config_dir/$repo_name.conf" ; clear ; config_menu ;;
      n|no) echo "Remember to configure your repo file before continuing!" ; exit ;;
      *) clear ; echo "Invalid action..." ; config_menu ;;
    esac
  else
    rm -f "$new_repo"
    echo "Exiting..."
    exit
  fi
}

function delete_config_file {
  local del ans
  _list_files "Config Files" "\.conf" "\.conf$"
  read -rp "Type the name of the repo file you wish to delete or one of the options above [ 1 - 2 ]: " del
  case $del in
    1|back) clear ; config_menu ;;
    2|exit) echo "Exiting..." ; exit ;;
    *)
      if [[ -f "$config_dir/$del.conf" ]] ; then
        read -rp "Are you sure you want to delete [$del]? y/n: " ans
        case $ans in
          y|yes) rm -f "$config_dir/$del.conf" ; rm -f "$config_dir/$del-exclusions" ; rm -f "$config_dir/$del.state" ; rm -f "$config_dir/$del-datefile" ; clear ; echo "[$del] repository configuration has been removed." ; delete_config_file ;;
          n|no) clear ; delete_config_file ;;
          exit) echo "Exiting..." ; exit ;;
          *) echo "No valid action indicated; exiting..." ; exit ;;
        esac
      else
        clear
        echo "There is no configuration file called [$del]; try again..."
        delete_config_file
      fi
      ;;
  esac
}

function config_wizard {
  clear
  echo "$ui_line_eq"
  echo "    Rescript Configuration Wizard"
  echo "$ui_line_eq"
  if [[ ! -f "$config_global" ]]; then
    echo "--- Global Setup ---"
    echo "Let's set up your global defaults first."
    
    # 1. Email setup
    read -rp "1. Do you want to receive email alerts? (y/n) [n]: " ans_email
    w_email=""
    w_confirm=""
    if [[ "$ans_email" == "y" || "$ans_email" == "yes" ]]; then
      read -rp "   Enter your email address: " w_email
      read -rp "   Receive emails also on successful backups? (y/n) [n]: " ans_success
      if [[ "$ans_success" == "y" || "$ans_success" == "yes" ]]; then
        w_confirm="yes"
      fi
    fi
    
    # 2. Webhook
    read -rp "2. Discord/Slack Webhook URL (Optional, press Enter to skip): " w_web
    
    # 3. Logging
    read -rp "3. Enable automatic logging? (y/n) [y]: " ans_log
    w_log="yes"
    if [[ "$ans_log" == "n" || "$ans_log" == "no" ]]; then
      w_log="no"
    fi
    w_log_ret=""
    if [[ "$w_log" == "yes" ]]; then
      read -rp "   Log retention in days (Optional, leave blank to keep forever): " w_log_ret
    fi
    
    # 4. Retention Policies
    echo "4. Retention Policies (Press Enter to keep the default)"
    read -rp "   Keep Last (default: none): " w_k_last
    read -rp "   Keep Hourly (default: 8): " w_k_hourly
    read -rp "   Keep Daily (default: 7): " w_k_daily
    read -rp "   Keep Weekly (default: 4): " w_k_weekly
    read -rp "   Keep Monthly (default: 12): " w_k_monthly
    read -rp "   Keep Yearly (default: 10): " w_k_yearly
    
    global_config_template > "$config_global"
    chmod 600 "$config_global"
    
    local g_conf="$config_global"
    
    if [[ -n "$w_email" ]]; then
      safe_sed "s|^EMAIL=\"\"|EMAIL=\"$w_email\"|" "$g_conf"
    fi
    if [[ -n "$w_confirm" ]]; then
      safe_sed "s|^CONFIRMATION_EMAIL=\"\"|CONFIRMATION_EMAIL=\"$w_confirm\"|" "$g_conf"
    fi
    if [[ -n "$w_web" ]]; then
      safe_sed "s|^WEBHOOK_URL=\"\"|WEBHOOK_URL=\"$w_web\"|" "$g_conf"
    fi
    
    safe_sed "s|^LOGGING=\"yes\"|LOGGING=\"$w_log\"|" "$g_conf"
    
    if [[ -n "$w_log_ret" ]]; then
      safe_sed "s|^LOG_RETENTION=\"\"|LOG_RETENTION=\"$w_log_ret\"|" "$g_conf"
    fi
    
    if [[ -n "$w_k_last" ]]; then safe_sed "s|^KEEP_LAST=\"\"|KEEP_LAST=\"$w_k_last\"|" "$g_conf" ; fi
    if [[ -n "$w_k_hourly" ]]; then safe_sed "s|^KEEP_HOURLY=\"8\"|KEEP_HOURLY=\"$w_k_hourly\"|" "$g_conf" ; fi
    if [[ -n "$w_k_daily" ]]; then safe_sed "s|^KEEP_DAILY=\"7\"|KEEP_DAILY=\"$w_k_daily\"|" "$g_conf" ; fi
    if [[ -n "$w_k_weekly" ]]; then safe_sed "s|^KEEP_WEEKLY=\"4\"|KEEP_WEEKLY=\"$w_k_weekly\"|" "$g_conf" ; fi
    if [[ -n "$w_k_monthly" ]]; then safe_sed "s|^KEEP_MONTHLY=\"12\"|KEEP_MONTHLY=\"$w_k_monthly\"|" "$g_conf" ; fi
    if [[ -n "$w_k_yearly" ]]; then safe_sed "s|^KEEP_YEARLY=\"10\"|KEEP_YEARLY=\"$w_k_yearly\"|" "$g_conf" ; fi
    
    printf "%b\n" "Global configuration saved.\n"
  fi

  echo "--- Repository Setup ---"
  read -rp "1. Repository Name (e.g., local-backup): " w_name
  if [[ -z "$w_name" ]]; then echo "Name cannot be empty. Exiting." ; exit 1 ; fi
  if [[ -f "$config_dir/$w_name.conf" ]]; then echo "Repository already exists! Exiting." ; exit 1 ; fi

  read -rp "2. Restic Repository Location (e.g., /mnt/backup, s3:s3.amazonaws.com/bucket): " w_repo
  read -rs -p "3. Restic Password: " w_pass ; echo ""
  read -rp "4. Target Directory to Backup (default: $HOME): " w_dir
  w_dir=${w_dir:-$HOME}
  
  echo "Creating configuration..."
  
  local new_conf="$config_dir/$w_name.conf"
  config_file > "$new_conf"
  
  safe_sed "s|RESTIC_REPO=\"\"|RESTIC_REPO=\"$w_repo\"|" "$new_conf"
  safe_sed "s|RESTIC_PASSWORD=\"\"|RESTIC_PASSWORD=\"$w_pass\"|" "$new_conf"
  safe_sed "s|^BACKUP_DIR=.*|BACKUP_DIR=\"$w_dir\"|" "$new_conf"
  
  chmod 600 "$new_conf"
  touch "$config_dir/$w_name-exclusions"
  simple_exclusions > "$config_dir/$w_name-exclusions"
  
  printf "%b\n" "\nConfiguration [$w_name] created successfully!"
  echo "Tip: You can edit your global configuration at any time by running: rescript config --global"
  read -rp "Would you like to initialize this repository now? (y/n): " ans
  case $ans in
    y|yes) 
      "$0" "$w_name" init
      ;;
    *)
      echo "You can initialize it later by running: rescript $w_name init"
      ;;
  esac
}

# Exclusions menu
function exclusion_menu {
  local excl_opt
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
  local excl_edit
  _list_files "Exclusion Files" "-exclusions" "-exclusions$"
  read -rp "Type the name of the exclusions file you wish to open or one of the options above [ 1 - 2 ]: " excl_edit
  case "$excl_edit" in
    1|back) clear ; exclusion_menu ;;
    2|exit) echo "Exiting..." ; exit ;;
    *)
      if [[ -e "$config_dir/$excl_edit-exclusions" ]] ; then
        "$rescript_editor" "$config_dir/$excl_edit-exclusions"
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
  local excl_file ans_excl
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
  local excl_bld
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

function rescript_config {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    config-help
    exit 0
  elif [[ "${1:-}" == "--wizard" ]]; then
    config_wizard
    exit 0
  elif [[ "${1:-}" == "-g" || "${1:-}" == "--global" ]]; then
    if [[ -z "$rescript_editor" ]] ; then
      rescript_editor_cmd
      if [[ -f "$config_global" ]]; then
        source_config "$config_global"
      fi
      rescript_editor="${RESCRIPT_EDITOR:-}"
      echo "Please type [rescript config --global] again to edit"
      echo "your global configuration."
      exit
    fi
    if [[ ! -f "$config_global" ]]; then
      global_config_template > "$config_global"
      chmod 600 "$config_global"
    fi
    "$rescript_editor" "$config_global"
    exit 0
  elif [[ -n "${1:-}" ]]; then
    echo "Invalid option [${1:-}]..." ; echo "" ; config-help ; exit 1
  fi
  if [[ -z "$rescript_editor" ]] ; then
    rescript_editor_cmd
    if [[ -f "$config_global" ]]; then
      source_config "$config_global"
    fi
    rescript_editor="${RESCRIPT_EDITOR:-}"
    echo "Please type [rescript config] again to set/edit"
    echo "your configuration/exclusion files."
    exit
  fi
  clear
  main_menu
}
# Main menu
function main_menu {
  local main
  echo "$ui_line_eq"
  echo "        Menu          "
  echo "$ui_line_eq"
  echo " [1] Configuration    "
  echo " [2] Exclusions       "
  echo " [3] Exit             "
  echo "$ui_line_eq"
  read -rp "Select an option and press Enter [ 1 - 3 ]: " main
  case "$main" in
    1|configuration) clear ; config_menu ;;
    2|exclusions) clear ; exclusion_menu ;;
    3|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid option..." ; main_menu ;;
  esac
}
