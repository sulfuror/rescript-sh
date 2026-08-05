# ============================================================== #
#                         COMMAND: LOGS                          #
# ============================================================== #

function logs {
  if [[ "$catlogs" = "false" && "$removelogs" = "false" ]] ; then
    if ls "$logs_dir/$repo"-* 1> /dev/null 2>&1 ; then
      local log_count
      log_count=$(find "$logs_dir" -maxdepth 1 -type f -name "*$repo*" | wc -l)
      print_line "="
      echo -e "${c_white}Log Files for Context:${c_reset} ${c_cyan}$repo${c_reset}"
      print_line "="
      find "$logs_dir" -maxdepth 1 -type f -name "*$repo*" -exec basename {} \; | sort | column
      print_line "-"
      echo -e "${c_cyan}Total log files: $log_count${c_reset}"
      echo -e "${c_blue}Your logs are saved at $logs_dir${c_reset}"
      exit 0
    else
      echo "There are no log files to list for [$repo]."
      exit 0
    fi
  elif [[ "$catlogs" = "true" && "$removelogs" = "true" ]] ; then
    echo "You cannot use '--cat' and '--remove' at the same time"
    echo ""
    logs-help
    exit 1
  fi
  if [[ "$catlogs" = "true" ]] ; then
    cat "$logs_dir/$logfile"
  elif [[ "$removelogs" = "true" ]] ; then
    if [[ "$logfile" = "all" ]] ; then
      if ls "$logs_dir/$repo"-* 1> /dev/null 2>&1 ; then
        rm -fv "${logs_dir:?}/$repo"-*
        echo -e "${c_green}Log files removed for [$repo].${c_reset}"
        exit 0
      else
        echo "There are no log files to remove for [$repo]."
        exit 0
      fi
    else
      if ls "$logs_dir/$logfile" 1> /dev/null 2>&1 ; then
        rm -fv "${logs_dir:?}/$logfile"
        echo "[$logfile] removed."
        exit 0
      else
        echo "There are is log file called [$logfile]."
        exit 1
      fi
    fi
  else
    echo "Something is not right."
    exit 1
  fi
}
