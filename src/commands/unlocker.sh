# ============================================================== #
#                      COMMAND: UNLOCKER                         #
# ============================================================== #

function unlocker {
  if [[ ${#rest[@]} -gt 0 ]]; then
    echo "Invalid option [${rest[0]}]..."
    echo ""
    unlocker-help
    exit 1
  fi
  if [[ ! -e "$lock" ]]; then
    echo -e "${c_cyan}No locks found...${c_reset}"
  else
    rm -rf "${lock:?}"
    echo -e "${c_green}Script unlocked...${c_reset}"
  fi
}
