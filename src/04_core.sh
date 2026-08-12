# ============================================================== #
#                              CORE                              #
# ============================================================== #

restic_alone() {
  rescript_lock
  debug_start
  print_context
  run_restic_with_retry ${rest[@]:+"${rest[@]}"}
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

if [[ -f "$config_global" ]]; then
  source_config "$config_global"
fi

# -------------------------------------------------------------- #
#        EDITOR MIGRATION AND JUST-IN-TIME INITIALIZATION        #
# -------------------------------------------------------------- #

if [[ -n "${RESCRIPT_EDITOR:-}" ]]; then
  rescript_editor="$RESCRIPT_EDITOR"
  rm -f "$config_dir/.editor" 2>/dev/null || true
elif [[ -s "$config_dir/.editor" ]]; then
  rescript_editor=$(<"$config_dir/.editor")
  if [[ -f "$config_global" ]]; then
    grep -v "^RESCRIPT_EDITOR=" "$config_global" > "${config_global}.tmp" 2>/dev/null || true
    printf "%s\n" "RESCRIPT_EDITOR=\"$rescript_editor\"" >> "${config_global}.tmp"
    mv "${config_global}.tmp" "$config_global"
  fi
  rm -f "$config_dir/.editor"
else
  rm -f "$config_dir/.editor" 2>/dev/null || true
  rescript_editor=""
fi

if [[ ! "${1:-}"  ]] ; then
  usage
  exit 1
fi
_check_help_or_error() {
  local cmd="${1:-}"
  local arg="${2:-}"
  if [[ "$arg" ]] ; then
    case "$arg" in
      -h|--help|help)
        if type "$cmd-help" &>/dev/null; then
          "$cmd-help"
        else
          usage
        fi
        exit 0
        ;;
      *)
        printf "%s\n" "Invalid option [$arg]..."
        printf "\n"
        if type "$cmd-help" &>/dev/null; then
          "$cmd-help"
        else
          usage | sed -ne '/Usage/,/EOF/p'
        fi
        exit 1
        ;;
    esac
  fi
}

case "${1:-}" in
  automatic|backup|cleanup|diff|env|extract|history|info|init|logs|mounter|next|restorer|search|size|snaps|umounter|unlocker|upgrade)
    _check_help_or_error "${1:-}" "${2:-}"
    printf "%s\n" "You have not indicated any repo for [$1]..."
    printf "\n"
    if type "${1:-}-help" &>/dev/null; then
      "${1:-}-help"
    else
      usage | sed -ne '/Usage/,/EOF/p'
    fi
    exit 1
    ;;
  status)
    parse_generic_args status-help "${@:2}"
    execute_with_metrics run_quietly global_status ${rest[@]:+"${rest[@]}"}
    exit 0
    ;;
  config)
    parse_generic_args config-help "${@:2}"
    rescript_config ${rest[@]:+"${rest[@]}"}
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
        printf "%s\n" "You have not indicated a valid option..."
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
    printf "\n"
    printf "%b\n" 'Redistribution and use in source and binary forms, with or without \nmodification, are permitted provided that the BSD 2-Clause License \nconditions are met.'
    exit
    ;;
  *)
    if [[ ! -e "$config_dir/$1.conf" && ! -e "$config_dir/$1.conf.gpg" ]] ; then
      printf "%s\n" "There is no repo or command for [$1]. Indicate a valid"
      printf "%s\n" "repo name or command to proceed. Use [rescript help] for usage."
      exit
    fi
    ;;
esac

# -------------------------------------------------------------- #
#                   CONFIGURATION & VARIABLES                    #
# -------------------------------------------------------------- #

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
elif [[ -n "${RESTIC_PASSWORD:-}" ]]; then
  export RESTIC_PASSWORD
fi

if [[ -n "${RESTIC_PASSWORD_COMMAND:-}" ]]; then
  export RESTIC_PASSWORD_COMMAND
fi
export RESTIC_COMPRESSION="${RESTIC_COMPRESSION:-auto}"
SECONDS=0

case "${RESTIC_REPO:-}" in
  sftp*) ping_target=${RESTIC_REPO#sftp*@} ; ping_target=${ping_target%:*} ; ping_code=0; ping -c 1 "$ping_target" > /dev/null 2>&1 || ping_code=$? ;;
  rclone*) ping_target=${RESTIC_REPO#rclone:} ; ping_code=0; rclone about "$ping_target" > /dev/null 2>&1 || ping_code=$? ;;
  /*) ping_code=0; [[ -d "$RESTIC_REPO" ]] || ping_code=1 ;;
esac

if [[ "$ping_code" -gt "0" && "${2:-}" != "init" ]] ; then
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
