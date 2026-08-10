# ============================================================== #
#                       COMMAND: SEARCH                          #
# ============================================================== #

function search {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a search pattern."
    exit 1
  fi
  
  local tmp_search="$session_tmp/search"
  (
    debug_start
    local snaps_output
    snaps_output=$(run_restic_with_retry snapshots -q 2>/dev/null || true)
    
    run_restic_with_retry find "${rest[@]}" 2>/dev/null | awk -v snaps="$snaps_output" '
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
    }' > "$tmp_search"
    debug_stop
  ) & local pid=$!
  
  # shellcheck disable=SC2064
  trap "kill $pid 2>/dev/null; cleanup_on_exit; exit 130" INT
  
  wait_with_spinner "Searching for [${rest[*]}]..." "$pid"
  
  wait "$pid" 2>/dev/null || true
  trap - INT
  
  printf "\r\e[K"
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-15s | %s${c_reset}\n" "No" "Snapshot" "Date" "Host" "Path"
  print_line "="
  
  if [[ -s "$tmp_search" ]]; then
    cat "$tmp_search"
  fi
}
