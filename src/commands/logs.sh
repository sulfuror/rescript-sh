# ============================================================== #
#                         COMMAND: LOGS                          #
# ============================================================== #

function logs {
  if [[ "$catlogs" = "false" && "$removelogs" = "false" ]] ; then
    local -a check_logs=( "$logs_dir/$repo"-* )
    if [[ -e "${check_logs[0]}" ]] ; then
      local log_count
      log_count=$(find "$logs_dir" -maxdepth 1 -type f -name "${repo}-*" | wc -l)
      print_line "="
      printf "%b\n" "${c_white}Log Files for Context:${c_reset} ${c_cyan}$repo${c_reset}"
      print_line "="
      find "$logs_dir" -maxdepth 1 -type f -name "${repo}-*" -exec basename {} \; | sort | column
      print_line "-"
      printf "%b\n" "${c_cyan}Total log files: $log_count${c_reset}"
      printf "%b\n" "${c_blue}Your logs are saved at $logs_dir${c_reset}"
      exit 0
    else
      echo "There are no log files to list for [$repo]."
      exit 0
    fi
  elif [[ "$catlogs" = "true" && "$removelogs" = "true" ]] ; then
    echo "You cannot use '--view' and '--remove' at the same time"
    echo ""
    logs-help
    exit 1
  fi
  if [[ "$catlogs" = "true" ]] ; then
    if [[ -z "${logfile:-}" ]]; then
      echo "You must specify a log file to view."
      exit 1
    elif [[ ! -f "$logs_dir/$logfile" ]]; then
      echo "There is no log file called [$logfile]."
      exit 1
    else
      cat "$logs_dir/$logfile"
    fi
  elif [[ "$removelogs" = "true" ]] ; then
    if [[ -z "${logfile:-}" || "$logfile" = "all" ]] ; then
      local -a check_logs=( "$logs_dir/$repo"-* )
      if [[ -e "${check_logs[0]}" ]] ; then
        rm -fv "${logs_dir:?}/$repo"-*
        printf "%b\n" "${c_green}Log files removed for [$repo].${c_reset}"
        exit 0
      else
        echo "There are no log files to remove for [$repo]."
        exit 0
      fi
    else
      if [[ -f "$logs_dir/$logfile" ]] ; then
        rm -fv "${logs_dir:?}/$logfile"
        echo "[$logfile] removed."
        exit 0
      else
        echo "There is no log file called [$logfile]."
        exit 1
      fi
    fi
  fi
}
