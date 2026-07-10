function statinfo {
  debug_start
  local target_host="${host_flag:-$rhost}"
  latest_host_stat=$(restic stats --host "$target_host" latest | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
  check_restic_error $?
  print_progress "Calculating repo stats" 25
  
  host_stat=$(restic stats --mode raw-data --host "$target_host" latest | grep 'Total Size' | sed 's/Total Size: //g' | sed 's/^[ \t]*//')
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

