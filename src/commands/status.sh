# ============================================================== #
#                            STATUS                              #
# ============================================================== #
global_status() {
  local full_mode="false"
  local excluded_repos=()
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -F|--full|--stats)
        full_mode="true"
        shift
        ;;
      -X|--ignore-repo)
        if [[ -n "${2:-}" ]]; then
          excluded_repos+=("$2")
          shift 2
        else
          printf "%s\n" "Error: -X/--ignore-repo requires a repository name."
          exit 1
        fi
        ;;
      *)
        printf "%s\n" "Invalid option [$1]..."
        printf "\n"
        status-help
        exit 1
        ;;
    esac
  done
  

  if [[ ! -d "$config_dir" ]]; then
    printf "%s\n" "No repositories configured."
    exit 1
  fi
  
  local repos=()
  if [[ -n "${repo:-}" && "${repo:-}" != "global" && -f "$config_dir/$repo.conf" ]]; then
    repos=("$repo")
  else
    get_repo_list ${excluded_repos[@]:+"${excluded_repos[@]}"}
  fi
  
  if [[ ${#repos[@]} -eq 0 ]]; then
    printf "%s\n" "No repositories found."
    exit 0
  fi
  
  local pids=()
  local tmp_files=()
  hide_cursor
  
  for current_repo in "${repos[@]}"; do
    local repo="$current_repo"
    local tmp_file="$session_tmp/status_${repo}_$$"
    tmp_files+=("$tmp_file")
    
    (
      source_config "$config_dir/$repo.conf"
      export RESTIC_PASSWORD
      export RESTIC_PASSWORD_COMMAND
      
      local num_snaps=0
      local latest_date="Never"
      local size_str="N/A"
      local health_str="${c_red}Error${c_reset}"
      
      local raw_snapshots
      debug_start
      raw_snapshots=$(run_restic_with_retry -r "$RESTIC_REPO" snapshots 2>/dev/null || true)
      debug_stop
      
      if [[ -n "$raw_snapshots" ]]; then
        local snap_count_str
        snap_count_str=$(printf "%s\n" "$raw_snapshots" | awk '/snapshots/{print $1}' | tail -n1 || true)
        if [[ -n "$snap_count_str" && "$snap_count_str" -gt 0 ]] 2>/dev/null; then
          num_snaps="$snap_count_str"
          debug_start
          latest_date=$(run_restic_with_retry -r "$RESTIC_REPO" snapshots --latest 1 2>/dev/null | awk 'NR==3 {print $2, $3}' || true)
          debug_stop
        fi
      fi
      
      if [[ "$full_mode" == "true" ]]; then
        # Stats
        debug_start
        local raw_stats
        raw_stats=$(run_restic_with_retry -r "$RESTIC_REPO" stats --mode raw-data 2>/dev/null)
        debug_stop
        if [[ -n "$raw_stats" ]]; then
          local size_raw
          size_raw=$(printf "%s\n" "$raw_stats" | awk '/Total Size:/{print $3$4}')
          if [[ -n "$size_raw" ]]; then
            size_str="$size_raw"
          fi
        fi
        
        # Check
        debug_start
        if run_restic_with_retry -r "$RESTIC_REPO" check --quiet >/dev/null 2>&1; then
          health_str="${c_green}OK${c_reset}"
        fi
        debug_stop
        
        printf "%s\n" "$repo|$num_snaps|$latest_date|$size_str|$health_str" > "$tmp_file"
      else
        printf "%s\n" "$repo|$num_snaps|$latest_date" > "$tmp_file"
      fi
    ) &
    pids+=($!)
  done
  
  # Trap for all PIDs
  # shellcheck disable=SC2064
  trap "kill ${pids[*]} 2>/dev/null; cleanup_on_exit; exit 130" INT
  
  local status_msg=""
  if [[ ${#repos[@]} -eq 1 ]]; then
    status_msg="Calculating status for [${repos[0]}]..."
  else
    status_msg="Calculating status for ${#repos[@]} repositories..."
  fi
  wait_with_spinner "$status_msg" "${pids[@]}"
  
  wait "${pids[@]}" 2>/dev/null || true
  trap "cleanup_on_exit; handle_interrupt" INT HUP QUIT TERM
  
  printf "\r\e[K"
  show_cursor
  
  print_line "="
  if [[ "$full_mode" == "true" ]]; then
    printf "${c_white}%-15s | %-10s | %-21s | %-12s | %s${c_reset}\n" "Repository" "Snapshots" "Latest Date" "Size" "Health"
  else
    printf "${c_white}%-15s | %-10s | %-21s${c_reset}\n" "Repository" "Snapshots" "Latest Date"
  fi
  print_line "="
  
  local r_name num_snaps latest_date size_str health_str
  for current_repo in "${repos[@]}"; do
    local repo="$current_repo"
    local tmp_file="$session_tmp/status_${repo}_$$"
    if [[ -f "$tmp_file" ]]; then
      if [[ "$full_mode" == "true" ]]; then
        IFS='|' read -r r_name num_snaps latest_date size_str health_str < "$tmp_file"
        printf "%-15s | %-10s | %-21s | %-12s | %b\n" "$r_name" "$num_snaps" "$latest_date" "$size_str" "$health_str"
      else
        IFS='|' read -r r_name num_snaps latest_date < "$tmp_file"
        printf "%-15s | %-10s | %-21s\n" "$r_name" "$num_snaps" "$latest_date"
      fi
    else
      if [[ "$full_mode" == "true" ]]; then
        printf "%-15s | %-10s | %-21s | %-12s | %b\n" "$repo" "Error" "Unknown" "N/A" "${c_red}Failed${c_reset}\n"
      else
        printf "%-15s | %-10s | %-21s\n" "$repo" "Error" "Unknown"
      fi
    fi
  done
}
