# ============================================================== #
#                       COMMAND: AUTOMATIC                       #
# ============================================================== #
_run_auto_cleanup() {
  if [[ ${#policies[@]} -gt 0 ]] ; then
    print_line
    printf "%b\n" "${c_cyan}Cleaning Repo...${c_reset}"
    cleanup
    print_line
    printf "%b\n" "${c_cyan}Checking for Errors in Repo...${c_reset}"
    run_restic_with_retry check --cleanup-cache
    check_restic_error $?
  fi
}
automatic() {
  local now next
  rescript_lock
  case "${LOGGING:-}" in
    y|yes)
      log_flag="true"
      ;;
  esac
  time_flag="true"
  context_flag="true"
  logger
  time_start
  print_context
  # Backup
  case "${SKIP_OFFICE:-}" in
    y|yes)
      printf "%b\n" "${c_cyan}Taking a Snapshot...${c_reset}" ; skip_flag="true" ; backup ;;
    *)
      printf "%b\n" "${c_cyan}Taking a Snapshot...${c_reset}" ; backup ;;
  esac
  local exclusions
  exclusions=$(grep -E -v -n -c '(^#|^[[:space:]]*$|^[[:space:]]*#)' "$excludes" 2>/dev/null || true)
  if [[ "$exclusions" -gt "0" ]] ; then
    printf "%b\n" "${c_green}There are $exclusions exclusion rules...${c_reset}"
  fi
  # Snapshot List
  case "${SHOW_SNAPS:-}" in
    y|yes)
      print_line
      printf "%b\n" "${c_cyan}Snapshots List...${c_reset}"
      snaps
      check_restic_error $?
      ;;
  esac
  # Check and Clean Repo Based on User's Policy
  if [[ -f "$config_dir/$repo.state" || -f "$config_dir/$repo-datefile" || -n "${CLEAN:-}" ]]; then
    now_next
    if [[ "$now" -lt "$next" ]] ; then
      print_line
      cleanup_next
    else 
      _run_auto_cleanup
      if [[ -n "${CLEAN:-}" ]] ; then
        local clean_num="${CLEAN//[A-Za-z]/}"
        local clean_unit="${CLEAN//[0-9]/}"
        local add_seconds=0
        case "$clean_unit" in
          days|day|d) add_seconds=$((clean_num * 86400)) ;;
          hours|hour|h) add_seconds=$((clean_num * 3600)) ;;
          minutes|minute|m) add_seconds=$((clean_num * 60)) ;;
          weeks|week|w) add_seconds=$((clean_num * 604800)) ;;
          months|month|M) add_seconds=$((clean_num * 2592000)) ;;
          *)
            printf "%b\n" "WARNING: \nCLEAN is set to ${CLEAN:-} in your configuration file; please use the correct syntax as follows: \n1. CLEAN=\"${CLEAN}days\"\n2. CLEAN=\"${CLEAN}hours\"\n3. CLEAN=\"${CLEAN}minutes\""
            ;;
        esac
        if [[ "$add_seconds" -gt 0 ]]; then
          local next_epoch=$((now + add_seconds))
          set_state "NEXT_CLEANUP" "$next_epoch" "$config_dir/$repo.state"
          printf "%b\n" "${c_green}Done Cleaning; Next Cleanup and Check Will Be Done in $clean_num $clean_unit...${c_reset}"
        fi
      fi
    fi
  else 
    _run_auto_cleanup
  fi
  # Stats
  case "${SHOW_STATS:-}" in
    y|yes) 
      statinfo 
      ;;
  esac
  # Time and Runtime
  time_end

  if [[ -n "${CLEAN:-}" && ${#policies[@]} -eq 0 ]] ; then
    local clean_num="${CLEAN//[A-Za-z]/}"
    local clean_unit="${CLEAN//[0-9]/}"
    printf "%s\n" "[rescript] noted that your CLEAN variable is ${CLEAN:-}, so [rescript] assumes that"
    printf "%s\n" "you want to perform a 'cleanup' (forget, prune and check) every $clean_num $clean_unit but"
    printf "%s\n" "it can't execute it if you have not set the KEEP variables; please set your"
    printf "%s\n" "desired KEEP values in order to perform the 'cleanup' every $clean_num $clean_unit. If you"
    printf "%s\n" "don't want [rescript] to 'cleanup' your repo automatically every $clean_num $clean_unit,"
    printf "%s\n" "just leave the CLEAN variable blank in your configuration file and this"
    printf "%s\n" "message will not appear again."
    printf "\n"
    printf "%s\n" "For more info about this subject:"
    printf "%s\n" "https://github.com/sulfuror/rescript-sh/blob/master/README.md#usage"
  fi
}
