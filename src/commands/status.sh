# ============================================================== #
#                            STATUS                              #
# ============================================================== #

function global_status {
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
          echo "Error: -X/--ignore-repo requires a repository name."
          exit 1
        fi
        ;;
      *)
        shift
        ;;
    esac
  done
  

  if [[ ! -d "$config_dir" ]]; then
    echo "No repositories configured."
    exit 1
  fi
  
  repos=()
  if [[ -n "${repo:-}" && "${repo:-}" != "global" && -f "$config_dir/$repo.conf" ]]; then
    repos=("$repo")
  else
    for conf in "$config_dir"/*.conf; do
      [ -e "$conf" ] || continue
      local r_name=$(basename "$conf" .conf)
      if [[ "$r_name" != "global" ]]; then
        if ! array_contains "$r_name" "${excluded_repos[@]}"; then
          repos+=("$r_name")
        fi
      fi
    done
  fi
  
  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "No repositories found."
    exit 0
  fi
  
  print_line "="
  if [[ "$full_mode" == "true" ]]; then
    printf "${c_white}%-15s | %-10s | %-21s | %-12s | %s${c_reset}\n" "Repository" "Snapshots" "Latest Date" "Size" "Health"
  else
    printf "${c_white}%-15s | %-10s | %-21s${c_reset}\n" "Repository" "Snapshots" "Latest Date"
  fi
  print_line "="
  
  for repo in "${repos[@]}"; do
    source_config "$config_dir/$repo.conf"
    export RESTIC_PASSWORD
    export RESTIC_PASSWORD_COMMAND
    
    local num_snaps=0
    local latest_date="Never"
    
    local raw_snapshots
    debug_start
    raw_snapshots=$(restic -r "$RESTIC_REPO" snapshots 2>/dev/null || true)
    debug_stop
    
    if [[ -n "$raw_snapshots" ]]; then
      local snap_count_str
      snap_count_str=$(echo "$raw_snapshots" | awk '/snapshots/{print $1}' | tail -n1 || true)
      if [[ -n "$snap_count_str" && "$snap_count_str" -gt 0 ]] 2>/dev/null; then
        num_snaps="$snap_count_str"
        debug_start
        latest_date=$(restic -r "$RESTIC_REPO" snapshots --latest 1 2>/dev/null | awk 'NR==3 {print $2, $3}' || true)
        debug_stop
      fi
    fi
    
    if [[ "$full_mode" == "true" ]]; then
      hide_cursor
      local base_row=$(printf "%-15s | %-10s | %-21s | " "$repo" "$num_snaps" "$latest_date")
      
      (
        size_str="N/A"
        health_str="${c_red}Error${c_reset}"
        
        # Stats
        debug_start
        raw_stats=$(restic -r "$RESTIC_REPO" stats --mode raw-data 2>/dev/null)
        debug_stop
        if [[ -n "$raw_stats" ]]; then
          local size_raw=$(echo "$raw_stats" | awk '/Total Size:/{print $3$4}')
          if [[ -n "$size_raw" ]]; then
            size_str="$size_raw"
          fi
        fi
        
        # Check
        debug_start
        if restic -r "$RESTIC_REPO" check --quiet >/dev/null 2>&1; then
          health_str="${c_green}OK${c_reset}"
        fi
        debug_stop
        
        echo "$size_str|$health_str" > "/tmp/rescript_status_$repo"
      ) &
      local pid=$!
      trap 'kill "$pid" 2>/dev/null; rm -f "/tmp/rescript_status_$repo" 2>/dev/null; exit 130' INT
      
      local spin='-\|/'
      local i=0
      while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r%b %-12s | %s" "$base_row" "Calc ${spin:$i:1}" "Calc ${spin:$i:1}"
        sleep 0.1
      done
      wait $pid
      
      local size_str="N/A"
      local health_str="${c_red}Error${c_reset}"
      if [[ -f "/tmp/rescript_status_$repo" ]]; then
        IFS='|' read -r size_str health_str < "/tmp/rescript_status_$repo"
        rm -f "/tmp/rescript_status_$repo"
      fi
      
      show_cursor
      printf "\r%b %-12s | %b\e[K\n" "$base_row" "$size_str" "$health_str"
      
    else
      printf "%-15s | %-10s | %-21s\n" "$repo" "$num_snaps" "$latest_date"
    fi
  done
  print_line "="
}
