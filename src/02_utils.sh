function handle_interrupt {
  echo ""
  echo "################ Proccess interrupted ################"
  echo ""
  exit 130
}

trap handle_interrupt INT HUP QUIT

# Create a rescript directories if they are not present
mkdir -p "$rescript_dir" "$config_dir" "$lock_dir" "$logs_dir"
# Create "editor" file if not present
if [[ ! -f "$config_dir/.editor" ]] ; then
  touch "$config_dir/.editor"
fi
rescript_editor="$(cat "$config_dir/.editor")"
# Set PATH so it includes user's private bin if it exists (cron jobs may require this)
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

tput_columns=$(tput cols 2>/dev/null)

if [[ "$tput_columns" -gt "0" ]] ; then
  cols="$tput_columns"
else
  cols="80"
fi

if [[ -t 1 ]] ; then
  int="true"
else
  int="false"
fi

function print_line {
  local char="${1:--}"
  echo -ne "${c_gray}"
  printf "%${cols}s\n" "" | tr ' ' "$char"
  echo -ne "${c_reset}"
}

function _send_email {
  local subject="$1"
  if [[ "$simulate_flag" == "true" ]]; then
    echo -e "${c_yellow}SIMULATE: Would send email to [$EMAIL] with subject: [$subject]${c_reset}"
    return 0
  fi
  if [[ -n "$EMAIL" ]] ; then
    if [[ "$(command -v mail)" ]] ; then
      if [[ "$int" = "false" ]] ; then
        if [[ -e "$log" ]] ; then
          logmessage="Logfile: $log"
          catlog=$(sed -E "s/$(printf '\033')\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$log")
        else
          logmessage="Output for this job:"
          catlog=$(sed -E "s/$(printf '\033')\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$tmplog")
        fi
        local mail_err
        mail_err=$(mktemp)
        local mail_status=0
        if [[ "$time_flag" = "true" ]] ; then
          echo -e "$logmessage\n\n$catlog" | mail -s "$subject" "$EMAIL" 2> "$mail_err"
          mail_status=$?
        else
          echo -e "Date: $(date +%a\ %b\ %d\ %Y\ %r)\nSystem: $(opsys)\nHostname: $rhost\nRepository Location: $dest\nRestic Version: $(restic version | awk '{print $2}')\n\n$logmessage\n$(print_line)\n$catlog\n$(print_line)\nEnd: $(date +%a\ %b\ %d\ %Y\ %r)\nDuration: $(duration)" | mail -s "$subject" "$EMAIL" 2> "$mail_err"
          mail_status=$?
        fi
        if [[ $mail_status -ne 0 ]]; then
          echo -e "\n${c_yellow}WARNING: Rescript could not send the email. Make sure your system's mail agent (MTA) is installed and configured correctly.${c_reset}"
        fi
        rm -f "$mail_err"
      fi
    else
      echo "[rescript] can't send emails; install [mailutils] package to do so."
    fi
  fi
}

function print_context {
  if [[ "$context_flag" != "true" || "$quiet_flag" == "true" || "$context_printed" == "true" ]] ; then
    return 0
  fi
  context_printed="true"

  local title="Rescript Execution Context"
  local padding=$(( (cols - ${#title}) / 2 ))
  
  print_line "="
  echo -ne "${c_blue}"
  printf "%*s%s\n" "$padding" "" "$title"
  echo -ne "${c_reset}"
  print_line "="
  
  local date_time
  date_time=$(date +"%Y-%m-%d %H:%M:%S")
  local mode="Live"
  if [[ "$simulate_flag" == "true" ]]; then
    mode="Dry-Run (Simulated)"
  fi
  
  local backend="Local"
  if [[ "$RESTIC_REPO" == sftp* ]]; then backend="SFTP"
  elif [[ "$RESTIC_REPO" == b2* ]]; then backend="Backblaze B2"
  elif [[ "$RESTIC_REPO" == s3* ]]; then backend="S3"
  elif [[ "$RESTIC_REPO" == azure* ]]; then backend="Azure"
  elif [[ "$RESTIC_REPO" == gs* ]]; then backend="Google Cloud"
  elif [[ "$RESTIC_REPO" == rclone* ]]; then backend="Rclone"
  elif [[ "$RESTIC_REPO" == rest* ]]; then backend="REST Server"
  fi

  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Date/Time" "$date_time"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "System" "$(opsys)"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Hostname" "$rhost"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Profile" "$repo"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Command" "$cmd"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Mode" "$mode"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Backend" "$backend"
  printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Restic Version" "$(restic version | awk '{print $2}')"
  
  if [[ -n "$dest" ]] ; then
    printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Destination" "$dest"
  fi

  case "$cmd" in
    backup|automatic)
      printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Backup Source" "$BACKUP_DIR"
      local excl_count
      excl_count=$(grep -E -v -c '(^#|^\s*$|^\s*\t*#)' "$excludes" 2>/dev/null || echo 0)
      if [[ "$excl_count" -gt 0 ]] ; then
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Exclusions" "$excl_count rules applied"
      fi
      local hooks=""
      if [[ -n "$PRE_CMD" && -n "$POST_CMD" ]]; then hooks="Pre & Post Hooks Configured"
      elif [[ -n "$PRE_CMD" ]]; then hooks="Pre-Hook Configured"
      elif [[ -n "$POST_CMD" ]]; then hooks="Post-Hook Configured"
      fi
      if [[ -n "$hooks" ]]; then
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Hooks" "$hooks"
      fi
      if [[ -n "$CLEAN" ]] ; then
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Auto-Clean" "Every $CLEAN"
      fi
      ;;
    cleanup)
      printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Policies" "${policies[*]}"
      ;;
    restorer)
      if [[ -n "$snap_id" ]] ; then
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Snapshot ID" "$snap_id"
      else
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Snapshot ID" "latest"
      fi
      printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Target Dir" "$restore_dir"
      ;;
  esac
  print_line "="
  echo ""
}

function job_done {
  if [[ -z "$cmd" ]] ; then
    cmd="backup"
  fi
  if [[ "$CONFIRMATION_EMAIL" = "y" || "$CONFIRMATION_EMAIL" = "yes" ]] ; then
    _send_email "rescript: [$repo] $cmd finished successfully!"
  fi
}

function report_errors {
  if [[ -z "$cmd" ]] ; then
    cmd="backup"
  fi
  if [[ -n "$error_message" ]] ; then
    if [[ "$ping_code" -gt "0" ]] ; then
      echo -e "${c_red}$error_message${c_reset}"
    else
      echo ""
      echo -e "${c_red}${c_white}WARNING!${c_reset}"
      echo -e "${c_red}$error_message${c_reset}"
    fi
    _send_email "rescript: [$repo] $cmd failed!"
  fi
}

function check_restic_error {
  exit_code="$1"
  latest_cmd="$prev_cmd"
  latest_error
}

function latest_error {
  if [[ "$exit_code" != "0" ]] ; then
    if [[ -n "$rest_cmd" ]] ; then
      error_message="[$rest_cmd] failed; exit code $exit_code"
    else
      read -r cmd1 cmd2 _ <<< "$latest_cmd"
      if [[ "$cmd1" = *"restic" ]] ; then
        error_message="[$cmd2] failed; exit code $exit_code"
      else
        error_message="[$cmd1] failed; exit code $exit_code"
      fi
    fi
    report_errors
    time_end
    exit "${exit_code:-$?}"
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
        elif [[ -s /etc/os-release ]] ; then
          (source /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")
        elif [[ -s /etc/issue.net ]] ; then
          cat /etc/issue.net
        else
          echo "Unknown Linux OS ($(uname -m))"
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
  ndur=${#dur[@]}
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

function print_progress {
  local label="$1"
  local percent="$2"
  local length=20
  local fill=$(( (percent * length) / 100 ))
  local empty=$(( length - fill ))
  
  printf "%-30s: [" "$label"
  
  if [[ $fill -gt 0 ]]; then
    printf "%${fill}s" "" | tr ' ' '#'
  fi
  if [[ $empty -gt 0 ]]; then
    printf "%${empty}s" "" | tr ' ' '-'
  fi
  
  printf "](%s%%)\r" "$percent"
}
