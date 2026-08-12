# ============================================================== #
#                      COMMAND: UNLOCKER                         #
# ============================================================== #
unlocker() {
  if [[ ${#rest[@]} -gt 0 ]]; then
    printf "%s\n" "Invalid option [${rest[0]}]..."
    printf "\n"
    unlocker-help
    exit 1
  fi
  if [[ ! -e "$lock" ]]; then
    printf "%b\n" "${c_cyan}No locks found...${c_reset}"
  else
    rm -f "${lock:?}"
    printf "%b\n" "${c_green}Script unlocked...${c_reset}"
  fi
}
