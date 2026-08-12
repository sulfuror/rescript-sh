# ============================================================== #
#                           UTILS                                #
# ============================================================== #
hide_cursor() {
  tput civis 2> /dev/null || true
}
show_cursor() {
  tput cnorm 2> /dev/null || true
}
handle_interrupt() {
  printf "\n"
  printf "%s\n" "################ Process interrupted ################"
  printf "\n"
  exit 130
}
cleanup_on_exit() {
  if [[ "${rescript_lock_created:-}" == "true" ]]; then
    rm -f "${lock:?}" 2>/dev/null
    rescript_lock_created="false"
  fi
  if [[ -n "${tmplog:-}" ]]; then 
    rm -f "${tmplog:?}" 2>/dev/null
    tmplog=""
  fi
  if [[ -n "${session_tmp:-}" && -d "$session_tmp" ]]; then
    rm -rf "${session_tmp:?}" 2>/dev/null
    session_tmp=""
  fi
}
safe_sed() {
  if [[ "$unix_name" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}
is_pid_alive() {
  local target_pid="$1"
  if [[ -n "$target_pid" ]] && kill -0 "$target_pid" 2>/dev/null; then
    return 0
  fi
  return 1
}

trap 'cleanup_on_exit; handle_interrupt' INT HUP QUIT TERM
trap 'cleanup_on_exit' EXIT

# Create the rescript directories if they are not present
mkdir -p "$rescript_dir" "$config_dir" "$lock_dir" "$logs_dir"



# Set PATH so it includes user's private bin if it exists (cron jobs may require this)
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

tput_columns=$(tput cols 2>/dev/null || printf "\n")

if [[ -n "$tput_columns" && "$tput_columns" -gt "0" ]] ; then
  cols="$tput_columns"
else
  cols="80"
fi

if [[ -t 1 ]] ; then
  int="true"
else
  int="false"
fi
array_contains() {
  local target="$1"
  shift
  for element in "$@"; do
    if [[ "$element" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}
print_line() {
  local char=${1:--}
  local current_cols="${cols:-80}"
  
  local line=""
  for (( i=0; i<current_cols; i++ )); do
    line="${line}${char}"
  done
  printf "%b" "${c_gray}${line}${c_reset}\n"
}
format_log_output() {
  local target_log="$1"
  sed -E "s/$(printf '\033')\[[0-9;?]*[a-zA-Z]//g" "$target_log" | sed 's/.*\r//' | tr -d '\r' | sed -E -e 's/={60,}/============================================================/g' -e 's/-{60,}/------------------------------------------------------------/g' -e 's/^[ \t]+(Rescript Execution Context)/                          \1/'
}
_send_email() {
  local subject="${1:-}"
  local logmessage catlog
  if [[ -n "$EMAIL" ]] ; then
    if command -v mail >/dev/null 2>&1 ; then
      if [[ "$int" = "false" || "${force_email:-}" = "true" ]] ; then
        if [[ "$simulate_flag" == "true" ]]; then
          printf "%b\n" "${c_yellow}SIMULATE: Would send email to [$EMAIL] with subject: [[SIMULATION] $subject]${c_reset}"
          return 0
        fi
        local text_line="============================================================"
        if [[ -n "${log:-}" && -e "$log" ]] ; then
          logmessage="Logfile: $log\n$text_line"
          catlog=$(format_log_output "$log")
        else
          logmessage=""
          catlog=$(format_log_output "$tmplog")
        fi
        local mail_err="$session_tmp/mail_err"
        local mail_status=0
        
        printf "%b\n" "${logmessage}\n${catlog}" | mail -s "$subject" "$EMAIL" 2> "$mail_err" || mail_status=$?
        
        if [[ $mail_status -ne 0 ]]; then
          printf "%b\n" "\n${c_yellow}WARNING: Rescript could not send the email. Make sure your system's mail agent (MTA) is installed and configured correctly.${c_reset}"
        fi
      fi
    else
      printf "%s\n" "[rescript] can't send emails; install [mailutils] package to do so."
    fi
  fi
}
_send_webhook() {
  local subject="${1:-}"
  if [[ -n "${WEBHOOK_URL:-}" ]] ; then
    if [[ "$int" = "false" || "${force_webhook:-}" = "true" ]] ; then
      if command -v curl >/dev/null 2>&1 ; then
        if [[ "$simulate_flag" == "true" ]]; then
          printf "%b\n" "${c_yellow}SIMULATE: Would send webhook to [$WEBHOOK_URL] with subject: [[SIMULATION] $subject]${c_reset}"
          return 0
        fi
        local target_log=""
        local attach_file=""
        
        if [[ -n "${log:-}" && -e "$log" ]] ; then
          target_log="$log"
        elif [[ -n "${tmplog:-}" && -e "$tmplog" ]] ; then
          target_log="$tmplog"
        fi
        
        if [[ -n "$target_log" ]]; then
          attach_file="$session_tmp/webhook_$$.txt"
          format_log_output "$target_log" > "$attach_file"
          
          local webhook_status=0
          curl -s -X POST -F "payload_json={\"content\": \"**$subject**\"}" -F "file=@$attach_file" "$WEBHOOK_URL" >/dev/null 2>&1 || webhook_status=$?
          if [[ $webhook_status -ne 0 ]]; then
            printf "%b\n" "${c_yellow}WARNING: Rescript could not send the webhook to the provided URL.${c_reset}"
          fi
          rm -f "$attach_file"
        else
          local webhook_status=0
          curl -s -X POST -H "Content-Type: application/json" -d "{\"content\": \"**$subject**\n\`\`\`text\nNo output captured.\n\`\`\`\"}" "$WEBHOOK_URL" >/dev/null 2>&1 || webhook_status=$?
          if [[ $webhook_status -ne 0 ]]; then
            printf "%b\n" "${c_yellow}WARNING: Rescript could not send the webhook to the provided URL.${c_reset}"
          fi
        fi
      else
        printf "%b\n" "${c_yellow}[rescript] can't send webhooks; install [curl] package to do so.${c_reset}"
      fi
    fi
  fi
}
print_context() {
  if [[ "${context_flag:-}" != "true" || "$context_printed" == "true" ]] ; then
    return 0
  fi
  context_printed="true"

  local title="Rescript Execution Context"
  local padding=$(( (cols - ${#title}) / 2 ))
  
  print_line "="
  printf "%b" "${c_blue}"
  printf "%*s%s\n" "$padding" "" "$title"
  printf "%b" "${c_reset}"
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
      printf "  ${c_white}%-15s${c_reset}: ${c_cyan}%s${c_reset}\n" "Backup Source" "${BACKUP_DIR[*]:-}"
      local excl_count
      excl_count=$(grep -E -v -c '(^#|^\s*$|^\s*\t*#)' "$excludes" 2>/dev/null || true)
      excl_count="${excl_count:-0}"
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
  printf "\n"
}
job_done() {
  cmd="${cmd:-backup}"
  
  if [[ ! "$cmd" =~ ^(automatic|backup|cleanup)$ && "${force_email:-}" != "true" && "${force_webhook:-}" != "true" ]]; then
    return 0
  fi

  local success_msg
  success_msg="✅ rescript: [$repo] $cmd finished successfully on [$(hostname)]!"

  if [[ "${CONFIRMATION_EMAIL:-}" = "y" || "${CONFIRMATION_EMAIL:-}" = "yes" ]] ; then
    _send_email "$success_msg"
  fi
  if [[ "${CONFIRMATION_WEBHOOK:-}" = "y" || "${CONFIRMATION_WEBHOOK:-}" = "yes" ]] ; then
    if [[ -n "${WEBHOOK_URL:-}" ]] ; then
      _send_webhook "$success_msg"
    fi
  fi
}
report_errors() {
  cmd="${cmd:-backup}"

  if [[ ! "$cmd" =~ ^(automatic|backup|cleanup)$ && "${force_email:-}" != "true" && "${force_webhook:-}" != "true" ]]; then
    return 0
  fi

  if [[ -n "$error_message" ]] ; then
    if [[ "$ping_code" -gt "0" ]] ; then
      printf "%b\n" "${c_red}$error_message${c_reset}"
    else
      printf "\n"
      printf "%b\n" "${c_red}${c_white}WARNING!${c_reset}"
      printf "%b\n" "${c_red}$error_message${c_reset}"
    fi
    local error_msg
    error_msg="❌ rescript: [$repo] $cmd failed on [$(hostname)]!"
    _send_email "$error_msg"
    _send_webhook "$error_msg"
  fi
}
run_restic_with_retry() {
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
      printf "%b\n" "${c_yellow}Warning: restic failed with exit code $exit_code. Retrying in 30 seconds... (Attempt $attempt of $max_attempts)${c_reset}" >&2
      sleep 30
    fi
    ((attempt++))
  done
  
  return $exit_code
}
check_restic_error() {
  exit_code="${1:-0}"
  latest_cmd="${prev_cmd:-}"
  latest_error
}
latest_error() {
  if [[ "$exit_code" != "0" ]] ; then
    if [[ -n "$rest_cmd" ]] ; then
      error_message="[$rest_cmd] failed; exit code $exit_code"
    else
      local cmd1 cmd2 _
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
opsys() {
  case "$unix_name" in
    Linux|GNU)
      if [[ "$(uname -o)" = "Android" ]] ; then
        os="$(uname -o)"
        os_vers="$(getprop ro.build.version.release)"
        printf "%b\n" "$os" "$os_vers"
      else
        if command -v lsb_release >/dev/null 2>&1 ; then
          lsb_release -ds
        elif [[ -s /etc/os-release ]] ; then
          (source /etc/os-release 2>/dev/null && printf "%s\n" "$PRETTY_NAME")
        elif [[ -s /etc/issue.net ]] ; then
          cat /etc/issue.net
        else
          printf "%s\n" "Unknown Linux OS ($(uname -m))"
        fi
      fi
      ;;
    FreeBSD|NetBSD|OpenBSD)
      uname -rs
      ;;
    Darwin)
      os="$(sw_vers -productName)"
      os_vers="$(sw_vers -productVersion)"
      printf "%b\n" "$os" "$os_vers"
      ;;
    *)
      printf "%b\n" "Unknown OS"
      ;;
  esac
}
duration() {
  if [[ "$SECONDS" -eq 0 ]] ; then
    printf "%s\n" "0 seconds"
    return
  fi
  local dur=()
  local d="$((SECONDS/60/60/24))"
  local h="$((SECONDS/60/60%24))"
  local m="$((SECONDS/60%60))"
  local s="$((SECONDS%60))"
  local days="days"
  local hrs="hours"
  local min="minutes"
  local sec="seconds"
  local ndur=0
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
    4) printf "%s\n" "${dur[0]}, ${dur[1]}, ${dur[2]} and ${dur[3]}" ;;
    3) printf "%s\n" "${dur[0]}, ${dur[1]} and ${dur[2]}" ;;
    2) printf "%s\n" "${dur[0]} and ${dur[1]}" ;;
    1) printf "%s\n" "${dur[0]}" ;;
    0) printf "%s\n" "Too fast!" ;;
  esac
}
set_state() {
  local key="$1"
  local value="$2"
  local state_file="$3"
  
  local state_name
  state_name=$(basename "$state_file")
  
  (
    if command -v flock >/dev/null 2>&1; then
      flock -x 200
    fi
    
    if [[ ! -f "$state_file" ]]; then
      printf "%s\n" "${key}=${value}" > "$state_file"
    else
      grep -v "^${key}=" "$state_file" > "${state_file}.tmp" 2>/dev/null || true
      printf "%s\n" "${key}=${value}" >> "${state_file}.tmp"
      mv "${state_file}.tmp" "$state_file"
    fi
  ) 200> "${lock_dir}/${state_name}.lock"
}
get_state() {
  local key="$1"
  local state_file="$2"
  
  if [[ -f "$state_file" ]]; then
    grep "^${key}=" "$state_file" | cut -d'=' -f2
  else
    printf "%s\n" "0"
  fi
}
now_next() {
  now=$(date +"%s")

  local state_file="$config_dir/$repo.state"
  local old_datefile="$config_dir/$repo-datefile"

  # Seamless migration for existing users
  if [[ ! -f "$state_file" && -f "$old_datefile" ]]; then
    local old_val
    old_val=$(cat "$old_datefile" 2>/dev/null || true); old_val="${old_val:-0}"
    set_state "NEXT_CLEANUP" "$old_val" "$state_file"
    rm -f "$old_datefile"
  fi

  next=$(get_state "NEXT_CLEANUP" "$state_file")
  
  if ! [[ "$next" =~ ^[0-9]+$ ]] ; then
    next=0
  fi
}

# UI and Progress Utilities
wait_with_spinner() {
  local label="$1"
  shift
  local pids=("$@")
  local spin='-\|/'
  local i=0
  while true; do
    local any_running=false
    for pid in "${pids[@]}"; do
      kill -0 "$pid" 2>/dev/null && any_running=true && break
    done
    [[ "$any_running" == "true" ]] || break
    i=$(( (i+1) % 4 ))
    printf "\r%b%s %s%b" "$c_cyan" "$label" "${spin:$i:1}" "$c_reset"
    sleep 0.1
  done
  wait "${pids[@]}" 2>/dev/null || true
}
_require_sudo() {
  local action_desc="${1:-operation}"
  if [[ "$EUID" -ne 0 ]]; then
    # Check if sudo requires a password
    if ! sudo -n true 2>/dev/null; then
      printf "%b\n" "\n${c_yellow}The $action_desc requires elevated privileges.${c_reset}"
      printf "%s\n" "Please enter your sudo password to proceed."
      printf "\n"
    fi
    return 1
  fi
  return 0
}
get_repo_list() {
  local excluded=("$@")
  repos=()
  for conf in "$config_dir"/*.conf; do
    [ -e "$conf" ] || continue
    local name
    name=$(basename "$conf" .conf)
    [[ "$name" == "global" ]] && continue
    if ! array_contains "$name" ${excluded[@]:+"${excluded[@]}"}; then
      repos+=("$name")
    fi
  done
}
run_with_spinner() {
  local cmd="$1"
  local label="${2:-Working}"
  
  # Hide cursor
  hide_cursor
  
  printf "%b " "$label"
  
  # Execute the command in the background, suppressing stdout/stderr
  local err_file="$session_tmp/hook_err"
  bash -c "$cmd" > "$err_file" 2>&1 &
  local pid=$!
  
  local spin='-\|/'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
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
    if [[ -s "$err_file" ]]; then
      printf "%b\n" "${c_yellow}--- Error Output ---${c_reset}"
      cat "$err_file"
      printf "%b\n" "${c_yellow}--------------------${c_reset}"
    fi
  fi
  
  
  return $exit_code
}
logger() {
  if [[ "$log_flag" = "true" ]] ; then
    log="$logs_dir/$repo-$(date +%Y-%m-%d-%H%M%S).log"
    if [[ "$quiet_flag" == "true" ]]; then
      exec > "$log" 2>&1
    else
      exec > >(tee -a "$log") 2>&1
    fi
    if [[ "$LOG_RETENTION" =~ ^[0-9]+$ ]] && [ "$LOG_RETENTION" -gt 0 ]; then
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
time_start() {
  if [[ "$time_flag" = "true" ]] ; then
    SECONDS=0
  fi
}
time_end() {
  if [[ "$time_flag" = "true" ]] ; then
    print_line
    printf "%b\n" "${c_white}Duration:${c_reset} ${c_green}$(duration)${c_reset}"
  fi
}
rescript_lock() {
  if [[ "${rescript_lock_created:-}" == "true" ]]; then return 0; fi
  if [[ -e "$lock" ]]; then
    local existing_pid=""
    existing_pid=$(cat "$lock" 2>/dev/null || true)
    
    if is_pid_alive "$existing_pid"; then
      printf "%s\n" "WARNING: [$repo] repo is already running (PID: $existing_pid)..."
      printf "%s\n" "If you are sure $repo is not running, type"
      printf "%s\n" " "
      printf "%s\n" "  rescript $repo unlocker"
      printf "%s\n" " "
      printf "%s\n" "This will remove the lock for [$repo] repository."
      latest_cmd="$cmd"
      exit_code="1"
      latest_error
    else
      printf "%s\n" "INFO: Found stale lock file for [$repo] (PID: $existing_pid is dead). Overwriting..."
      rm -f "$lock" 2>/dev/null
    fi
  fi
  
  # Atomic lock creation with PID
  set -C
  if printf "%s\n" "$$" > "$lock" 2>/dev/null; then
    set +C
    rescript_lock_created="true"
  else
    set +C
    printf "%s\n" "ERROR: Failed to acquire lock for [$repo]."
    exit 1
  fi
}
debug_start() {
  if [[ "$debug_flag" = "true" ]] ; then
    set -xv
  fi
}
debug_stop() {
  if [[ "$debug_flag" = "true" ]] ; then
    set +xv
  fi
}
set_sim_flag() {
  local cmd_name="${1:-}"
  sim_flags=()
  if [[ -n "${2:-}" ]]; then
    sim_flags=( "$2" )
  fi
  if [[ "$simulate_flag" == "true" ]]; then
    printf "%b\n" "${c_yellow}SIMULATE: $cmd_name running in dry-run mode.${c_reset}"
    sim_flags=( --dry-run )
  fi
}
_run_post_actions() {
  if [[ "$check_flag" = "true" ]] ; then
    print_line
    printf "%b\n" "${c_cyan}Starting check...${c_reset}"
    run_quietly run_restic_with_retry check --cleanup-cache
  fi
  if [[ "$info_flag" = "true" ]] ; then
    run_quietly statinfo
  fi
}
source_config() {
  local conf_file="$1"
  local bash_err
  if ! bash_err=$(bash -n "$conf_file" 2>&1); then
    printf "%b\n" "${c_red}FATAL ERROR: Rescript found a syntax error in your configuration file!${c_reset}"
    printf "%b\n" "${c_yellow}File: $conf_file${c_reset}"
    printf "%b\n" "${c_yellow}Details: $bash_err${c_reset}"
    printf "%b\n" "${c_yellow}Please verify your configuration file for missing quotes, unmatched brackets, or invalid syntax.${c_reset}"
    exit 2
  fi
  source "$conf_file"
}
_parse_standard_flags() {
  case "$1" in
    -D|--debug) debug_flag="true" ; return 0 ;;
    -E|--email) force_email="true" ; CONFIRMATION_EMAIL="y" ; return 0 ;;
    -L|--log) log_flag="true" ; return 0 ;;
    -M|--metadata) context_flag="true" ; return 0 ;;
    -Q|--quiet) quiet_flag="true" ; return 0 ;;
    -T|--timer) time_flag="true" ; return 0 ;;
    -W|--webhook) force_webhook="true" ; CONFIRMATION_WEBHOOK="y" ; return 0 ;;
    *) return 1 ;;
  esac
}
parse_generic_args() {
  local help_func="$1"
  shift
  while [[ $# -gt 0 ]] ; do
    if _parse_standard_flags "$1" ; then shift ; continue ; fi
    case "$1" in
      -h|--help) "$help_func" ; exit 0 ;;
      -S|--simulate) 
        printf "%s\n" "[$1] is not a valid option..."
        printf "\n"
        "$help_func"
        exit 1
        ;;
      --) shift ; rest+=( "$@" ) ; break ;;
      -*) rest+=( "$1" ) ;;
      *) rest+=( "$1" ) ;;
    esac
    shift
  done
}
run_quietly() {
  "$@"
}
execute_with_metrics() {
  logger
  print_context
  time_start
  "$@"
  time_end
}

# -----------------------------------------------------------------------------
# Editor Migration and Just-in-Time Initialization
# -----------------------------------------------------------------------------


if [[ -n "${RESCRIPT_EDITOR:-}" ]]; then
  rescript_editor="$RESCRIPT_EDITOR"
  rm -f "$config_dir/.editor" 2>/dev/null || true
elif [[ -s "$config_dir/.editor" ]]; then
  rescript_editor=$(<"$config_dir/.editor")
  if [[ -f "$config_global" ]]; then
    grep -v "^RESCRIPT_EDITOR=" "$config_global" > "${config_global}.tmp" 2>/dev/null || true
    printf "%s\n" "RESCRIPT_EDITOR=\"$rescript_editor\"" >> "${config_global}.tmp"
    mv "${config_global}.tmp" "$config_global"
  fi
  rm -f "$config_dir/.editor"
else
  rm -f "$config_dir/.editor" 2>/dev/null || true
  rescript_editor=""
fi
