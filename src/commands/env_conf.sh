function env_conf {
  local title
  local padding

  if [[ "${var_flag:-}" ]] ; then
    upper_var=$(echo "${var_flag:-}" | tr '[:lower:]' '[:upper:]')
    search=$(grep -E "^[[:space:]]*[A-Z0-9_]*${upper_var}[A-Z0-9_]*=" "$config_repo" || true)
    if [[ -z "$search" ]] ; then
      echo "There is no var named [$var_flag]..."
      echo ""
      env-help
      exit 1
    else
      print_line "="
      echo -e "${c_white}Variable: ${c_cyan}$upper_var${c_reset}"
      print_line "="
      
      echo "$search" | awk -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" -F'=' '{
        if (length($1) == 0) next;
        key = $1
        sub(/^[^=]*=/, "", $0)
        val = $0
        if ((key ~ /PASSWORD/ || key ~ /KEY/) && val != "\"\"" && val != "") {
          val = "\"********\""
        }
        printf "  %s%-25s%s : %s%s%s\n", cw, key, cr, cc, val, cr
      }'
    fi
  else
    print_line "="
    echo -e "${c_white}Configuration Context: ${c_cyan}$repo${c_reset}"
    print_line "="
    
    sed '/^#/ d' < "$config_repo" | sed '/^\s*$/d' | awk -v cw="${c_white}" -v cc="${c_cyan}" -v cr="${c_reset}" -F'=' '{
      if (length($1) == 0) next;
      key = $1
      sub(/^[^=]*=/, "", $0)
      val = $0
      if ((key ~ /PASSWORD/ || key ~ /KEY/) && val != "\"\"" && val != "") {
        val = "\"********\""
      }
      printf "  %s%-25s%s : %s%s%s\n", cw, key, cr, cc, val, cr
    }'
  fi
}

