function restorer {
  rescript_lock
  if [[ "$host_flag" ]] ; then
    restore_dir="$HOME/restore-latest-host-${host_flag}_$(date +%s)"
    restore_opts="--host $host_flag"
  elif [[ "$path_flag" ]] ; then
    restore_dir="$HOME/restore-latest-by-path_$(date +%s)"
    restore_opts="--path $path_flag"
  elif [[ "$tag_flag" ]] ; then
    restore_dir="$HOME/restore-latest-tag-${tag_flag}_$(date +%s)"
    restore_opts="--tag $tag_flag"
  else
    restore_dir="$HOME/restore-ID-${snap_flag}_$(date +%s)"
    snap_id="$snap_flag"
  fi
  print_context
  echo -e "${c_cyan}Restoring from:${c_reset} ${c_white}$dest...${c_reset}"

  set_sim_flag "Restorer" "--verify"

  if [[ "${snap_id:-}" ]] ; then
    debug_start
    # shellcheck disable=SC2086
    run_restic_with_retry restore "$snap_id" --target "$restore_dir" $sim_flag
    check_restic_error $?
    debug_stop
  else
    debug_start
    # shellcheck disable=SC2086
    run_restic_with_retry restore latest --target "$restore_dir" ${restore_opts:-} $sim_flag
    check_restic_error $?
    debug_stop
  fi
  report_errors
}

