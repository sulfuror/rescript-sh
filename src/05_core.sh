# ============================================================== #
# Rescript Commands                                              #
# ============================================================== #
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
    echo -e "${c_cyan}Running jobs in parallel... (enforcing quiet mode)${c_reset}"
  fi
  
  config_dir="$HOME/.rescript/config"
  if [[ ! -d "$config_dir" ]]; then
    echo "No repositories configured."
    exit 1
  fi
  
  repos=()
  for conf in "$config_dir"/*.conf; do
    [ -e "$conf" ] || continue
    repo_name=$(basename "$conf" .conf)
    
    excluded=false
    for ex in "${excluded_repos[@]}"; do
      if [[ "$ex" == "$repo_name" ]]; then
        excluded=true
        break
      fi
    done
    
    if [[ "$excluded" == "false" ]]; then
      repos+=("$repo_name")
    fi
  done
  
  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "No repositories found or all were excluded."
    exit 0
  fi
  
  has_metadata=false
  is_automatic=false
  for arg in "${forward_args[@]}"; do
    if [[ "$arg" == "-M" || "$arg" == "--metadata" ]]; then
      has_metadata=true
    fi
    if [[ "$arg" == "automatic" ]]; then
      is_automatic=true
    fi
  done
  
  if [[ ${#forward_args[@]} -eq 0 ]]; then
    is_automatic=true
  fi

  for r_name in "${repos[@]}"; do
    if [[ "$has_metadata" == "false" && "$is_automatic" == "false" ]]; then
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
  
  exit 0
fi

if [[ ! "${1:-}"  ]] ; then
  echo "You need to indicate the name of your repository or a"
  echo "command; type [rescript help] for usage."
  exit
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
  backup|cleanup|diff|extract|search)
    _check_help_or_error "${1:-}" "${2:-}"
    echo "You have not indicated any repo for [$1]..."
    echo ""
    "${1:-}"-help
    exit 1
    ;;
  config)
    _check_help_or_error "${1:-}" "${2:-}"
    if [[ -z "$rescript_editor" ]] ; then
      select_editor
      echo "Please type [rescript config] again to set/edit"
      echo "your configuration/exclusion files."
      exit
    fi
    clear
    main_menu
    exit
    ;;
  editor)
    _check_help_or_error "${1:-}" "${2:-}"
    select_editor
    exit
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
    _check_help_or_error "${1:-}" "${2:-}"
    clear
    install
    exit
    ;;
  history)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    history-help
    exit
    ;;
  info)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    info-help
    exit
    ;;
  logs)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    logs-help
    exit
    ;;
  mounter)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    mounter-help
    exit
    ;;
  restorer)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    restorer-help
    exit
    ;;
  size)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    size-help
    exit
    ;;
  snaps)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    snaps-help
    exit
    ;;
  umounter)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    umounter-help
    exit
    ;;
  unlocker)
    echo "You have not indicated any repo for [$1]..."
    echo ""
    unlocker-help
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
# Functions                                                      #
# ============================================================== #
source "$config_file"
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

export RESTIC_REPOSITORY="$RESTIC_REPO"
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
export RESTIC_COMPRESSION="${RESTIC_COMPRESSION:-auto}"
SECONDS=0

case "${2:-}" in
  init) restic init ; exit 0 ;;
esac

case "$RESTIC_REPO" in
  sftp*) ping_target=${RESTIC_REPO#sftp*@} ; ping_target=${ping_target%:*} ; ping -c 1 "$ping_target" > /dev/null || true ; ping_code="$?" ;;
  rclone*) ping_target=${RESTIC_REPO#rclone:} ; rclone about "$ping_target" > /dev/null || true ; ping_code="$?" ;;
  /*) dir "$RESTIC_REPO" 2>/dev/null 1>/dev/null || true ; ping_code="$?" ;;
esac

if [[ "$ping_code" -gt "0" ]] ; then
  error_message="Cannot access to: $RESTIC_REPO \nPlease check your connection. If your repository is not \ninitializated run [rescript $repo init]."
  report_errors
  exit "$ping_code"
fi

if [[ -n "${DESTINATION:-}" ]] ; then
  dest=$DESTINATION
else
  dest=$RESTIC_REPO
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


