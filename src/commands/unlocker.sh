function unlocker {
  if [[ ! -e "$lock" ]]; then
    echo -e "${c_cyan}No locks found...${c_reset}"
  else
    rm -rf "${lock:?}"
    echo -e "${c_green}Script unlocked...${c_reset}"
  fi
}
