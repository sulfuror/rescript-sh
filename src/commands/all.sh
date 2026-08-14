# ============================================================== #
#                          COMMAND: ALL                          #
# ============================================================== #

command_all() {
  local excluded_repos=()
  local forward_args=()
  local parallel_execution="false"
  
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -P|--parallel)
        parallel_execution="true"
        shift 1
        ;;
      --ignore-repo|-X)
        if [[ -n "${2:-}" && "${2:-}" != -* ]]; then
          excluded_repos+=("${2:-}")
          shift 2
        else
          printf "%s\n" "Error: --ignore-repo requires a repository name."
          exit 1
        fi
        ;;
      --ignore-repo=*)
        excluded_repos+=("${1#*=}")
        shift 1
        ;;
      *)
        forward_args+=("${1:-}")
        shift 1
        ;;
    esac
  done

  local has_help=false
  local arg
  for arg in ${forward_args[@]:+"${forward_args[@]}"}; do
    if [[ "$arg" == "-h" || "$arg" == "--help" || "$arg" == "help" ]]; then
      has_help=true
      break
    fi
  done

  if [[ "$has_help" == "true" ]]; then
    if [[ ${#forward_args[@]} -eq 1 ]]; then
      printf "%s\n" "Usage: rescript all [command] [flags] ..."
      printf "\n"
      printf "%s\n" "The 'all' keyword executes a command across ALL configured"
      printf "%s\n" "repositories sequentially (or in parallel with -P)."
      printf "\n"
      printf "%s\n" "Flags specific to 'all':"
      printf "%s\n" "  -P, --parallel              Execute on all repositories in parallel."
      printf "%s\n" "  -X, --ignore-repo <repo>    Exclude a repository. Can be used multiple times."
      printf "\n"
      printf "%s\n" "Examples:"
      printf "%s\n" "  rescript all backup -q"
      printf "%s\n" "  rescript all cleanup --simulate --ignore-repo [repo_name]"
      printf "%s\n" "  rescript all backup --parallel"
      exit 0
    fi
  fi
  
  if [[ "$parallel_execution" == "true" ]]; then
    local has_quiet=false
    for arg in ${forward_args[@]:+"${forward_args[@]}"}; do
      if [[ "$arg" == "-Q" || "$arg" == "--quiet" ]]; then
        has_quiet=true
        break
      fi
    done
    if [[ "$has_quiet" == "false" ]]; then
      forward_args+=("-Q")
    fi
    export RESCRIPT_LOG_ON_ERROR="true"
  fi
  
  if [[ ! -d "$config_dir" ]]; then
    printf "%s\n" "No repositories configured."
    exit 1
  fi
  
  local repos=()
  get_repo_list ${excluded_repos[@]:+"${excluded_repos[@]}"}
  
  if [[ ${#repos[@]} -eq 0 ]]; then
    printf "%s\n" "No repositories found or all were excluded."
    exit 0
  fi
  
  local repo_list
  if [[ "$parallel_execution" == "true" ]]; then
    repo_list=$(IFS=', '; printf "%s\n" "${repos[*]}")
    printf "%b\n" "${c_cyan}Running on repositories: ${c_white}$repo_list${c_cyan} (in parallel, enforcing quiet mode)${c_reset}"
  fi
  
  local has_metadata=false
  local is_automatic=false
  local is_simulate=false
  for arg in ${forward_args[@]:+"${forward_args[@]}"}; do
    if [[ "$arg" == "-S" || "$arg" == "--simulate" ]]; then
      is_simulate=true
    fi
    if [[ "$arg" == "-M" || "$arg" == "--metadata" ]]; then
      has_metadata=true
    fi
    if [[ "$arg" == "automatic" ]]; then
      is_automatic=true
    fi
    case "$arg" in
      status)
        printf "%s\n" "Invalid option for [all]: [$arg]..."
        printf "\n"
        status-help
        exit 1
        ;;
      config|editor|install|uninstall|update|version)
        printf "%s\n" "[$arg] is a global command..."
        printf "\n"
        "$arg-help"
        exit 1
        ;;
    esac
  done
  
  if [[ ${#forward_args[@]} -eq 0 ]]; then
    is_automatic=true
  fi

  local config_global="$HOME/.rescript/config/global.conf"
  if [[ -f "$config_global" ]]; then
    source_config "$config_global"
  fi
  
  local spinner_rc
  if [[ -n "${PRE_CMD:-}" ]] ; then
    if [[ "$is_simulate" == "true" ]]; then
      printf "%b\n" "${c_cyan}Running Global PRE_CMD...${c_reset}"
      printf "%b\n" "${c_yellow}SIMULATE: $PRE_CMD${c_reset}"
    else
      spinner_rc=0
      run_with_spinner "$PRE_CMD" "${c_cyan}Running Global PRE_CMD...${c_reset}" || spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        printf "%b\n" "${c_red}The Global PRE_CMD [$PRE_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi
  
  export RESCRIPT_SKIP_HOOKS="true"

  local pids=()
  local r_name
  for r_name in "${repos[@]}"; do
    if [[ "$has_metadata" == "false" && "$is_automatic" == "false" && "$parallel_execution" == "false" ]]; then
      if [[ "$has_help" == "false" ]]; then
        print_line "="
        printf "${c_white}Running on repository:${c_reset} ${c_cyan}%s${c_reset}\n" "$r_name"
        print_line "="
      fi
    fi
    
    if [[ "$parallel_execution" == "true" ]]; then
      if command -v setsid >/dev/null 2>&1; then
        setsid "$0" "$r_name" ${forward_args[@]:+"${forward_args[@]}"} < /dev/null &
      else
        "$0" "$r_name" ${forward_args[@]:+"${forward_args[@]}"} < /dev/null &
      fi
      pids+=($!)
    else
      "$0" "$r_name" ${forward_args[@]:+"${forward_args[@]}"} || true
      if [[ "$has_help" == "true" ]]; then
        exit 0
      fi
      printf "\n"
    fi
  done
  
  local action_msg
  if [[ "$parallel_execution" == "true" ]]; then
    action_msg="automatic"
    if [[ ${#forward_args[@]} -gt 0 ]]; then
      action_msg="${forward_args[0]}"
    fi
    printf "%bRunning [%s] in parallel for all repositories...%b\n" "$c_cyan" "$action_msg" "$c_reset"
    wait_with_spinner "Working..." "${pids[@]}"

    local fail_count=0
    local failed_repos=()

    for i in "${!pids[@]}"; do
      if ! wait "${pids[$i]}" 2>/dev/null; then
        fail_count=$((fail_count + 1))
        failed_repos+=("${repos[$i]}")
      fi
    done

    if [[ $fail_count -eq 0 ]]; then
      printf "\r\e[K%bAll parallel jobs finished successfully!%b\n" "$c_green" "$c_reset"
    else
      printf "\r\e[K%bFinished with errors ($fail_count failed):%b\n" "$c_red" "$c_reset"
      for f_repo in ${failed_repos[@]:+"${failed_repos[@]}"}; do
        printf "%b\n" "${c_red} [$f_repo] failed. Please check its logs.${c_reset}"
      done
    fi
  fi
  
  if [[ -n "${POST_CMD:-}" ]] ; then
    if [[ "$is_simulate" == "true" ]]; then
      printf "%b\n" "${c_cyan}Running Global POST_CMD...${c_reset}"
      printf "%b\n" "${c_yellow}SIMULATE: $POST_CMD${c_reset}"
    else
      spinner_rc=0
      run_with_spinner "$POST_CMD" "${c_cyan}Running Global POST_CMD...${c_reset}" || spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        printf "%b\n" "${c_red}The Global POST_CMD [$POST_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi
}

if [[ "${1:-}" == "all" ]]; then
  shift 1
  command_all "$@"
  exit 0
fi
