# ============================================================== #
#                           BACKUP                               #
# ============================================================== #

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
      local spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        echo -e "${c_red}The PRE_CMD [$PRE_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi
  debug_start
  set_sim_flag "Backup"
  if [[ "$skip_flag" = "true" ]] ; then
    bu_opts+=( --exclude="**/.~lock.*" )
  fi
  run_restic_with_retry backup "${sim_flags[@]}" --verbose "${bu_opts[@]}" "${rest[@]}" "${BACKUP_DIR[@]}"
  local restic_rc=$?
  check_restic_error $restic_rc
  debug_stop

  if [[ -n "$POST_CMD" && "${RESCRIPT_SKIP_HOOKS:-}" != "true" ]] ; then
    if [[ "$simulate_flag" == "true" ]]; then
      echo -e "${c_cyan}Running POST_CMD...${c_reset}"
      echo -e "${c_yellow}SIMULATE: $POST_CMD${c_reset}"
    else
      run_with_spinner "$POST_CMD" "${c_cyan}Running POST_CMD...${c_reset}"
      local spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        echo -e "${c_red}The POST_CMD [$POST_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi

}
