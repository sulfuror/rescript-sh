# ============================================================== #
#                        COMMAND:UMOUNTER                        #
# ============================================================== #

function umounter {
  if [[ ${#rest[@]} -gt 0 ]]; then
    echo "Invalid option [${rest[0]}]..."
    echo ""
    umounter-help
    exit 1
  fi
  rescript_lock
  debug_start
  local pid_file="/tmp/rescript_mount_${repo}.pid"

  if [[ -f "$pid_file" ]]; then
    IFS=':' read -r pid mount_point < "$pid_file"
    if kill -0 "$pid" 2>/dev/null; then
      echo -e "${c_cyan}Stopping mounter process (PID: $pid)...${c_reset}"
      kill -15 "$pid"
      sleep 1
      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid"
      fi
      echo -e "${c_green}Mounter process stopped.${c_reset}"
    fi

    if [[ -d "$mount_point" ]]; then
      if mountpoint -q "$mount_point"; then
        echo -e "${c_cyan}Unmounting repository from:${c_reset} ${c_white}$mount_point${c_reset}"
        if ! fusermount -u "$mount_point" 2>/dev/null; then
          umount "$mount_point" 2>/dev/null
        fi
      fi
      rmdir "$mount_point" 2>/dev/null
      echo -e "${c_green}Mount point cleaned up.${c_reset}"
    fi
    rm -f "$pid_file"
  else
    echo -e "${c_cyan}No background mounter found for repository:${c_reset} ${c_white}$repo${c_reset}"
  fi
  debug_stop
  exit 0
}
