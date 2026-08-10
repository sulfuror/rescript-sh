# ============================================================== #
#                             CORE                               #
# ============================================================== #

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

if [[ "${1:-}" == "all" ]]; then
  shift 1
  excluded_repos=()
  forward_args=()
  parallel_execution="false"
  
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
          echo "Error: --ignore-repo requires a repository name."
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

  has_help=false
  for arg in "${forward_args[@]}"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" || "$arg" == "help" ]]; then
      has_help=true
      break
    fi
  done

  if [[ "$has_help" == "true" ]]; then
    if [[ ${#forward_args[@]} -eq 1 ]]; then
      echo "Usage: rescript all [command] [flags] ..."
      echo ""
      echo "The 'all' keyword executes a command across ALL configured"
      echo "repositories sequentially (or in parallel with -P)."
      echo ""
      echo "Flags specific to 'all':"
      echo "  -P, --parallel              Execute on all repositories in parallel."
      echo "  -X, --ignore-repo <repo>    Exclude a repository. Can be used multiple times."
      echo ""
      echo "Examples:"
      echo "  rescript all backup -q"
      echo "  rescript all cleanup --simulate --ignore-repo [repo_name]"
      echo "  rescript all backup --parallel"
      exit 0
    fi
  fi
  
  if [[ "$parallel_execution" == "true" ]]; then
    has_quiet=false
    for arg in "${forward_args[@]}"; do
      if [[ "$arg" == "-Q" || "$arg" == "--quiet" ]]; then
        has_quiet=true
        break
      fi
    done
    if [[ "$has_quiet" == "false" ]]; then
      forward_args+=("-Q")
    fi
    
  fi
  
  if [[ ! -d "$config_dir" ]]; then
    echo "No repositories configured."
    exit 1
  fi
  
  get_repo_list repos "${excluded_repos[@]}"
  
  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "No repositories found or all were excluded."
    exit 0
  fi
  
  if [[ "$parallel_execution" == "true" ]]; then
    repo_list=$(IFS=', '; echo "${repos[*]}")
    echo -e "${c_cyan}Running on repositories: ${c_white}$repo_list${c_cyan} (in parallel, enforcing quiet mode)${c_reset}"
  fi
  
  has_metadata=false
  is_automatic=false
  is_simulate=false
  for arg in "${forward_args[@]}"; do
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
        echo "Invalid option for [all]: [$arg]..."
        echo ""
        status-help
        exit 1
        ;;
      config|editor|install|uninstall|update|version)
        echo "[$arg] is a global command..."
        echo ""
        "$arg-help"
        exit 1
        ;;
    esac
  done
  
  if [[ ${#forward_args[@]} -eq 0 ]]; then
    is_automatic=true
  fi

  config_global="$HOME/.rescript/config/global.conf"
  if [[ -f "$config_global" ]]; then
    source_config "$config_global"
  fi
  
  if [[ -n "${PRE_CMD:-}" ]] ; then
    if [[ "$is_simulate" == "true" ]]; then
      echo -e "${c_cyan}Running Global PRE_CMD...${c_reset}"
      echo -e "${c_yellow}SIMULATE: $PRE_CMD${c_reset}"
    else
      run_with_spinner "$PRE_CMD" "${c_cyan}Running Global PRE_CMD...${c_reset}"
      spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        echo -e "${c_red}The Global PRE_CMD [$PRE_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi
  
  export RESCRIPT_SKIP_HOOKS="true"

  for r_name in "${repos[@]}"; do
    if [[ "$has_metadata" == "false" && "$is_automatic" == "false" && "$parallel_execution" == "false" ]]; then
      if [[ "$has_help" == "false" ]]; then
        print_line "="
        printf "${c_white}Running on repository:${c_reset} ${c_cyan}%s${c_reset}\n" "$r_name"
        print_line "="
      fi
    fi
    
    if [[ "$parallel_execution" == "true" ]]; then
      "$0" "$r_name" "${forward_args[@]}" &
    else
      "$0" "$r_name" "${forward_args[@]}" || true
      if [[ "$has_help" == "true" ]]; then
        exit 0
      fi
      echo ""
    fi
  done
  
  if [[ "$parallel_execution" == "true" ]]; then
    wait
    echo -e "${c_green}All parallel jobs finished!${c_reset}"
  fi
  
  if [[ -n "${POST_CMD:-}" ]] ; then
    if [[ "$is_simulate" == "true" ]]; then
      echo -e "${c_cyan}Running Global POST_CMD...${c_reset}"
      echo -e "${c_yellow}SIMULATE: $POST_CMD${c_reset}"
    else
      run_with_spinner "$POST_CMD" "${c_cyan}Running Global POST_CMD...${c_reset}"
      spinner_rc=$?
      if [[ $spinner_rc -ne 0 ]] ; then
        echo -e "${c_red}The Global POST_CMD [$POST_CMD] has failed.${c_reset}"
        exit 1
      fi
    fi
  fi
  
  exit 0
fi

if [[ ! "${1:-}"  ]] ; then
  usage
  exit 1
fi

function _check_help_or_error {
  local cmd="${1:-}"
  local arg="${2:-}"
  if [[ "$arg" ]] ; then
    case "$arg" in
      -h|--help|help)
        "$cmd-help"
        exit 0
        ;;
      *)
        echo "Invalid option [$arg]..."
        echo ""
        "$cmd-help"
        exit 1
        ;;
    esac
  fi
}

case "${1:-}" in
  backup|cleanup|diff|extract|search|init|history|info|logs|mounter|restorer|size|snaps|umounter|unlocker)
    _check_help_or_error "${1:-}" "${2:-}"
    echo "You have not indicated any repo for [$1]..."
    echo ""
    "${1:-}"-help
    exit 1
    ;;
  status)
    parse_generic_args status-help "${@:2}"
    execute_with_metrics run_quietly global_status "${rest[@]}"
    exit 0
    ;;
  config)
    parse_generic_args config-help "${@:2}"
    execute_with_metrics run_quietly rescript_config "${rest[@]}"
    exit 0
    ;;
  editor)
    _check_help_or_error "${1:-}" "${2:-}"
    rescript_editor_cmd
    exit 0
    ;;
  -h|--help|help)
    if [[ ! "${2:-}" ]] ; then
      usage
      exit  
    fi
    case "${2:-}" in
      backup|cleanup|config|diff|editor|env|extract|history|info|install|logs|mounter|next|restorer|search|size|snaps|umounter|unlocker|update|upgrade)
        "${2:-}"-help
        exit 1
        ;;
      *)  
        echo "You have not indicated a valid option..."
        usage | sed -ne '/Usage/,/EOF/p'
        exit 1
        ;;
    esac
    ;;
  install)
    if [[ "${2:-}" == "--autocomplete-only" ]]; then
      install "${2:-}" "${3:-}"
      exit
    fi
    _check_help_or_error "${1:-}" "${2:-}"
    clear
    install
    exit
    ;;
  uninstall)
    _check_help_or_error "${1:-}" "${2:-}"
    clear
    uninstall
    exit
    ;;

  update)
    _check_help_or_error "${1:-}" "${2:-}"
    update
    exit
    ;;
  -v|--version|version)
    usage | sed -ne '/Name/,/Version/p'
    echo ""
    echo -e 'Redistribution and use in source and binary forms, with or without \nmodification, are permitted provided that the BSD 2-Clause License \nconditions are met.'
    exit
    ;;
  *)
    if [[ ! -e "$config_dir/$1.conf" && ! -e "$config_dir/$1.conf.gpg" ]] ; then
      echo "There is no repo or command for [$1]. Indicate a valid"
      echo "repo name or command to proceed. Use [rescript help] for usage."
      exit
    fi
    ;;
esac

# ============================================================== #
# Configuration & Variables                                      #
# ============================================================== #

if [[ -f "$config_global" ]]; then
  source_config "$config_global"
fi

source_config "$config_repo"

# Defaulting unset variables from config for strict mode
export HOST="${HOST:-}"
export CLEAN="${CLEAN:-}"
export PRE_CMD="${PRE_CMD:-}"
export POST_CMD="${POST_CMD:-}"
export EXCLUDE_CACHE="${EXCLUDE_CACHE:-}"
export EXCLUDE_FILE="${EXCLUDE_FILE:-}"
export ONE_FILE_SYSTEM="${ONE_FILE_SYSTEM:-}"
export TAG="${TAG:-}"
export LOG_RETENTION="${LOG_RETENTION:-}"
export SKIP_OFFICE="${SKIP_OFFICE:-}"
export SHOW_SNAPS="${SHOW_SNAPS:-}"
export SHOW_STATS="${SHOW_STATS:-}"
export CONFIRMATION_EMAIL="${CONFIRMATION_EMAIL:-}"
export DESTINATION="${DESTINATION:-}"
export RESTIC_REPOSITORY="${RESTIC_REPO:-}"
export B2_ACCOUNT_ID="${B2_ID:-}"
export B2_ACCOUNT_KEY="${B2_KEY:-}"
export AWS_ACCESS_KEY_ID="${AWS_ID:-}"
export AWS_SECRET_ACCESS_KEY="${AWS_KEY:-}"
export AZURE_ACCOUNT_NAME="${AZURE_NAME:-}"
export AZURE_ACCOUNT_KEY="${AZURE_KEY:-}"
export GOOGLE_PROJECT_ID="${GOOGLE_ID:-}"
export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_CREDENTIALS:-}"

if [[ -n "${RESCRIPT_PASS:-}" ]] ; then
  export RESTIC_PASSWORD="$RESCRIPT_PASS"
else
  export RESTIC_PASSWORD="${RESTIC_PASSWORD:-}"
fi

export RESTIC_PASSWORD_COMMAND="${RESTIC_PASSWORD_COMMAND:-}"
export RESTIC_COMPRESSION="${RESTIC_COMPRESSION:-auto}"
SECONDS=0



case "${RESTIC_REPO:-}" in
  sftp*) ping_target=${RESTIC_REPO#sftp*@} ; ping_target=${ping_target%:*} ; ping_code=0; ping -c 1 "$ping_target" > /dev/null 2>&1 || ping_code=$? ;;
  rclone*) ping_target=${RESTIC_REPO#rclone:} ; ping_code=0; rclone about "$ping_target" > /dev/null 2>&1 || ping_code=$? ;;
  /*) ping_code=0; [[ -d "$RESTIC_REPO" ]] || ping_code=1 ;;
esac

if [[ "$ping_code" -gt "0" ]] ; then
  error_message="Cannot access to: ${RESTIC_REPO:-} \nPlease check your connection. If your repository is not \ninitializated run [rescript $repo init]."
  report_errors
  exit "$ping_code"
fi

if [[ -n "${DESTINATION:-}" ]] ; then
  dest=$DESTINATION
else
  dest=${RESTIC_REPO:-}
fi

if [[ -n "${HOST:-}" ]] ; then
  rhost="$HOST"
else
  rhost=$(hostname)
fi

declare -a policies=()

# Set variables for functions
if [[ -n "${KEEP_LAST:-}" && "$KEEP_LAST" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-last "$KEEP_LAST")
fi
if [[ -n "${KEEP_HOURLY:-}" && "$KEEP_HOURLY" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-hourly "$KEEP_HOURLY")
fi
if [[ -n "${KEEP_DAILY:-}" && "$KEEP_DAILY" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-daily "$KEEP_DAILY")
fi
if [[ -n "${KEEP_WEEKLY:-}" && "$KEEP_WEEKLY" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-weekly "$KEEP_WEEKLY")
fi
if [[ -n "${KEEP_MONTHLY:-}" && "$KEEP_MONTHLY" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-monthly "$KEEP_MONTHLY")
fi
if [[ -n "${KEEP_YEARLY:-}" && "$KEEP_YEARLY" -gt "0" ]] 2>/dev/null ; then
  policies+=(--keep-yearly "$KEEP_YEARLY")
fi
if [[ -n "${KEEP_WITHIN:-}" ]] ; then
  policies+=(--keep-within "$KEEP_WITHIN")
fi
if [[ -n "${KEEP_TAG:-}" ]] ; then
  policies+=(--keep-tag "$KEEP_TAG")
fi
