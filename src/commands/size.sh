function size {
  rescript_lock
  local target_host="$rhost"
  if [[ -n "$host_flag" ]] ; then
    target_host="$host_flag"
  fi
  
  local snapshot_id="latest"
  if [[ ${#rest[@]} -gt 0 ]] && [[ "${rest[0]}" == "latest" || "${rest[0]}" =~ ^[a-f0-9]{8}$ || "${rest[0]}" =~ ^[a-f0-9]{64}$ ]] ; then
    snapshot_id="${rest[0]}"
    rest=("${rest[@]:1}")
  fi
  
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a path inside the repository."
    exit 1
  fi
  
  local host_args=()
  if [[ "$snapshot_id" == "latest" ]]; then
    host_args=("--host" "$target_host")
    echo -e "${c_white}Target Host:${c_reset} ${c_cyan}${target_host}${c_reset}\n"
  else
    echo -e "${c_white}Snapshot ID:${c_reset} ${c_cyan}${snapshot_id}${c_reset}\n"
  fi
  
  print_progress "Calculating total size" 50
  debug_start

  local total_size
  total_size=$(restic ls -l --recursive "${host_args[@]}" "$snapshot_id" "${rest[@]}" 2>/dev/null | awk '
    /^[-dcbp](r|-)[w|-](x|-)(r|-)[w|-](x|-)(r|-)[w|-](x|-)/ { sum += $4 }
    END {
      if (sum >= 1024^3) printf "%.2f GB\n", sum / (1024^3)
      else if (sum >= 1024^2) printf "%.2f MB\n", sum / (1024^2)
      else if (sum >= 1024) printf "%.2f KB\n", sum / 1024
      else printf "%d B\n", sum
    }
  ' || true)
  debug_stop
  print_progress "Calculating total size" 100
  echo -ne '\n'
  
  if [[ -z "$total_size" || "$total_size" == "0 B" ]] ; then
    echo -e "${c_red}Path not found or empty.${c_reset}"
  else
    echo -e "\n${c_white}Total size for [${rest[*]}] in snapshot ${snapshot_id}:${c_reset} ${c_green}${total_size}${c_reset}"
  fi
}

