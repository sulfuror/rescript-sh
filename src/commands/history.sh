# ============================================================== #
#                         COMMAND: HISTORY                       #
# ============================================================== #

function history {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a pattern or file path to search history for."
    exit 1
  fi
  
  local col_no=5
  local col_snap=10
  local col_date=21
  local col_size=12
  
  local tmp_history="$session_tmp/history"
  
  (
    debug_start
    run_restic_with_retry find --json "${rest[@]}" 2>/dev/null | awk '
    /"snapshot":/ {
      match($0, /"snapshot": *"([^"]+)"/)
      snap = substr($0, RSTART, RLENGTH)
      sub(/"snapshot": *"/, "", snap)
      sub(/"/, "", snap)
      snap = substr(snap, 1, 8)
    }
    /"path":/ {
      match($0, /"path": *"([^"]+)"/)
      path = substr($0, RSTART, RLENGTH)
      sub(/"path": *"/, "", path)
      sub(/"/, "", path)
    }
    /"mtime":/ {
      match($0, /"mtime": *"([^"]+)"/)
      date = substr($0, RSTART, RLENGTH)
      sub(/"mtime": *"/, "", date)
      sub(/"/, "", date)
      sub(/T/, " ", date)
      date = substr(date, 1, 19)
    }
    /"size":/ {
      match($0, /"size": *([0-9]+)/)
      size_val = substr($0, RSTART, RLENGTH)
      sub(/"size": */, "", size_val)
      size_val = size_val + 0
      has_size = 1
    }
    /}/ {
      if (has_size) {
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
          has_size = 0
      }
    }' > "$tmp_history"
    
    # Capture the pipeline status of run_restic_with_retry
    exit ${PIPESTATUS[0]}
  ) & local pid=$!
  
  # shellcheck disable=SC2064
  trap "kill $pid 2>/dev/null; cleanup_on_exit; exit 130" INT
  
  wait_with_spinner "Searching history across snapshots..." "$pid"
  
  local exit_code=0
  wait "$pid" || exit_code=$?
  trap - INT
  
  printf "\r\e[K"
  
  if [ "$exit_code" -ne 0 ]; then
    printf "%b\n" "${c_red}History search failed due to a repository or connection error.${c_reset}"
  else
    if [[ -s "$tmp_history" ]]; then
      print_line "="
      printf "${c_white}%-4s | %-10s | %-21s | %-12s | %s${c_reset}\n" "No" "Snapshot" "Date" "Size" "Path"
      print_line "="
      cat "$tmp_history"
    else
      printf "%b\n" "${c_red}No history found for the given pattern.${c_reset}"
    fi
  fi
}
