# ============================================================== #
#                     COMMAND: MOUNTER                           #
# ============================================================== #
mounter() {
  rescript_lock
  local bg=false arg
  local clean_rest=()
  for arg in "${rest[@]}"; do
    if [[ "$arg" == "--background" ]]; then
      bg=true
    else
      clean_rest+=("$arg")
    fi
  done
  
  local pid_file="$lock_dir/mount_${repo}.pid"
  if [[ -f "$pid_file" ]]; then
    local pid_info
    pid_info=$(<"$pid_file")
    local mount_pid="${pid_info%%:*}"
    if is_pid_alive "$mount_pid"; then
      printf "%b\n" "${c_red}ERROR: Repository [$repo] is already mounted in the background (PID: $mount_pid).${c_reset}"
      printf "%b\n" "${c_cyan}Use [rescript $repo umounter] to unmount it first.${c_reset}"
      exit 1
    else
      rm -f "$pid_file"
    fi
  fi

  local rmount="$HOME/$repo-repo-$(date +%s)"
  mkdir -p "$rmount"
  
  if [[ "$bg" == "true" ]]; then
    # Use setsid and redirect stdin to completely detach from the TTY and avoid EOF/exit issues
    setsid restic mount "${clean_rest[@]}" "$rmount" </dev/null >/dev/null 2>&1 &
    local pid=$!
    sleep 0.5
    if ! is_pid_alive "$pid"; then
      rmdir "${rmount:?}" 2>/dev/null
      printf "%b\n" "${c_red}Failed to mount repository in background. See 'restic mount' logs for details.${c_reset}"
      exit 1
    fi
    printf "%s\n" "$pid:$rmount" > "$lock_dir/mount_${repo}.pid"
    printf "%b\n" "${c_green}Repository mounted in background at:${c_reset} ${c_white}$rmount${c_reset}"
    printf "%b\n" "${c_cyan}Use [rescript $repo umounter] to unmount.${c_reset}"
  else
    printf "%b\n" "${c_cyan}Mounting repository at:${c_reset} ${c_white}$rmount${c_reset}"
    printf "%b\n" "${c_cyan}Use another terminal or tool to browse the contents.${c_reset}"
    printf "%b\n" "${c_cyan}When finished, press [Ctrl-C] here to unmount.${c_reset}"
    
    local mounter_stopped=false
    stty -echoctl 2>/dev/null # Hide ^C from terminal
    trap 'mounter_stopped=true; stty echoctl 2>/dev/null' INT
    
    restic mount "${clean_rest[@]}" "$rmount" >/dev/null
    
    trap "cleanup_on_exit; handle_interrupt" INT HUP QUIT TERM
    stty echoctl 2>/dev/null # Restore terminal behavior
    
    # Allow Restic to unmount FUSE gracefully
    sleep 0.5
    if mountpoint -q "$rmount" 2>/dev/null; then
      fusermount -u "$rmount" 2>/dev/null || umount "$rmount" 2>/dev/null
      sleep 0.5
    fi
    
    rmdir "${rmount:?}" 2>/dev/null
    
    if [[ "$mounter_stopped" == "true" ]]; then
      printf "%b\n" "\n${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    else
      printf "%b\n" "${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    fi
  fi
}
