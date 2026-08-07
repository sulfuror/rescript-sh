# ============================================================== #
#                        COMMAND: DIFF                           #
# ============================================================== #

function differ {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    mapfile -t snaps < <(run_restic_with_retry snapshots -q | grep -E "^[a-z0-9]{8} " | tail -n 2 | awk '{print $1}')
    if [[ ${#snaps[@]} -lt 2 ]] ; then
      echo "You need at least 2 snapshots to perform a diff."
      exit 1
    fi
    debug_start
    run_restic_with_retry diff "${snaps[0]}" "${snaps[1]}"
    debug_stop
  else
    debug_start
    run_restic_with_retry diff "${rest[@]}"
    debug_stop
  fi
}
