function automatic {
  rescript_lock
  case "$LOGGING" in
    y|yes)
      log_flag="true"
      ;;
  esac
  time_flag="true"
  context_flag="true"
  logger
  time_start
  print_context
  context_flag="false"

  if [[ -n "$PRE_CMD" ]] ; then
    echo -e "${c_cyan}Running PRE_CMD...${c_reset}"
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_yellow}SIMULATE: $PRE_CMD${c_reset}"
    else
      eval "$PRE_CMD"
      if [[ $? -ne 0 ]] ; then
        echo "PRE_CMD failed. Exiting..."
        exit 1
      fi
    fi
  fi

  function _run_auto_cleanup {
    if [[ -n "${policies[*]}" ]] ; then
      print_line
      echo -e "${c_cyan}Cleaning Repo...${c_reset}"
      cleanup
      print_line
      echo -e "${c_cyan}Checking for Errors in Repo...${c_reset}"
      restic check --cleanup-cache
      check_restic_error $?
    fi
  }
  # Backup
  case "$SKIP_OFFICE" in
    y|yes)
      echo -e "${c_cyan}Taking a Snapshot...${c_reset}" ; skip_flag="true" ; backup ;;
    *)
      echo -e "${c_cyan}Taking a Snapshot...${c_reset}" ; backup ;;
  esac
  exclusions=$(grep -E -v -n -c '(^#|^\s*$|^\s*\t*#)' "$excludes")
  if [[ "$exclusions" -gt "0" ]] ; then
    echo -e "${c_green}There are $exclusions exclusion rules...${c_reset}"
  fi
  # Snapshot List
  case "$SHOW_SNAPS" in
    y|yes)
      print_line
      echo -e "${c_cyan}Snapshots List...${c_reset}"
      snaps
      check_restic_error $?
      ;;
  esac
  # Check and Clean Repo Based on User's Policy
  if [[ -f "$config_dir/$repo-datefile" || -n "$CLEAN" ]]; then
    if [[ ! -f "$config_dir/$repo-datefile" ]] ; then
      touch "$config_dir/$repo-datefile"
    fi
    now_next
    if [[ "$now" -lt "$next" ]] ; then
      print_line
      cleanup-next
    else 
        _run_auto_cleanup
        if [[ -n "$CLEAN" ]] ; then
          clean_num="${CLEAN//[A-Za-z]/}"
          clean_unit="${CLEAN//[0-9]/}"
          case "$unix_name" in
            Linux|GNU)
              date -d "now+$CLEAN" +%s 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
            *)
              gdate -d "now+$CLEAN" +%s 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
          esac
          exit_code="$?"
          if [[ "$exit_code" -gt "0" ]] ; then
            echo -e "WARNING: \nCLEAN is set to $CLEAN in your configuration file; please use the correct syntax as follows: \n1. CLEAN=\"${CLEAN}days\"     <---setup cleanup every $CLEAN days\n2. CLEAN=\"${CLEAN}hours\"    <---setup cleanup every $CLEAN hours\n3. CLEAN=\"${CLEAN}minutes\"  <---setup cleanup every $CLEAN minutes"
          else
            echo -e "${c_green}Done Cleaning; Next Cleanup and Check Will Be Done in $clean_num $clean_unit...${c_reset}"
          fi
      fi
    fi
  else 
      _run_auto_cleanup
  fi
  # Stats
  case "$SHOW_STATS" in
    y|yes) 
      print_line
      statinfo 
      ;;
  esac
  # Time and Runtime
  time_end
  if [[ -n "$POST_CMD" ]] ; then
    echo -e "${c_cyan}Running POST_CMD...${c_reset}"
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_yellow}SIMULATE: $POST_CMD${c_reset}"
    else
      eval "$POST_CMD"
    fi
  fi
  if [[ -n "$CLEAN" && -z "${policies[*]}" ]] ; then
    clean_num="${CLEAN//[A-Za-z]/}"
    clean_unit="${CLEAN//[0-9]/}"
    echo "[rescript] noted that your CLEAN variable is $CLEAN, so [rescript] assumes that"
    echo "you want to perform a 'cleanup' (forget, prune and check) every $clean_num $clean_unit but"
    echo "it can't execute it if you have not set the KEEP variables; please set your"
    echo "desired KEEP values in order to perform the 'cleanup' every $clean_num $clean_unit. If you"
    echo "don't want [rescript] to 'cleanup' your repo automatically every $clean_num $clean_unit,"
    echo "just leave the CLEAN variable blank in your cofiguration file and this"
    echo "message will not appear again."
    echo ""
    echo "For more info about this subject:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
  fi
}

function set_sim_flag {
  local cmd_name="$1"
  local default_flag="$2"
  sim_flag="$default_flag"
  if [[ "$simulate_flag" == "true" ]]; then
    echo -e "${c_yellow}SIMULATE: $cmd_name running in dry-run mode.${c_reset}"
    sim_flag="--dry-run"
  fi
}

function backup {
  print_context
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
  if [[ -n "$RESTIC_COMPRESSION" ]] ; then
    bu_opts+=( --compression="$RESTIC_COMPRESSION" )
  fi
  rescript_lock
  debug_start
  set_sim_flag "Backup"
  if [[ "$skip_flag" = "true" ]] ; then
    # shellcheck disable=SC2086
    restic backup $sim_flag --verbose "${bu_opts[@]}" --exclude-file=<(find "$BACKUP_DIR" -iname ".~lock.*" 2> /dev/null | sed -e 's/.~lock.//g' | sed -e 's/#//g') --exclude=".~lock.*" "${rest[@]}" $BACKUP_DIR
  else
    # shellcheck disable=SC2086
    restic backup $sim_flag --verbose "${bu_opts[@]}" "${rest[@]}" $BACKUP_DIR
  fi
  check_restic_error $?
  debug_stop

}




function statinfo {
  latest_host_stat=$(restic stats --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
  check_restic_error $?
  print_progress "Calculating repo stats" 25
  
  host_stat=$(restic stats --mode raw-data --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
  check_restic_error $?
  print_progress "Calculating repo stats" 50
  
  stat_restore_size=$(restic stats | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
  check_restic_error $?
  print_progress "Calculating repo stats" 75
  
  stat_raw_data=$(restic stats --mode raw-data | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
  check_restic_error $?
  print_progress "Calculating repo stats" 100
  
  echo -ne '\n'
  debug_stop
  
  echo ""
  print_line "="
  printf "${c_white}%-20s | %-18s | %-20s${c_reset}\n" "Summarized Info" "Restore Size" "Deduplicated Size"
  print_line "="
  printf "%-20s | %-18s | %-20s\n" "Latest Snapshot" "$latest_host_stat" "$host_stat"
  printf "%-20s | %-18s | %-20s\n" "All Snapshots" "$stat_restore_size" "$stat_raw_data"
}

function size {
  rescript_lock
  local target_host="$rhost"
  if [[ -n "$host_flag" ]] ; then
    target_host="$host_flag"
  fi
  
  local snapshot_id="latest"
  if [[ "${rest[0]}" == "latest" || "${rest[0]}" =~ ^[a-f0-9]{8}$ || "${rest[0]}" =~ ^[a-f0-9]{64}$ ]] ; then
    snapshot_id="${rest[0]}"
    rest=("${rest[@]:1}")
  fi
  
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a path inside the repository."
    exit 1
  fi
  
  print_progress "Calculating total size" 50
  debug_start

  local total_size
  total_size=$(restic ls -l --recursive --host "$target_host" "$snapshot_id" "${rest[@]}" 2>/dev/null | awk '
    /^[-dcbp](r|-)[w|-](x|-)(r|-)[w|-](x|-)(r|-)[w|-](x|-)/ { sum += $4 }
    END {
      if (sum >= 1024^3) printf "%.2f GB\n", sum / (1024^3)
      else if (sum >= 1024^2) printf "%.2f MB\n", sum / (1024^2)
      else if (sum >= 1024) printf "%.2f KB\n", sum / 1024
      else printf "%d B\n", sum
    }
  ')
  debug_stop
  print_progress "Calculating total size" 100
  echo -ne '\n'
  
  if [[ -z "$total_size" || "$total_size" == "0 B" ]] ; then
    echo -e "${c_red}Path not found or empty.${c_reset}"
  else
    echo -e "\n${c_white}Total size for [${rest[*]}] in snapshot ${snapshot_id}:${c_reset} ${c_green}${total_size}${c_reset}"
  fi
}

function cleanup {
  print_context
  rescript_lock

  set_sim_flag "Cleanup"

  if [[ -n "${policies[*]}" ]] ; then
    debug_start
    # shellcheck disable=SC2086
    restic forget $sim_flag "${policies[@]}" "${rest[@]}"
    check_restic_error $?
    debug_stop
    debug_start
    # shellcheck disable=SC2086
    restic prune $sim_flag --cleanup-cache
    check_restic_error $?
    debug_stop
  else
    echo "You have not indicated any policy value..."
    echo "If you want to use [cleanup] option you need to set the [KEEP] variables."
    echo "For more information about the Usage check out the following link:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
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
  seconds=$((result % 60))
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
  if [[ "$seconds" = "1" ]] ; then
    s="second"
  else
    s="seconds"
  fi
  if [[ "$days" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $days $d...${c_reset}"
  elif [[ "$hours" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $hours $h...${c_reset}"
  elif [[ "$minutes" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $minutes $m...${c_reset}"
  elif [[ "$seconds" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $seconds $s...${c_reset}"
  else
    echo -e "${c_cyan}Repo will be cleaned and checked in the next run...${c_reset}"
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
  local title
  local padding

  if [[ "$var_flag" ]] ; then
    upper_var=$(echo "$var_flag" | tr '[:lower:]' '[:upper:]')
    search=$(sed '/^#/ d' < "$config_dir/$repo.conf" | sed '/^\s*$/d' | grep "$upper_var")
    if [[ -z "$search" ]] ; then
      echo "There is no var named [$var_flag]..."
      echo ""
      env-help
      exit 1
    else
      print_line "="
      echo -e "${c_white}Variable: ${c_cyan}$upper_var${c_reset}"
      print_line "="
      
      echo "$search" | awk -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" -F'=' '{
        if (length($1) == 0) next;
        key = $1
        sub(/^[^=]*=/, "", $0)
        printf "  %s%-25s%s : %s%s%s\n", cw, key, cr, cc, $0, cr
      }'
    fi
  else
    print_line "="
    echo -e "${c_white}Configuration Context: ${c_cyan}$repo${c_reset}"
    print_line "="
    
    sed '/^#/ d' < "$config_dir/$repo.conf" | sed '/^\s*$/d' | awk -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" -F'=' '{
      if (length($1) == 0) next;
      key = $1
      sub(/^[^=]*=/, "", $0)
      printf "  %s%-25s%s : %s%s%s\n", cw, key, cr, cc, $0, cr
    }'
  fi
}

function logs {
  if [[ "$catlogs" = "false" && "$removelogs" = "false" ]] ; then
    if ls "$logs_dir/$repo"-* 1> /dev/null 2>&1 ; then
      local log_count
      log_count=$(find "$logs_dir" -maxdepth 1 -type f -name "*$repo*" | wc -l)
      print_line "="
      echo -e "${c_white}Log Files for Context:${c_reset} ${c_cyan}$repo${c_reset}"
      print_line "="
      find "$logs_dir" -maxdepth 1 -type f -name "*$repo*" -exec basename {} \;
      print_line "-"
      echo -e "${c_cyan}Total log files: $log_count${c_reset}"
      echo -e "${c_blue}Your logs are saved at $logs_dir${c_reset}"
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
        echo -e "${c_green}Log files removed for [$repo].${c_reset}"
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
    if [[ -n "$LOG_RETENTION" && "$LOG_RETENTION" -gt 0 ]] 2>/dev/null ; then
      find "$logs_dir" -name "$repo-*.log" -type f -mtime +"$LOG_RETENTION" -exec rm -f {} +
    fi
  else
    exec > >(tee -a "$tmplog") 2>&1
  fi
}

function search {
  rescript_lock
  debug_start
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a search pattern."
    exit 1
  fi
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-15s | %s${c_reset}\n" "No" "Snapshot" "Date" "Host" "Path"
  print_line "="
  
  local snaps_output
  snaps_output=$(restic snapshots -q)
  
  restic find "${rest[@]}" | awk -v snaps="$snaps_output" '
  BEGIN {
    n = split(snaps, lines, "\n")
    for (i=1; i<=n; i++) {
       if (lines[i] ~ /^[0-9a-fA-F]{8} /) {
          split(lines[i], f, " ")
          id = f[1]
          date[id] = f[2] " " f[3]
          host[id] = f[4]
       }
    }
  }
  {
    gsub(/\x1b\[[0-9;]*[a-zA-Z]/, "")
    gsub(/\r/, "")
  }
  /Found matching entries in snapshot/ {
      for(i=1; i<=NF; i++) {
          if ($i == "snapshot") {
              snap = $(i+1)
              break
          }
      }
      next
  }
  /^$/ { next }
  {
      count++
      printf "%-4d | %-10s | %-21s | %-15s | %s\n", count, snap, date[snap], host[snap], $0
  }'
  debug_stop
}

function history {
  rescript_lock
  debug_start
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a pattern or file path to search history for."
    exit 1
  fi
  
  local col_no=5
  local col_snap=10
  local col_date=21
  local col_size=12
  local col_path=$(( cols - col_no - col_snap - col_date - col_size - 7 ))
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-12s | %s${c_reset}\n" "No" "Snapshot" "Date" "Size" "Path"
  print_line "="
  
  restic find -l "${rest[@]}" 2>/dev/null | awk -v path_len="$col_path" '
  {
    gsub(/\x1b\[[0-9;]*[a-zA-Z]/, "")
    gsub(/\r/, "")
  }
  /Found matching entries in snapshot/ {
      for(i=1; i<=NF; i++) {
          if ($i == "snapshot") {
              snap = substr($(i+1), 1, 8)
              break
          }
      }
      next
  }
  /^[-dcbp](r|-)[w|-](x|-)(r|-)[w|-](x|-)(r|-)[w|-](x|-)/ {
      size_val = $4
      date = $5 " " $6
      path = $7
      for (j=8; j<=NF; j++) {
          path = path " " $j
      }
      
      if (size_val != last_size || date != last_date) {
          if (size_val >= 1024^3) size_str = sprintf("%.1fG", size_val / (1024^3))
          else if (size_val >= 1024^2) size_str = sprintf("%.1fM", size_val / (1024^2))
          else if (size_val >= 1024) size_str = sprintf("%.1fK", size_val / 1024)
          else size_str = sprintf("%dB", size_val)
          
          count++
          printf "%-4d | %-10s | %-21s | %-12s | %s\n", count, snap, date, size_str, path
          last_size = size_val
          last_date = date
      }
  }'
  
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "History search failed or no matches found."
  fi
  debug_stop
}

function differ {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    mapfile -t snaps < <(restic snapshots -q | grep -E "^[a-z0-9]{8} " | tail -n 2 | awk '{print $1}')
    if [[ ${#snaps[@]} -lt 2 ]] ; then
      echo "You need at least 2 snapshots to perform a diff."
      exit 1
    fi
    restic diff "${snaps[0]}" "${snaps[1]}"
  else
    restic diff "${rest[@]}"
  fi
}

function extract {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a file path to extract."
    exit 1
  fi
  
  local file=""
  local extract_rest=()
  for (( i=${#rest[@]}-1; i>=0; i-- )); do
    if [[ -z "$file" && "${rest[i]}" != -* ]]; then
      file="${rest[i]}"
    else
      extract_rest=( "${rest[i]}" "${extract_rest[@]}" )
    fi
  done

  if [[ -z "$file" ]] ; then
    echo "You must provide a file path to extract."
    exit 1
  fi
  
  local dest_name
  dest_name="$(basename "$file")"
  if [[ -d "./$dest_name" ]] ; then
    dest_name="${dest_name}_extracted"
  fi
  
  echo "Extracting [$file] to [./$dest_name]..."
  
  local restic_args=()
  if [[ ${#extract_rest[@]} -eq 0 ]] ; then
    echo "Auto-detecting latest snapshot for this file..."
    local snap_id
    snap_id=$(restic find "$file" 2>/dev/null | tr -d '\r' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/Found matching entries in snapshot/ { for(i=1;i<=NF;i++) if($i=="snapshot") snap=$(i+1) } END { print snap }')
    if [[ -z "$snap_id" ]] ; then
      echo "Extraction failed. File [$file] not found in any snapshot."
      exit 1
    fi
    restic_args=( "$snap_id" "$file" )
  else
    restic_args=( "${extract_rest[@]}" "$file" )
  fi
  
  local err_file="/tmp/rescript_extract_err_$$"
  (
    restic dump "${restic_args[@]}" > "./$dest_name" 2> "$err_file"
  ) &
  local pid=$!
  local progress=0
  
  while kill -0 "$pid" 2>/dev/null; do
    print_progress "Extracting file" "$progress"
    progress=$(( progress + 5 ))
    if [[ $progress -ge 100 ]]; then
      progress=0
    fi
    sleep 0.2
  done
  
  wait "$pid"
  local exit_code=$?
  
  if [[ $exit_code -eq 0 ]] ; then
    print_progress "Extracting file" 100
    echo -ne "\n${c_green}Extraction complete.${c_reset}\n"
  else
    echo -ne "\n${c_red}Extraction failed. Restic error:${c_reset}\n"
    cat "$err_file" 2>/dev/null
    rm -f "./$dest_name"
  fi
  rm -f "$err_file"
}

function mounter {
  rescript_lock
  local bg=false
  local clean_rest=()
  for arg in "${rest[@]}"; do
    if [[ "$arg" == "--background" ]]; then
      bg=true
    else
      clean_rest+=("$arg")
    fi
  done

  rmount="$HOME/$repo-repo-$(date +%s)"
  mkdir -p "$rmount"
  
  if [[ "$bg" == "true" ]]; then
    restic mount "${clean_rest[@]}" "$rmount" >/dev/null 2>&1 &
    local pid=$!
    echo "$pid:$rmount" > "/tmp/rescript_mount_${repo}.pid"
    echo -e "${c_green}Repository mounted in background at:${c_reset} ${c_white}$rmount${c_reset}"
    echo -e "${c_cyan}Use [rescript $repo umounter] to unmount.${c_reset}"
  else
    echo -e "${c_cyan}Mounting repository at:${c_reset} ${c_white}$rmount${c_reset}"
    echo -e "${c_cyan}Use another terminal or tool to browse the contents.${c_reset}"
    echo -e "${c_cyan}When finished, press [Ctrl-C] here to unmount.${c_reset}"
    
    local mounter_stopped=false
    stty -echoctl 2>/dev/null # Hide ^C from terminal
    trap 'mounter_stopped=true; stty echoctl 2>/dev/null' INT
    
    restic mount "${clean_rest[@]}" "$rmount" >/dev/null
    
    trap - INT
    stty echoctl 2>/dev/null # Restore terminal behavior
    
    # Allow Restic to unmount FUSE gracefully
    sleep 0.5
    if mountpoint -q "$rmount" 2>/dev/null; then
      fusermount -u "$rmount" 2>/dev/null || umount "$rmount" 2>/dev/null
      sleep 0.5
    fi
    
    rm -rf "$rmount" 2>/dev/null
    
    if [ "$mounter_stopped" = "true" ]; then
      echo -e "\n${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    else
      echo -e "${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    fi
  fi
}

function umounter {
  rescript_lock
  debug_start
  local pid_file="/tmp/rescript_mount_${repo}.pid"

  if [[ -f "$pid_file" ]]; then
    IFS=':' read -r pid mount_point < "$pid_file"
    if kill -0 "$pid" 2>/dev/null; then
      echo -e "${c_cyan}Stopping mounter process (PID: $pid)...${c_reset}"
      kill -15 "$pid"
      sleep 1
      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid"
      fi
      echo -e "${c_green}Mounter process stopped.${c_reset}"
    fi

    if [[ -d "$mount_point" ]]; then
      if mountpoint -q "$mount_point"; then
        echo -e "${c_cyan}Unmounting repository from:${c_reset} ${c_white}$mount_point${c_reset}"
        if ! fusermount -u "$mount_point" 2>/dev/null; then
          umount "$mount_point" 2>/dev/null
        fi
      fi
      rmdir "$mount_point" 2>/dev/null
      echo -e "${c_green}Mount point cleaned up.${c_reset}"
    fi
    rm -f "$pid_file"
  else
    echo -e "${c_cyan}No background mounter found for repository:${c_reset} ${c_white}$repo${c_reset}"
  fi
  debug_stop
  exit 0
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

function rescript_lock {
  if [[ "$rescript_lock_created" == "true" ]]; then return 0; fi
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

function restic_alone {
  rescript_lock
  debug_start
  restic "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  rest_cmd="${rest[0]}"
  case "$rest_cmd" in
    --repo=*) rest_cmd="${rest[1]}" ;;
    -r*|--repo*) rest_cmd="${rest[2]}" ;;
  esac
  latest_error
}

function restorer {
  rescript_lock
  if [[ "$host_flag" ]] ; then
    restore_dir="$HOME/restore-latest-host-${host_flag}_$(date +%s)"
    restore_opts="--host $host_flag"
  elif [[ "$path_flag" ]] ; then
    restore_dir="$HOME/restore-latest-by-path_$(date +%s)"
    restore_opts="--path $path_flag"
  elif [[ "$tag_flag" ]] ; then
    restore_dir="$HOME/restore-latest-tag-${tag_flag}_$(date +%s)"
    restore_opts="--tag $tag_flag"
  else
    restore_dir="$HOME/restore-ID-${snap_flag}_$(date +%s)"
    snap_id="$snap_flag"
  fi
  print_context
  echo -e "${c_cyan}Restoring from:${c_reset} ${c_white}$dest...${c_reset}"

  set_sim_flag "Restorer" "--verify"

  if [[ "$snap_id" ]] ; then
    debug_start
    # shellcheck disable=SC2086
    restic restore "$snap_id" --target "$restore_dir" $sim_flag
    check_restic_error $?
    debug_stop
  else
    debug_start
    # shellcheck disable=SC2086
    restic restore latest --target "$restore_dir" $restore_opts $sim_flag
    check_restic_error $?
    debug_stop
  fi
  report_errors
}

function snaps {
  if [[ "$cmd" != "snaps" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  debug_start
  restic snapshots --compact "${rest[@]}" | awk -v w="$cols" -v cw="${c_white}" -v cr="${c_reset}" -v cg="${c_gray}" '
    { gsub(/\r/, "") }
    /^-+$/ {
      count++
      if (count == 1) {
        printf "%s", cg
        for(i=1; i<=w; i++) printf "="; printf "%s\n", cr
        next
      } else if (count == 2) {
        printf "%s", cg
        for(i=1; i<=w; i++) printf "-"; printf "%s\n", cr
        next
      }
    }
    count == 0 {
      printf "%s", cg
      for(i=1; i<=w; i++) printf "="; printf "%s\n", cr
      print cw $0 cr
      next
    }
    { print }
  '
  latest_cmd=$prev_cmd exit_code="${PIPESTATUS[0]}"
  debug_stop
  latest_error
}

function unlocker {
  if [[ ! -e "$lock" ]]; then
    echo -e "${c_cyan}No locks found...${c_reset}"
  else
    rm -rf "${lock:?}"
    echo -e "${c_green}Script unlocked...${c_reset}"
  fi
}

# ============================================================== #
# Call Commands and Functions Related to a Repository            #
# ============================================================== #

function upgrade_repo {
  rescript_lock
  debug_start
  echo "[Upgrading repository format to version 2...]"
  restic migrate upgrade_repo_v2 "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
}
if [[ ! $(command -v restic) ]] ; then
  echo "***$(basename "$0") warning***"
  echo "[restic] not found..."
  echo ""
  exit 1
fi

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
