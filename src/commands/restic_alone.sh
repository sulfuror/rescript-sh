function restic_alone {
  rescript_lock
  debug_start
  print_context
  restic "${rest[@]}"
  latest_cmd=$prev_cmd exit_code="$?"
  debug_stop
  rest_cmd="${rest[0]}"
  case "$rest_cmd" in
    --repo=*) rest_cmd="${rest[1]}" ;;
    -r*|--repo*) rest_cmd="${rest[2]}" ;;
  esac
  latest_error
}

