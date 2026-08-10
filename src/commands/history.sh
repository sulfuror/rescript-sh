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
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-12s | %s${c_reset}\n" "No" "Snapshot" "Date" "Size" "Path"
  print_line "="
  
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
  }'
  local pipe_status=("${PIPESTATUS[@]}")
  debug_stop
  
  if [ "${pipe_status[0]}" -ne 0 ]; then
    echo "History search failed due to a repository or connection error."
  fi
}
