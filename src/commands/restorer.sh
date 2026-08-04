# ============================================================== #
#                       COMMAND: RESTORER                        #
# ============================================================== #

function restorer {
  rescript_lock
  if [[ "${interactive_flag:-}" == "true" ]] ; then
    echo -e "${c_cyan}Fetching snapshot list...${c_reset}"
    mapfile -t snap_list < <(run_restic_with_retry snapshots 2>/dev/null | grep -E '^[0-9a-f]{8}')
    if [[ ${#snap_list[@]} -eq 0 ]]; then
      echo "No snapshots found to restore."
      exit 1
    fi
    echo -e "${c_cyan}Select a snapshot to restore:${c_reset}"
    PS3="Enter the number of the snapshot: "
    select sel_snap in "${snap_list[@]}" "Cancel"; do
      if [[ "$sel_snap" == "Cancel" ]]; then
        echo "Canceled."
        exit 0
      elif [[ -n "$sel_snap" ]]; then
        snap_id="${sel_snap%% *}"
        restore_dir="$HOME/restore-ID-${snap_id}_$(date +%s)"
        break
      else
        echo "Invalid selection."
      fi
    done
  elif [[ "$host_flag" ]] ; then
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
