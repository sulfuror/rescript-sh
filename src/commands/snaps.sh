# ============================================================= #
#                           SNAPS                               #
# ============================================================= #

function snaps {
  if [[ "$cmd" != "snaps" ]] ; then
    rm -f "${lock:?}"
  fi
  rescript_lock
  debug_start
  local group_by=0 arg
  for arg in "${rest[@]}"; do
    if [[ "$arg" == "--group-by" || "$arg" == "--group-by="* ]]; then
      group_by=1
      break
    fi
  done

  run_restic_with_retry snapshots --compact "${rest[@]}" | awk -v w="$cols" -v cw="${c_white}" -v cr="${c_reset}" -v cg="${c_gray}" -v gb="$group_by" '
    { gsub(/\r/, "") }
    gb == 1 { print; next }
    /^-+$/ {
      count++
      if (count == 1) {
        printf "%s", cg
        for(i=1; i<=w; i++) printf "="; printf "%s\n", cr
        next
      } else if (count == 2) {
        printf "%s", cg
        for(i=1; i<=w; i++) printf "-"; printf "%s\n", cr
        next
      }
    }
    count == 0 {
      printf "%s", cg
      for(i=1; i<=w; i++) printf "="; printf "%s\n", cr
      print cw $0 cr
      next
    }
    { print }
  '
  latest_cmd=$prev_cmd exit_code="${PIPESTATUS[0]}"
  debug_stop
  latest_error
}
