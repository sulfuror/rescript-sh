function restic_alone {
  rescript_lock
  debug_start
  print_context
  run_restic_with_retry "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  local rest_cmd=""
  if [[ ${#rest[@]} -gt 0 ]]; then
    rest_cmd="${rest[0]}"
    case "$rest_cmd" in
      --repo=*) rest_cmd="${rest[1]:-}" ;;
      -r*|--repo*) rest_cmd="${rest[2]:-}" ;;
    esac
  fi
  latest_error
}

