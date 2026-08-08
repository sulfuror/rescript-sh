# ============================================================== #
#                       COMMAND: NEXT                            #
# ============================================================== #

function cleanup-next {
  if [[ ! -f "$config_dir/$repo-datefile" ]] ; then
    touch "$config_dir/$repo-datefile"
  fi
  now_next
  local result=$((next-now))
  local days=$((result / 86400))
  local hours=$(((result / 3600) % 24))
  local minutes=$(((result / 60) % 60))
  local seconds=$((result % 60))
  local d h m s
  if [[ "$days" = "1" ]] ; then
    d="day"
  else
    d="days"
  fi
  if [[ "$hours" = "1" ]] ; then
    h="hour"
  else
    h="hours"
  fi
  if [[ "$minutes" = "1" ]] ; then
    m="minute"
  else
    m="minutes"
  fi
  if [[ "$seconds" = "1" ]] ; then
    s="second"
  else
    s="seconds"
  fi
  if [[ "$days" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $days $d...${c_reset}"
  elif [[ "$hours" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $hours $h...${c_reset}"
  elif [[ "$minutes" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $minutes $m...${c_reset}"
  elif [[ "$seconds" -gt "0" ]] ; then
    echo -e "${c_cyan}Next cleanup and check in $seconds $s...${c_reset}"
  else
    echo -e "${c_cyan}Repo will be cleaned and checked in the next run...${c_reset}"
  fi
}
