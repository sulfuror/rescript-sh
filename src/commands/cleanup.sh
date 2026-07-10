function cleanup {
  print_context
  rescript_lock

  set_sim_flag "Cleanup"

  if [[ -n "${policies[*]}" ]] ; then
    debug_start
    restic forget $sim_flag "${policies[@]}" "${rest[@]}"
    check_restic_error $?
    debug_stop
    debug_start
    restic prune $sim_flag --cleanup-cache
    check_restic_error $?
    debug_stop
  else
    echo "You have not indicated any policy value..."
    echo "If you want to use [cleanup] option you need to set the [KEEP] variables."
    echo "For more information about the Usage check out the following link:"
    echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
  fi
}

