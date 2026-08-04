# ============================================================== #
#                       COMMAND: AUTOMATIC                       #
# ============================================================== #

function automatic {
  rescript_lock
  case "$LOGGING" in
    y|yes)
      log_flag="true"
      ;;
  esac
  time_flag="true"
  context_flag="true"
  logger
  time_start
  print_context
  context_flag="false"



  function _run_auto_cleanup {
    if [[ -n "${policies[*]}" ]] ; then
      print_line
      echo -e "${c_cyan}Cleaning Repo...${c_reset}"
      cleanup
      print_line
      echo -e "${c_cyan}Checking for Errors in Repo...${c_reset}"
      run_restic_with_retry check --cleanup-cache
      check_restic_error $?
    fi
  }
  # Backup
  case "$SKIP_OFFICE" in
    y|yes)
      echo -e "${c_cyan}Taking a Snapshot...${c_reset}" ; skip_flag="true" ; backup ;;
    *)
      echo -e "${c_cyan}Taking a Snapshot...${c_reset}" ; backup ;;
  esac
  exclusions=$(grep -E -v -n -c '(^#|^\s*$|^\s*\t*#)' "$excludes")
  if [[ "$exclusions" -gt "0" ]] ; then
    echo -e "${c_green}There are $exclusions exclusion rules...${c_reset}"
  fi
  # Snapshot List
  case "$SHOW_SNAPS" in
    y|yes)
      print_line
      echo -e "${c_cyan}Snapshots List...${c_reset}"
      snaps
      check_restic_error $?
      ;;
  esac
  # Check and Clean Repo Based on User's Policy
  if [[ -f "$config_dir/$repo-datefile" || -n "${CLEAN:-}" ]]; then
    if [[ ! -f "$config_dir/$repo-datefile" ]] ; then
      touch "$config_dir/$repo-datefile"
    fi
    now_next
    if [[ "$now" -lt "$next" ]] ; then
      print_line
      cleanup-next
    else 
        _run_auto_cleanup
        if [[ -n "${CLEAN:-}" ]] ; then
          clean_num="${CLEAN//[A-Za-z]/}"
          clean_unit="${CLEAN//[0-9]/}"
          case "$unix_name" in
            Linux|GNU)
              date -d "now+${CLEAN:-}" +%s 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
            *)
              gdate -d "now+${CLEAN:-}" +%s 2>/dev/null > "$config_dir/$repo-datefile"
              ;;
          esac
          exit_code="$?"
          if [[ "$exit_code" -gt "0" ]] ; then
            echo -e "WARNING: \nCLEAN is set to ${CLEAN:-} in your configuration file; please use the correct syntax as follows: \n1. CLEAN=\"${CLEAN}days\"     <---setup cleanup every ${CLEAN:-} days\n2. CLEAN=\"${CLEAN}hours\"    <---setup cleanup every ${CLEAN:-} hours\n3. CLEAN=\"${CLEAN}minutes\"  <---setup cleanup every ${CLEAN:-} minutes"
          else
            echo -e "${c_green}Done Cleaning; Next Cleanup and Check Will Be Done in $clean_num $clean_unit...${c_reset}"
          fi
      fi
    fi
  else 
      _run_auto_cleanup
  fi
  # Stats
  case "$SHOW_STATS" in
    y|yes) 
      print_line
      statinfo 
      ;;
  esac
  # Time and Runtime
  time_end

  if [[ -n "${CLEAN:-}" && -z "${policies[*]}" ]] ; then
    clean_num="${CLEAN//[A-Za-z]/}"
    clean_unit="${CLEAN//[0-9]/}"
    echo "[rescript] noted that your CLEAN variable is ${CLEAN:-}, so [rescript] assumes that"
    echo "you want to perform a 'cleanup' (forget, prune and check) every $clean_num $clean_unit but"
    echo "it can't execute it if you have not set the KEEP variables; please set your"
    echo "desired KEEP values in order to perform the 'cleanup' every $clean_num $clean_unit. If you"
    echo "don't want [rescript] to 'cleanup' your repo automatically every $clean_num $clean_unit,"
    echo "just leave the CLEAN variable blank in your cofiguration file and this"
    echo "message will not appear again."
    echo ""
    echo "For more info about this subject:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
  fi
}
