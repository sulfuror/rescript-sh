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
    snap_id=$(run_restic_with_retry find "${find_flags[@]}" "$file" 2>/dev/null | tr -d '\r' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/Found matching entries in snapshot/ { for(i=1;i<=NF;i++) if($i=="snapshot") { print $(i+1); exit } }' || true)
    debug_stop
    if [[ -z "$snap_id" ]] ; then
      echo "Extraction failed. File [$file] not found in any snapshot."
      exit 1
    fi
  else
    echo "Using provided snapshot ID [${snap_id}]..."
  fi

  local dest_name
  dest_name="$(basename "$file")"
  if [[ -e "./$dest_name" || -e "./${dest_name}.zip" ]] ; then
    # Add snapshot ID to filename to prevent collision and provide context
    local filename="${dest_name%.*}"
    local extension="${dest_name##*.}"
    
    # Calculate short snapshot ID (8 characters)
    local short_snap="${snap_id:0:8}"
    
    local base_dest_name
    if [[ "$filename" == "$extension" ]]; then
      base_dest_name="${dest_name}_snap_${short_snap}"
      dest_name="$base_dest_name"
    else
      base_dest_name="${filename}_snap_${short_snap}"
      dest_name="${base_dest_name}.${extension}"
    fi
    
    # Fallback to append (1), (2), etc. if the file still exists
    local counter=1
    while [[ -e "./$dest_name" || -e "./${dest_name}.zip" ]] ; do
      if [[ "$filename" == "$extension" ]]; then
        dest_name="${base_dest_name} (${counter})"
      else
        dest_name="${base_dest_name} (${counter}).${extension}"
      fi
      ((counter++))
    done
  fi
  
  echo "Extracting [$file] to [./$dest_name]..."
  
  local restic_args=( "dump" "-a" "zip" "$snap_id" "$file" "${extract_rest[@]}" )
  
  local err_file="/tmp/rescript_extract_err_$$"
  (
    debug_start
    run_restic_with_retry "${restic_args[@]}" > "./$dest_name" 2> "$err_file"
    debug_stop
  ) &
  local pid=$!
  # shellcheck disable=SC2064
  trap "kill $pid 2>/dev/null; rm -f \"./$dest_name\" \"$err_file\" 2>/dev/null; exit 130" INT
  
  local spin='-\|/'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf "\r${c_cyan}Extracting file... %s${c_reset}" "${spin:$i:1}"
    sleep 0.1
  done
  
  wait "$pid" || exit_code=$?
  trap - INT
  exit_code=${exit_code:-0}
  
  printf "\r\e[K"
  
  if [[ $exit_code -eq 0 ]] ; then
    
    # Check if restic dumped a directory as a zip archive
    if file "./$dest_name" 2>/dev/null | grep -qi "zip archive data"; then
      if [[ ! "$dest_name" == *.zip ]]; then
        mv "./$dest_name" "./$dest_name.zip"
        dest_name="$dest_name.zip"
        echo -e "${c_green}Directory successfully extracted as a zip archive.${c_reset}"
      else
        echo -e "${c_green}Extraction complete.${c_reset}"
      fi
    else
      echo -e "${c_green}Extraction complete.${c_reset}"
    fi
    echo "Saved to: ./$dest_name"
  else
    echo -ne "\n${c_red}Extraction failed. Restic error:${c_reset}\n"
    cat "$err_file" 2>/dev/null
    rm -f "./$dest_name"
  fi
  rm -f "$err_file"
}
