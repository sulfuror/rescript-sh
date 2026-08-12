# ============================================================== #
#                        COMMAND: CLEANUP                        #
# ============================================================== #
cleanup() {
  print_context
  rescript_lock

  set_sim_flag "Cleanup"

  if [[ ${#policies[@]} -gt 0 ]] ; then
    debug_start
    run_restic_with_retry forget ${sim_flags[@]:+"${sim_flags[@]}"} "${policies[@]}" ${rest[@]:+"${rest[@]}"}
    check_restic_error $?
    debug_stop
    debug_start
    run_restic_with_retry prune ${sim_flags[@]:+"${sim_flags[@]}"} --cleanup-cache
    check_restic_error $?
    debug_stop
  else
    printf "%s\n" "You have not indicated any policy value..."
    printf "%s\n" "If you want to use [cleanup] option you need to set the [KEEP] variables."
    printf "%s\n" "For more information about the usage check out the following link:"
    printf "%s\n" "https://github.com/sulfuror/rescript-sh/blob/master/README.md#usage"
  fi
}
