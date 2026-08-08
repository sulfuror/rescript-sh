# ============================================================== #
#                          COMMAND: INFO                         #
# ============================================================== #

function statinfo {
  local target_host="${host_flag:-$rhost}"
  hide_cursor
  
  local tmp1="$session_tmp/stat1"
  local tmp2="$session_tmp/stat2"
  local tmp3="$session_tmp/stat3"
  local tmp4="$session_tmp/stat4"
  
  debug_start
  ( run_restic_with_retry stats --host "$target_host" latest > "$tmp1" 2>/dev/null ) & local pid1=$!
  ( run_restic_with_retry stats --mode raw-data --host "$target_host" latest > "$tmp2" 2>/dev/null ) & local pid2=$!
  ( run_restic_with_retry stats --host "$target_host" > "$tmp3" 2>/dev/null ) & local pid3=$!
  ( run_restic_with_retry stats --mode raw-data --host "$target_host" > "$tmp4" 2>/dev/null ) & local pid4=$!
  debug_stop

  # shellcheck disable=SC2064
  trap "kill $pid1 $pid2 $pid3 $pid4 2>/dev/null; cleanup_on_exit; exit 130" INT
  
  wait_with_spinner "Calculating repo stats..." "$pid1" "$pid2" "$pid3" "$pid4"
  
  wait $pid1; local e1=$?
  wait $pid2; local e2=$?
  wait $pid3; local e3=$?
  wait $pid4; local e4=$?
  trap - INT
  
  if [[ $e1 -ne 0 ]]; then check_restic_error $e1; fi
  if [[ $e2 -ne 0 ]]; then check_restic_error $e2; fi
  if [[ $e3 -ne 0 ]]; then check_restic_error $e3; fi
  if [[ $e4 -ne 0 ]]; then check_restic_error $e4; fi
  
  local latest_host_stat
  local host_stat
  local stat_restore_size
  local stat_raw_data
  
  latest_host_stat=$(awk -F': ' '/Total Size/{print $2}' "$tmp1" 2>/dev/null || echo "N/A")
  host_stat=$(awk -F': ' '/Total Size/{print $2}' "$tmp2" 2>/dev/null || echo "N/A")
  stat_restore_size=$(awk -F': ' '/Total Size/{print $2}' "$tmp3" 2>/dev/null || echo "N/A")
  stat_raw_data=$(awk -F': ' '/Total Size/{print $2}' "$tmp4" 2>/dev/null || echo "N/A")
  
  
  
  show_cursor
  printf "\r\e[K"
  
  print_line "="
  printf "${c_white}%-20s | %-18s | %-20s${c_reset}\n" "Summarized Info" "Restore Size" "Deduplicated Size"
  print_line "="
  printf "%-20s | %-18s | %-20s\n" "Latest Snapshot" "${latest_host_stat:-N/A}" "${host_stat:-N/A}"
  printf "%-20s | %-18s | %-20s\n" "All Snapshots" "${stat_restore_size:-N/A}" "${stat_raw_data:-N/A}"
}
