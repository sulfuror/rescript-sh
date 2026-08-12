# ============================================================== #
#                          COMMAND: ENV                          #
# ============================================================== #

env_conf() {
  local title
  local padding

  if [[ "${var_flag:-}" ]] ; then
    local upper_var="${var_flag^^}"
    print_line "="
    printf "%b\n" "${c_white}Variable: ${c_cyan}$upper_var${c_reset}"
    print_line "="
    
    awk -v var="${upper_var:-}" -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" '
    BEGIN { in_array = 0; found = 0 }
    /^#/ { next }
    /^[[:space:]]*$/ { next }
    /^[A-Z0-9_]+=/ {
      key = $0
      sub(/=.*/, "", key)
      
      if (var != "" && index(key, var) == 0) {
        skip = 1
      } else {
        skip = 0
        found = 1
      }
      
      if (!skip) {
        val = $0
        sub(/^[^=]*=/, "", val)
        
        if ((key ~ /PASSWORD/ || key ~ /KEY/) && val != "\"\"" && val != "") {
          val = "\"********\""
          hidden = 1
        } else {
          hidden = 0
        }
        
        printf "  %s%-25s%s : %s%s", cw, key, cr, cc, val
        
        if (val ~ /\(\s*$/) {
          in_array = 1
        } else {
          printf "%s\n", cr
          in_array = 0
        }
      }
      next
    }
    {
      if (in_array && !skip) {
        if (!hidden) {
          printf "\n  %s", $0
        }
        if ($0 ~ /^\s*\)\s*$/) {
          in_array = 0
          if (!hidden) {
            printf "%s\n", cr
          }
        }
      }
    }
    END {
      if (var != "" && !found) {
        exit 1
      }
    }' "$config_repo" || {
      printf "%b\n" "\nThere is no var named [$var_flag]..."
      printf "\n"
      env-help
      exit 1
    }
  else
    print_line "="
    printf "%b\n" "${c_white}Configuration Context: ${c_cyan}$repo${c_reset}"
    print_line "="
    
    awk -v var="" -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" '
    BEGIN { in_array = 0; found = 0 }
    /^#/ { next }
    /^[[:space:]]*$/ { next }
    /^[A-Z0-9_]+=/ {
      key = $0
      sub(/=.*/, "", key)
      
      skip = 0
      found = 1
      
      if (!skip) {
        val = $0
        sub(/^[^=]*=/, "", val)
        
        if ((key ~ /PASSWORD/ || key ~ /KEY/) && val != "\"\"" && val != "") {
          val = "\"********\""
          hidden = 1
        } else {
          hidden = 0
        }
        
        printf "  %s%-25s%s : %s%s", cw, key, cr, cc, val
        
        if (val ~ /\(\s*$/) {
          in_array = 1
        } else {
          printf "%s\n", cr
          in_array = 0
        }
      }
      next
    }
    {
      if (in_array && !skip) {
        if (!hidden) {
          printf "\n  %s", $0
        }
        if ($0 ~ /^\s*\)\s*$/) {
          in_array = 0
          if (!hidden) {
            printf "%s\n", cr
          }
        }
      }
    }' "$config_repo"
  fi
}
