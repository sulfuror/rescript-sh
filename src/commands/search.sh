# ============================================================== #
#                       COMMAND: SEARCH                          #
# ============================================================== #

function search {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a search pattern."
    exit 1
  fi
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-15s | %s${c_reset}\n" "No" "Snapshot" "Date" "Host" "Path"
  print_line "="
  
  local snaps_output
  debug_start
  snaps_output=$(run_restic_with_retry snapshots -q)
  
  run_restic_with_retry find "${rest[@]}" | awk -v snaps="$snaps_output" '
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
