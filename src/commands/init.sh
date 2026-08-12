# ============================================================== #
#                          COMMAND: INIT                         #
# ============================================================== #
init() {
  rescript_lock
  debug_start
  print_context
  run_restic_with_retry init ${rest[@]:+"${rest[@]}"}
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
}
