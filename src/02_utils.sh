# ============================================================== #
#                           UTILS                                #
# ============================================================== #

function hide_cursor {
  tput civis 2> /dev/null || true
}

function show_cursor {
  tput cnorm 2> /dev/null || true
}

function handle_interrupt {
  echo ""
  echo "################ Proccess interrupted ################"
  echo ""
  exit 130
}

trap handle_interrupt INT HUP QUIT

# Create the rescript directories if they are not present
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

function array_contains {
  local target="$1"
  shift
  for element in "$@"; do
    if [[ "$element" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

function print_line {
  local char=${1:--}
  local cols=$(tput cols 2>/dev/null || echo 80)
  [[ -z "$cols" || ! "$cols" =~ ^[0-9]+$ ]] && cols=80
  
  local line=""
  for (( i=0; i<cols; i++ )); do
    line="${line}${char}"
  done
  echo -ne "${c_gray}${line}${c_reset}\n"
}

function _send_email {
  local subject="${1:-}"
  if [[ "$simulate_flag" == "true" ]]; then
    echo -e "${c_yellow}SIMULATE: Would send email to [$EMAIL] with subject: [$subject]${c_reset}"
    return 0
  fi
  if [[ -n "$EMAIL" ]] ; then
    if [[ "$(command -v mail)" ]] ; then
      if [[ "$int" = "false" || "${force_email:-}" = "true" ]] ; then
        if [[ -n "${log:-}" && -e "$log" ]] ; then
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
          echo -e "$logmessage\n\n$catlog" | mail -s "$subject" "$EMAIL" 2> "$mail_err" || mail_status=$?
        else
          echo -e "Date: $(date +%a\ %b\ %d\ %Y\ %r)\nSystem: $(opsys)\nHostname: $rhost\nRepository Location: $dest\nRestic Version: $(restic version | awk '{print $2}')\n\n$logmessage\n$(print_line)\n$catlog\n$(print_line)\nEnd: $(date +%a\ %b\ %d\ %Y\ %r)\nDuration: $(duration)" | mail -s "$subject" "$EMAIL" 2> "$mail_err" || mail_status=$?
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

function _send_webhook {
  local subject="${1:-}"
  if [[ -n "${WEBHOOK_URL:-}" ]] ; then
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_yellow}SIMULATE: Would send webhook to [$WEBHOOK_URL] with subject: [$subject]${c_reset}"
      return 0
    fi
    if [[ "$int" = "false" || "${force_webhook:-}" = "true" ]] ; then
      if [[ "$(command -v curl)" ]] ; then
        local target_log=""
        local attach_file=""
        
        if [[ -n "${log:-}" && -e "$log" ]] ; then
          target_log="$log"
        elif [[ -n "${tmplog:-}" && -e "$tmplog" ]] ; then
          target_log="$tmplog"
        fi
        
        if [[ -n "$target_log" ]]; then
          attach_file="/tmp/rescript_webhook_$$.txt"
          sed -E "s/$(printf '\033')\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$target_log" | tr -d '\r' | sed -E -e 's/={60,}/============================================================/g' -e 's/-{60,}/------------------------------------------------------------/g' -e 's/^[ \t]+(Rescript Execution Context)/                          \1/' > "$attach_file"
          
          curl -s -X POST -F "payload_json={\"content\": \"**$subject**\"}" -F "file=@$attach_file" "$WEBHOOK_URL" >/dev/null 2>&1 || true
          rm -f "$attach_file"
        else
          curl -s -X POST -H "Content-Type: application/json" -d "{\"content\": \"**$subject**\n\`\`\`text\nNo output captured.\n\`\`\`\"}" "$WEBHOOK_URL" >/dev/null 2>&1 || true
        fi
      else
        echo -e "${c_yellow}[rescript] can't send webhooks; install [curl] package to do so.${c_reset}"
      fi
    fi
  fi
}

function print_context {
  if [[ "${context_flag:-}" != "true" || "$context_printed" == "true" ]] ; then
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
      printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Backup Source" "${BACKUP_DIR[*]}"
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
      if [[ -n "${CLEAN:-}" ]] ; then
        printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Auto-Clean" "Every ${CLEAN:-}"
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
  cmd="${cmd:-backup}"
  
  if [[ ! "$cmd" =~ ^(automatic|backup|cleanup)$ && "${force_email:-}" != "true" && "${force_webhook:-}" != "true" ]]; then
    return 0
  fi

  if [[ "${CONFIRMATION_EMAIL:-}" = "y" || "${CONFIRMATION_EMAIL:-}" = "yes" ]] ; then
    _send_email "rescript: [$repo] $cmd finished successfully!"
  fi
  if [[ "${CONFIRMATION_WEBHOOK:-}" = "y" || "${CONFIRMATION_WEBHOOK:-}" = "yes" ]] ; then
    if [[ -n "${WEBHOOK_URL:-}" ]] ; then
      _send_webhook "✅ rescript: [$repo] $cmd finished successfully on [$(hostname)]!"
    fi
  fi
}

function report_errors {
  cmd="${cmd:-backup}"

  if [[ ! "$cmd" =~ ^(automatic|backup|cleanup)$ && "${force_email:-}" != "true" && "${force_webhook:-}" != "true" ]]; then
    return 0
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
    _send_webhook "❌ rescript: [$repo] $cmd failed on [$(hostname)]!"
  fi
}

function run_restic_with_retry {
  local max_attempts=3
  local attempt=1
  local exit_code=0
  
  while [[ $attempt -le $max_attempts ]]; do
    restic "$@"
    exit_code=$?
    
    # Restic exit code 1 = fatal error (often network/IO)
    # Restic exit code 11 = repository locked
    if [[ $exit_code -ne 1 && $exit_code -ne 11 ]]; then
      break
    fi
    
    if [[ $attempt -lt $max_attempts ]]; then
      echo -e "${c_yellow}Warning: restic failed with exit code $exit_code. Retrying in 30 seconds... (Attempt $attempt of $max_attempts)${c_reset}" >&2
      sleep 30
    fi
    ((attempt++))
  done
  
  return $exit_code
}

function check_restic_error {
  exit_code="${1:-0}"
  latest_cmd="${prev_cmd:-}"
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
  if [[ "$SECONDS" -eq 0 ]] ; then
    echo "0 seconds"
    return
  fi
  declare -a dur=()
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

function now_next {
  case "$unix_name" in
    Linux|GNU)
      now=$(date +"%s")
      ;;
    *)
      now=$(gdate +"%s" 2>/dev/null || date +"%s")
      ;;
  esac
  next=$(cat "$config_dir/$repo-datefile" 2>/dev/null || echo "0")
  if ! [[ "$next" =~ ^[0-9]+$ ]] ; then
    next=0
  fi
}

# UI and Progress Utilities

function print_progress {
  local label="${1:-}"
  local percent="${2:-}"
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

function run_with_spinner {
  local cmd="$1"
  local label="${2:-Working}"
  
  # Hide cursor
  hide_cursor
  
  printf "%b " "$label"
  
  # Execute the command in the background, suppressing stdout/stderr
  eval "$cmd" > /dev/null 2>&1 &
  local pid=$!
  
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf "\r%b %s" "$label" "${spin:$i:1}"
    sleep 0.1
  done
  
  # Wait to get the exact exit code
  wait $pid
  local exit_code=$?
  
  # Restore cursor and clean spinner
  show_cursor
  
  if [[ $exit_code -eq 0 ]]; then
    printf "\r%b %bDone!%b \n" "$label" "$c_green" "$c_reset"
  else
    printf "\r%b %bFailed!%b \n" "$label" "$c_red" "$c_reset"
  fi
  
  return $exit_code
}

function logger {
  if [[ "$log_flag" = "true" ]] ; then
    log="$logs_dir/$repo-$(date +%Y-%m-%d-%H%M%S).log"
    if [[ "$quiet_flag" == "true" ]]; then
      exec > "$log" 2>&1
    else
      exec > >(tee -a "$log") 2>&1
    fi
    if [[ -n "$LOG_RETENTION" && "$LOG_RETENTION" -gt 0 ]] 2>/dev/null ; then
      find "$logs_dir" \( -name "$repo-*.log" -o -name "$repo-*.log.gz" \) -type f -mtime +"$LOG_RETENTION" -exec rm -f {} +
    fi
  else
    if [[ "$quiet_flag" == "true" ]]; then
      exec > "$tmplog" 2>&1
    else
      exec > >(tee -a "$tmplog") 2>&1
    fi
  fi
}

function time_start {
  if [[ "$time_flag" = "true" ]] ; then
    SECONDS=0
  fi
}

function time_end {
  if [[ "$time_flag" = "true" ]] ; then
    print_line
    echo -e "${c_white}Duration:${c_reset} ${c_green}$(duration)${c_reset}"
  fi
}

function rescript_lock {
  if [[ "${rescript_lock_created:-}" == "true" ]]; then return 0; fi
  if [ -e "$lock" ]; then
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
    rescript_lock_created="true"
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

function set_sim_flag {
  local cmd_name="${1:-}"
  local default_flag="${2:-}"
  sim_flag="$default_flag"
  if [[ "$simulate_flag" == "true" ]]; then
    echo -e "${c_yellow}SIMULATE: $cmd_name running in dry-run mode.${c_reset}"
    sim_flag="--dry-run"
  fi
}

function _run_post_actions {
  if [[ "$check_flag" = "true" ]] ; then
    print_line
    echo -e "${c_cyan}Starting check...${c_reset}"
    run_quietly run_restic_with_retry check --cleanup-cache
  fi
  if [[ "$info_flag" = "true" ]] ; then
    print_line
    run_quietly statinfo
  fi
}

function source_config {
  local conf_file="$1"
  local bash_err
  if ! bash_err=$(bash -n "$conf_file" 2>&1); then
    echo -e "${c_red}FATAL ERROR: Rescript found a syntax error in your configuration file!${c_reset}"
    echo -e "${c_yellow}File: $conf_file${c_reset}"
    echo -e "${c_yellow}Details: $bash_err${c_reset}"
    echo -e "${c_yellow}Please verify your configuration file for missing quotes, unmatched brackets, or invalid syntax.${c_reset}"
    exit 2
  fi
  source "$conf_file"
}
