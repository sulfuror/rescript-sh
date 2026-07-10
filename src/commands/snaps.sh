function snaps {
  if [[ "$cmd" != "snaps" ]] ; then
    rm -rf "$lock"
  fi
  rescript_lock
  debug_start
  restic snapshots --compact "${rest[@]}" | awk -v w="$cols" -v cw="${c_white}" -v cr="${c_reset}" -v cg="${c_gray}" '
    { gsub(/\r/, "") }
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

