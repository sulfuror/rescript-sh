function backup {
  print_context
  declare -a bu_opts=()
  if [[ "${EXCLUDE_CACHE:-}" = "yes" || "${EXCLUDE_CACHE:-}" = "y" || -z "${EXCLUDE_CACHE:-}" ]] ; then
    bu_opts+=( --exclude-caches )
  fi
  if [[ "${EXCLUDE_FILE:-}" = "yes" || "${EXCLUDE_FILE:-}" = "y" || -z "${EXCLUDE_FILE:-}" ]] ; then
    bu_opts+=( --exclude-file="$excludes" )
  fi
  if [[ "${ONE_FILE_SYSTEM:-}" = "yes" || "${ONE_FILE_SYSTEM:-}" = "y" ]] ; then
    bu_opts+=( --one-file-system )
  fi
  if [[ -n "$HOST" ]] ; then
    bu_opts+=( --host="$HOST" )
  fi
  if [[ -n "${TAG:-}" ]] ; then
    bu_opts+=( --tag="${TAG:-}" )
  fi
  if [[ -n "$RESTIC_COMPRESSION" ]] ; then
    bu_opts+=( --compression="$RESTIC_COMPRESSION" )
  fi
  rescript_lock
  
  if [[ -n "$PRE_CMD" && "${RESCRIPT_SKIP_HOOKS:-}" != "true" ]] ; then
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_cyan}Running PRE_CMD...${c_reset}"
      echo -e "${c_yellow}SIMULATE: $PRE_CMD${c_reset}"
    else
      run_with_spinner "$PRE_CMD" "${c_cyan}Running PRE_CMD...${c_reset}"
      if [[ $? -ne 0 ]] ; then
        exit 1
      fi
    fi
  fi
  debug_start
  set_sim_flag "Backup"
  if [[ "$skip_flag" = "true" ]] ; then
    run_restic_with_retry backup $sim_flag --verbose "${bu_opts[@]}" --exclude-file=<(find "${BACKUP_DIR[@]}" -iname ".~lock.*" 2> /dev/null | sed -e 's/.~lock.//g' | sed -e 's/#//g') --exclude=".~lock.*" "${rest[@]}" "${BACKUP_DIR[@]}"
  else
    run_restic_with_retry backup $sim_flag --verbose "${bu_opts[@]}" "${rest[@]}" "${BACKUP_DIR[@]}"
  fi
  check_restic_error $?
  debug_stop

  if [[ -n "$POST_CMD" && "${RESCRIPT_SKIP_HOOKS:-}" != "true" ]] ; then
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_cyan}Running POST_CMD...${c_reset}"
      echo -e "${c_yellow}SIMULATE: $POST_CMD${c_reset}"
    else
      run_with_spinner "$POST_CMD" "${c_cyan}Running POST_CMD...${c_reset}"
    fi
  fi

}




