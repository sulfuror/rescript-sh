function automatic {
  if [[ -n "$PRE_CMD" ]] ; then
    echo -e "$yellow""[Running PRE_CMD...]""$endcolor"
    if [[ "$simulate_flag" == "true" ]]; then
      echo "SIMULATE: $PRE_CMD"
    else
      eval "$PRE_CMD"
      if [[ $? -ne 0 ]] ; then
        echo -e "$yellow""PRE_CMD failed. Exiting...""$endcolor"
        exit 1
      fi
    fi
  fi
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
  print_line
  # Snapshot List
  case "$SHOW_SNAPS" in
    y|yes)
      echo -e "$yellow""[Snapshots List...]""$endcolor"
      snaps
      print_line
      latest_cmd=$prev_cmd exit_code="$?"
      latest_error
      ;;
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
        print_line
        echo -e "$yellow""[Checking for Errors in Repo...]""$endcolor"
        restic check --cleanup-cache
        latest_cmd=$prev_cmd exit_code="$?"
        latest_error
        print_line
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
            echo -e "$yellow""WARNING: \nCLEAN is set to $CLEAN in your configuration file; please use the correct syntax as follows:"$endcolor" \n1. CLEAN=""$CLEAN"days"     <---setup cleanup every $CLEAN days\n2. CLEAN=""$CLEAN"hours"    <---setup cleanup every $CLEAN hours\n3. CLEAN=""$CLEAN"minutes"  <---setup cleanup every $CLEAN minutes"
          else
            echo -e "$yellow""[Done Cleaning; Next Cleanup and Check Will Be Done in $clean_num $clean_unit...]""$endcolor"
          fi
        fi
      fi
    fi
  else 
      if [[ -n "${policies[*]}" ]] ; then
        echo -e "$yellow""[Cleaning Repo...]""$endcolor"
        cleanup
        print_line
        echo -e "$yellow""[Checking for Errors in Repo...]""$endcolor"
        restic check --cleanup-cache
        latest_cmd=$prev_cmd exit_code="$?"
        latest_error
      fi
  fi
  # Stats
  case "$SHOW_STATS" in
    y|yes) statinfo ;;
  esac
  # Time and Runtime
  time_end
  if [[ -n "$POST_CMD" ]] ; then
    echo -e "$yellow""[Running POST_CMD...]""$endcolor"
    if [[ "$simulate_flag" == "true" ]]; then
      echo "SIMULATE: $POST_CMD"
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
  if [[ -n "$RESTIC_COMPRESSION" ]] ; then
    bu_opts+=( --compression="$RESTIC_COMPRESSION" )
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
  local sim_flag=""
  if [[ "$simulate_flag" == "true" ]]; then
    echo "SIMULATE: Backup running in dry-run mode."
    sim_flag="--dry-run"
  fi
  if [[ "$skip_flag" = "true" ]] ; then
    restic backup $sim_flag --verbose "${bu_opts[@]}" --exclude-file=<(find $BACKUP_DIR -iname ".~lock.*" 2> /dev/null | sed -e 's/.~lock.//g' | sed -e 's/#//g') --exclude=".~lock.*" "${rest[@]}" $BACKUP_DIR
  else
    restic backup $sim_flag --verbose "${bu_opts[@]}" "${rest[@]}" $BACKUP_DIR
  fi
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error

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
  latest_host_stat=$(restic stats --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  print_progress "Calculating repo stats" 25
  
  host_stat=$(restic stats --mode raw-data --host "$rhost" latest | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  print_progress "Calculating repo stats" 50
  
  stat_restore_size=$(restic stats | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  print_progress "Calculating repo stats" 75
  
  stat_raw_data=$(restic stats --mode raw-data | grep 'Total Size' | sed 's/Total Size: //g')
  latest_cmd=$prev_cmd exit_code="$?"
  latest_error
  print_progress "Calculating repo stats" 100
  
  echo -ne '\n'
  debug_stop
  
  printf "\e[1m%-$((cols/4))s %$((cols/3))s %$((cols/3))s\e[0m\n" "Summarized Info" "Restore Size" "Deduplicated Size"
  print_line
  printf "%-$((cols/4))s %$((cols/3))s %$((cols/3))s\n" "Latest Snapshot" "$latest_host_stat" "$host_stat"
  printf "%-$((cols/4))s %$((cols/3))s %$((cols/3))s\n" "All Snapshots" "$stat_restore_size" "$stat_raw_data"
  if [[ "$cmd" = "info" ]] ; then
    time_end
  fi
}

function size {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a path inside the repository."
    exit 1
  fi
  
  echo "Calculating total size... (this may take a moment)"
  debug_start
  local total_size=$(restic ls -l --recursive latest "${rest[@]}" 2>/dev/null | awk '
    /^[-dcbp](r|-)[w|-](x|-)(r|-)[w|-](x|-)(r|-)[w|-](x|-)/ { sum += $4 }
    END {
      if (sum >= 1024^3) printf "%.2f GB\n", sum / (1024^3)
      else if (sum >= 1024^2) printf "%.2f MB\n", sum / (1024^2)
      else if (sum >= 1024) printf "%.2f KB\n", sum / 1024
      else printf "%d B\n", sum
    }
  ')
  debug_stop
  
  if [[ -z "$total_size" || "$total_size" == "0 B" ]] ; then
    echo "Path not found or empty."
  else
    echo -e "\nTotal size for [${rest[*]}] in latest snapshot: \e[1m$total_size\e[0m"
  fi
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

  local sim_flag=""
  if [[ "$simulate_flag" == "true" ]]; then
    echo "SIMULATE: Cleanup running in dry-run mode."
    sim_flag="--dry-run"
  fi

  if [[ -n "${policies[*]}" ]] ; then
    debug_start
    restic forget $sim_flag "${policies[@]}" "${rest[@]}"
    latest_cmd=$prev_cmd exit_code="$?"
    debug_stop
    latest_error
    debug_start
    restic prune $sim_flag --cleanup-cache
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
    echo -e "$yellow""Next cleanup and check in $days $d...""$endcolor"
  elif [[ "$hours" -gt "0" ]] ; then
    echo -e "$yellow""Next cleanup and check in $hours $h...""$endcolor"
  elif [[ "$minutes" -gt "0" ]] ; then
    echo -e "$yellow""Next cleanup and check in $minutes $m...""$endcolor"
  elif [[ "$seconds" -gt "0" ]] ; then
    echo -e "$yellow""Next cleanup and check in $seconds $s...""$endcolor"
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
  
  local c1=$((cols/6))
  local c2=$((cols/4))
  local c3=$((cols/5))
  local c4=$((cols/5))

  printf "\e[1m%-*s %-*s %-*s %-*s %s\e[0m\n" "$c1" "Snapshot" "$c2" "Date" "$c3" "Host" "$c4" "Tag" "Path"
  print_line
  
  local snaps_output=$(restic snapshots -q)
  
  restic find "${rest[@]}" | awk -v snaps="$snaps_output" -v c1="$c1" -v c2="$c2" -v c3="$c3" -v c4="$c4" '
  BEGIN {
    n = split(snaps, lines, "\n")
    for (i=1; i<=n; i++) {
       if (lines[i] ~ /^[0-9a-fA-F]{8} /) {
          split(lines[i], f, " ")
          id = f[1]
          date[id] = f[2] " " f[3]
          host[id] = f[4]
          if (f[5] ~ /^\// || f[5] ~ /^C:/ || f[5] ~ /^\[/) {
             tag[id] = "-"
          } else {
             tag[id] = f[5]
          }
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
      printf "%-*s %-*s %-*s %-*s %s\n", c1, snap, c2, date[snap], c3, host[snap], c4, tag[snap], $0
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
  
  local col_snap=10
  local col_date=21
  local col_size=12
  local col_path=$(( cols - col_snap - col_date - col_size - 4 ))
  
  printf "\e[1m%-10s %-21s %-12s %s\e[0m\n" "Snapshot" "Date" "Size" "Path"
  print_line
  
  restic find -l "${rest[@]}" 2>/dev/null | awk -v path_len=$col_path '
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
      if (size_val >= 1024^3) size_str = sprintf("%.1fG", size_val / (1024^3))
      else if (size_val >= 1024^2) size_str = sprintf("%.1fM", size_val / (1024^2))
      else if (size_val >= 1024) size_str = sprintf("%.1fK", size_val / 1024)
      else size_str = sprintf("%dB", size_val)
      
      date = $5 " " $6
      path = $7
      for (j=8; j<=NF; j++) {
          path = path " " $j
      }
      printf "%-10s %-21s %-12s %s\n", snap, date, size_str, path
  }'
  
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "History search failed or no matches found."
  fi
  debug_stop
}

function differ {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    local snaps=($(restic snapshots -q | grep -E "^[a-z0-9]{8} " | tail -n 2 | awk '{print $1}'))
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
  
  local dest_name="$(basename "$file")"
  if [[ -d "./$dest_name" ]] ; then
    dest_name="${dest_name}_extracted"
  fi
  
  echo "Extracting [$file] to [./$dest_name]..."
  
  local restic_args=()
  if [[ ${#extract_rest[@]} -eq 0 ]] ; then
    echo "Auto-detecting latest snapshot for this file..."
    local snap_id=$(restic find "$file" 2>/dev/null | tr -d '\r' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/Found matching entries in snapshot/ { for(i=1;i<=NF;i++) if($i=="snapshot") snap=$(i+1) } END { print snap }')
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
  
  while kill -0 $pid 2>/dev/null; do
    print_progress "Extracting file" "$progress"
    progress=$(( progress + 5 ))
    if [[ $progress -ge 100 ]]; then
      progress=0
    fi
    sleep 0.2
  done
  
  wait $pid
  local exit_code=$?
  
  if [[ $exit_code -eq 0 ]] ; then
    print_progress "Extracting file" 100
    echo -ne '\nExtraction complete.\n'
  else
    echo -ne '\nExtraction failed. Restic error:\n'
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
    echo "Repository mounted in background at: $rmount"
    echo "Use [rescript $repo umounter] to unmount."
  else
    restic mount "${clean_rest[@]}" "$rmount"
    rm -rf "$rmount"
  fi
}

function umounter {
  rescript_lock
  debug_start
  local pid_file="/tmp/rescript_mount_${repo}.pid"
  if [[ ! -f "$pid_file" ]] ; then
    echo "No background mount found for repository [$repo]."
    exit 1
  fi
  
  local data=$(<"$pid_file")
  local pid="${data%%:*}"
  local rmount="${data#*:}"
  
  echo "Unmounting repository at $rmount..."
  if command -v fusermount >/dev/null 2>&1; then
    fusermount -u "$rmount"
  else
    umount "$rmount"
  fi
  
  sleep 1
  rm -rf "$rmount"
  rm -f "$pid_file"
  echo "Successfully unmounted."
  debug_stop
}

function non_opt {
  case "$cmd" in
  backup|cleanup|diff|env|extract|history|info|logs|mounter|restorer|search|size|snaps|umounter|unlocker|upgrade)
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
  restic "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  rest_cmd="${rest[0]}"
  case "$rest_cmd" in
    --repo=*) rest_cmd="${rest[1]}" ;;
    -r*|--repo*) rest_cmd="${rest[2]}" ;;
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
  restic snapshots --compact "${rest[@]}"
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
    print_line "="
    printf "%$(((cols + ${#title}) / 2))s\n" "$title" | tr '[:lower:]' '[:upper:]'
    print_line "="
    echo -e "$yellow""Date and Time:""$endcolor" "$(date +%a\ %b\ %d\ %Y\ %r)"
    echo -e "$yellow""System:""$endcolor" "$(opsys)"
    echo -e "$yellow""Hostname:""$endcolor" "$rhost"
    echo -e "$yellow""Repository Location:""$endcolor" "$dest"
    echo -e "$yellow""Restic Version:""$endcolor" "$(restic version | awk '{print $2}')"
    print_line
  fi
}

function time_end {
  if [[ ! "$cmd" ]] ; then
    footer="SCRIPT ENDED"
  else
    footer="$cmd ended"
  fi
  if [[ "$time_flag" = "true" ]] ; then
    print_line
    echo -e "$yellow""End:""$endcolor" "$(date +%a\ %b\ %d\ %Y\ %r)"
    echo -e "$yellow""Duration:""$endcolor" "$(duration)"
    print_line "="
    printf "%$(((${cols} + ${#footer}) / 2))s\n" "$footer" | tr '[:lower:]' '[:upper:]'
    print_line "="
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

function upgrade_repo {
  rescript_lock
  logger
  time_start
  debug_start
  echo -e "$yellow[Upgrading repository format to version 2...]$endcolor"
  restic migrate upgrade_repo_v2 "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
  time_end
}
if [[ ! $(command -v restic) ]] ; then
  echo "***$(basename $0) warning***"
  echo "[restic] not found..."
  echo ""
  exit 1
fi
