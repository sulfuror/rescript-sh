function extract {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a file path to extract."
    exit 1
  fi
  
  local file=""
  local extract_rest=()
  for (( i=${#rest[@]}-1; i>=0; i-- )); do
    if [[ -z "$file" && "${rest[i]}" != -* ]]; then
      file="${rest[i]}"
    else
      extract_rest=( "${rest[i]}" "${extract_rest[@]}" )
    fi
  done

  if [[ -z "$file" ]] ; then
    echo "You must provide a file path to extract."
    exit 1
  fi
  
  local dest_name
  dest_name="$(basename "$file")"
  if [[ -d "./$dest_name" ]] ; then
    dest_name="${dest_name}_extracted"
  fi
  
  echo "Extracting [$file] to [./$dest_name]..."
  
  local restic_args=()
  if [[ ${#extract_rest[@]} -eq 0 ]] ; then
    echo "Auto-detecting latest snapshot for this file..."
    local snap_id
    snap_id=$(restic find "$file" 2>/dev/null | tr -d '\r' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/Found matching entries in snapshot/ { for(i=1;i<=NF;i++) if($i=="snapshot") snap=$(i+1) } END { print snap }')
    if [[ -z "$snap_id" ]] ; then
      echo "Extraction failed. File [$file] not found in any snapshot."
      exit 1
    fi
    restic_args=( "$snap_id" "$file" )
  else
    restic_args=( "${extract_rest[@]}" "$file" )
  fi
  
  local err_file="/tmp/rescript_extract_err_$$"
  (
    restic dump "${restic_args[@]}" > "./$dest_name" 2> "$err_file"
  ) &
  local pid=$!
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

