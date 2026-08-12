# ============================================================== #
#                      COMMAND: UPGRADE                          #
# ============================================================== #
upgrade_repo() {
  rescript_lock
  debug_start
  printf "%s\n" "[Upgrading repository format to version 2...]"
  restic migrate upgrade_repo_v2 ${rest[@]:+"${rest[@]}"}
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
}
