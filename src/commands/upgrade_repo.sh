# ============================================================== #
#                      COMMAND: UPGRADE                          #
# ============================================================== #

function upgrade_repo {
  rescript_lock
  debug_start
  echo "[Upgrading repository format to version 2...]"
  restic migrate upgrade_repo_v2 "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  latest_error
}
