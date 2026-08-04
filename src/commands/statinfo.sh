# ============================================================== #
#                          COMMAND: INFO                         #
# ============================================================== #

function statinfo {
  local target_host="${host_flag:-$rhost}"
  debug_start
  latest_host_stat=$(restic stats --host "$target_host" latest | awk -F': ' '/Total Size/{print $2}')
  debug_stop
  check_restic_error $?
  print_progress "Calculating repo stats" 25
  
  debug_start
  host_stat=$(restic stats --mode raw-data --host "$target_host" latest | awk -F': ' '/Total Size/{print $2}')
  debug_stop
  check_restic_error $?
  print_progress "Calculating repo stats" 50
  
  debug_start
  stat_restore_size=$(restic stats --host "$target_host" | awk -F': ' '/Total Size/{print $2}')
  debug_stop
  check_restic_error $?
  print_progress "Calculating repo stats" 75
  
  debug_start
  stat_raw_data=$(restic stats --mode raw-data --host "$target_host" | awk -F': ' '/Total Size/{print $2}')
  debug_stop
  check_restic_error $?
  print_progress "Calculating repo stats" 100
  
  echo -ne '\n'
  echo ""
  print_line "="
  printf "${c_white}%-20s | %-18s | %-20s${c_reset}\n" "Summarized Info" "Restore Size" "Deduplicated Size"
  print_line "="
  printf "%-20s | %-18s | %-20s\n" "Latest Snapshot" "$latest_host_stat" "$host_stat"
  printf "%-20s | %-18s | %-20s\n" "All Snapshots" "$stat_restore_size" "$stat_raw_data"
}
