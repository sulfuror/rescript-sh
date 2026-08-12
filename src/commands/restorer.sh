# ============================================================== #
#                       COMMAND: RESTORER                        #
# ============================================================== #

restorer() {
  rescript_lock
  local -a restore_opts=()
  local -a snap_list=()
  local sel_snap snap_id restore_dir
  if [[ "${interactive_flag:-}" == "true" ]] ; then
    printf "%b\n" "${c_cyan}Fetching snapshot list...${c_reset}"
    while IFS= read -r line; do
      snap_list+=("$line")
    done < <(run_restic_with_retry snapshots 2>/dev/null | grep -E '^[0-9a-f]{8}')
    if [[ ${#snap_list[@]} -eq 0 ]]; then
      printf "%s\n" "No snapshots found to restore."
      exit 1
    fi
    printf "%b\n" "${c_cyan}Select a snapshot to restore:${c_reset}"
    PS3="Enter the number of the snapshot: "
    select sel_snap in "${snap_list[@]}" "Cancel"; do
      if [[ "$sel_snap" == "Cancel" ]]; then
        printf "%s\n" "Canceled."
        exit 0
      elif [[ -n "$sel_snap" ]]; then
        snap_id="${sel_snap%% *}"
        restore_dir="$HOME/restore-ID-${snap_id}_$(date +%s)"
        break
      else
        printf "%s\n" "Invalid selection."
      fi
    done
  elif [[ "$host_flag" ]] ; then
    restore_dir="$HOME/restore-latest-host-${host_flag}_$(date +%s)"
    restore_opts=("--host" "$host_flag")
  elif [[ "$path_flag" ]] ; then
    restore_dir="$HOME/restore-latest-by-path_$(date +%s)"
    restore_opts=("--path" "$path_flag")
  elif [[ "$tag_flag" ]] ; then
    restore_dir="$HOME/restore-latest-tag-${tag_flag}_$(date +%s)"
    restore_opts=("--tag" "$tag_flag")
  else
    restore_dir="$HOME/restore-ID-${snap_flag}_$(date +%s)"
    snap_id="$snap_flag"
  fi
  print_context
  printf "%b\n" "${c_cyan}Restoring from:${c_reset} ${c_white}$dest...${c_reset}"

  set_sim_flag "Restorer" "--verify"

  if [[ "${snap_id:-}" ]] ; then
    debug_start
    # shellcheck disable=SC2086
    run_restic_with_retry restore "$snap_id" --target "$restore_dir" ${sim_flags[@]:+"${sim_flags[@]}"} ${rest[@]:+"${rest[@]}"}
    check_restic_error $?
    debug_stop
  else
    debug_start
    run_restic_with_retry restore latest --target "$restore_dir" ${restore_opts[@]:+"${restore_opts[@]}"} ${sim_flags[@]:+"${sim_flags[@]}"} ${rest[@]:+"${rest[@]}"}
    check_restic_error $?
    debug_stop
  fi
  report_errors
}
