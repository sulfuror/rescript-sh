# ============================================================== #
#                        COMMAND:UMOUNTER                        #
# ============================================================== #
umounter() {
  rescript_lock
  debug_start
  local pid_file="$lock_dir/mount_${repo}.pid"

  if [[ -f "$pid_file" ]]; then
    local pid_info
    pid_info=$(<"$pid_file")
    
    if [[ -z "$pid_info" || "$pid_info" != *":"* ]]; then
      printf "%s\n" "INFO: Invalid or empty mount file found. Assuming already unmounted."
      rm -f "$pid_file"
      debug_stop
      exit 0
    fi
    
    local mount_pid="${pid_info%%:*}"
    local mount_point="${pid_info##*:}"
    
    if [[ -n "$mount_point" && -d "$mount_point" ]]; then
      if mountpoint -q "$mount_point"; then
        printf "%b\n" "${c_cyan}Unmounting repository from:${c_reset} ${c_white}$mount_point${c_reset}"
        if ! fusermount -u "$mount_point" 2>/dev/null; then
          umount "$mount_point" 2>/dev/null
        fi
      fi
      rmdir "$mount_point" 2>/dev/null
      printf "%b\n" "${c_green}Mount point cleaned up.${c_reset}"
    fi

    if ! is_pid_alive "$mount_pid"; then
      printf "%s\n" "INFO: Stale mount file found (PID $mount_pid is dead). Assuming already unmounted."
      rm -f "$pid_file"
    else
      printf "%b\n" "${c_cyan}Stopping mounter process (PID: $mount_pid)...${c_reset}"
      kill -15 "$mount_pid" 2>/dev/null
      sleep 1
      if is_pid_alive "$mount_pid"; then
        kill -9 "$mount_pid" 2>/dev/null
      fi
      printf "%b\n" "${c_green}Mounter process stopped.${c_reset}"
    fi
    rm -f "$pid_file"
  else
    printf "%b\n" "${c_cyan}No background mounter found for repository:${c_reset} ${c_white}$repo${c_reset}"
  fi
  debug_stop
  exit 0
}
