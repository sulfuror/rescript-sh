function mounter {
  rescript_lock
  local bg=false
  local clean_rest=()
  for arg in "${rest[@]}"; do
    if [[ "$arg" == "--background" ]]; then
      bg=true
    else
      clean_rest+=("$arg")
    fi
  done

  rmount="$HOME/$repo-repo-$(date +%s)"
  mkdir -p "$rmount"
  
  if [[ "$bg" == "true" ]]; then
    restic mount "${clean_rest[@]}" "$rmount" >/dev/null 2>&1 &
    local pid=$!
    echo "$pid:$rmount" > "/tmp/rescript_mount_${repo}.pid"
    echo -e "${c_green}Repository mounted in background at:${c_reset} ${c_white}$rmount${c_reset}"
    echo -e "${c_cyan}Use [rescript $repo umounter] to unmount.${c_reset}"
  else
    echo -e "${c_cyan}Mounting repository at:${c_reset} ${c_white}$rmount${c_reset}"
    echo -e "${c_cyan}Use another terminal or tool to browse the contents.${c_reset}"
    echo -e "${c_cyan}When finished, press [Ctrl-C] here to unmount.${c_reset}"
    
    local mounter_stopped=false
    stty -echoctl 2>/dev/null # Hide ^C from terminal
    trap 'mounter_stopped=true; stty echoctl 2>/dev/null' INT
    
    restic mount "${clean_rest[@]}" "$rmount" >/dev/null
    
    trap - INT
    stty echoctl 2>/dev/null # Restore terminal behavior
    
    # Allow Restic to unmount FUSE gracefully
    sleep 0.5
    if mountpoint -q "$rmount" 2>/dev/null; then
      fusermount -u "$rmount" 2>/dev/null || umount "$rmount" 2>/dev/null
      sleep 0.5
    fi
    
    rm -rf "$rmount" 2>/dev/null
    
    if [ "$mounter_stopped" = "true" ]; then
      echo -e "\n${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    else
      echo -e "${c_green}Mounter process stopped. Mount point cleaned up.${c_reset}"
    fi
  fi
}

