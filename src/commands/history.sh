function history {
  rescript_lock
  if [[ ${#rest[@]} -eq 0 ]] ; then
    echo "You must provide a pattern or file path to search history for."
    exit 1
  fi
  
  local col_no=5
  local col_snap=10
  local col_date=21
  local col_size=12
  local col_path=$(( cols - col_no - col_snap - col_date - col_size - 7 ))
  
  print_line "="
  printf "${c_white}%-4s | %-10s | %-21s | %-12s | %s${c_reset}\n" "No" "Snapshot" "Date" "Size" "Path"
  print_line "="
  
  debug_start
  restic find -l "${rest[@]}" | awk -v path_len="$col_path" '
  {
    gsub(/\x1b\[[0-9;]*[a-zA-Z]/, "")
    gsub(/\r/, "")
  }
  /Found matching entries in snapshot/ {
      for(i=1; i<=NF; i++) {
          if ($i == "snapshot") {
              snap = substr($(i+1), 1, 8)
              break
          }
      }
      next
  }
  /^[-dcbp](r|-)[w|-](x|-)(r|-)[w|-](x|-)(r|-)[w|-](x|-)/ {
      size_val = $4
      date = $5 " " $6
      path = $7
      for (j=8; j<=NF; j++) {
          path = path " " $j
      }
      
      if (size_val != last_size || date != last_date) {
          if (size_val >= 1024^3) size_str = sprintf("%.1fG", size_val / (1024^3))
          else if (size_val >= 1024^2) size_str = sprintf("%.1fM", size_val / (1024^2))
          else if (size_val >= 1024) size_str = sprintf("%.1fK", size_val / 1024)
          else size_str = sprintf("%dB", size_val)
          
          count++
          printf "%-4d | %-10s | %-21s | %-12s | %s\n", count, snap, date, size_str, path
          last_size = size_val
          last_date = date
      }
  }'
  debug_stop
  
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "History search failed or no matches found."
  fi
}
