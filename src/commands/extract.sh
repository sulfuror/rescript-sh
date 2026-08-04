# ============================================================== #
#                        COMMAND: EXTRACT                        #
# ============================================================== #

function extract {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a file path to extract."
    exit 1
  fi
  
  local file=""
  local snap_id=""
  local extract_rest=()
  local args_done=false
  
  for arg in "${rest[@]}"; do
    if [[ "$arg" == -* ]]; then
      args_done=true
      extract_rest+=( "$arg" )
    elif [[ "$args_done" == false ]]; then
      if [[ -z "$snap_id" ]]; then
        snap_id="$arg"
      elif [[ -z "$file" ]]; then
        file="$arg"
      else
        extract_rest+=( "$arg" )
      fi
    else
      extract_rest+=( "$arg" )
    fi
  done

  # Shift if only one positional argument was provided
  if [[ -n "$snap_id" && -z "$file" ]]; then
    file="$snap_id"
    snap_id=""
  fi

  if [[ -z "$file" ]] ; then
    echo "You must provide a file path to extract."
    echo "Note: Positional arguments (snapshot ID and file path) must be placed BEFORE any restic flags."
    exit 1
  fi
  
  local dest_name
  dest_name="$(basename "$file")"
  if [[ -e "./$dest_name" ]] ; then
    dest_name="${dest_name}_extracted"
  fi
  
  echo "Extracting [$file] to [./$dest_name]..."
  
  local restic_args=()
  if [[ -z "$snap_id" ]] ; then
    echo "Auto-detecting latest snapshot for this file..."
    
    local has_host=false
    for arg in "${extract_rest[@]}"; do
      if [[ "$arg" == "--host" || "$arg" == "-H" ]]; then
        has_host=true
        break
      fi
    done
    
    local find_flags=()
    if [[ "$has_host" == false ]]; then
      find_flags+=( "--host" "$rhost" )
    fi
    find_flags+=( "${extract_rest[@]}" )
    
    debug_start
    snap_id=$(run_restic_with_retry find "${find_flags[@]}" "$file" 2>/dev/null | tr -d '\r' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/Found matching entries in snapshot/ { for(i=1;i<=NF;i++) if($i=="snapshot") snap=$(i+1) } END { print snap }')
    debug_stop
    if [[ -z "$snap_id" ]] ; then
      echo "Extraction failed. File [$file] not found in any snapshot."
      exit 1
    fi
  fi
  
  restic_args=( "$snap_id" "$file" "${extract_rest[@]}" )
  
  local err_file="/tmp/rescript_extract_err_$$"
  (
    debug_start
    run_restic_with_retry dump "${restic_args[@]}" > "./$dest_name" 2> "$err_file"
    debug_stop
  ) &
  local pid=$!
  trap 'kill "$pid" 2>/dev/null; rm -f "./$dest_name" "$err_file" 2>/dev/null; exit 130' INT
  local progress=0
  
  while kill -0 "$pid" 2>/dev/null; do
    print_progress "Extracting file" "$progress"
    progress=$(( progress + 5 ))
    if [[ $progress -ge 100 ]]; then
      progress=0
    fi
    sleep 0.2
  done
  
  wait "$pid" || exit_code=$?
  exit_code=${exit_code:-0}
  
  if [[ $exit_code -eq 0 ]] ; then
    print_progress "Extracting file" 100
    echo -ne "\n${c_green}Extraction complete.${c_reset}\n"
  else
    echo -ne "\n${c_red}Extraction failed. Restic error:${c_reset}\n"
    cat "$err_file" 2>/dev/null
    rm -f "./$dest_name"
  fi
  rm -f "$err_file"
}
