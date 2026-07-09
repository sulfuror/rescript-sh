if [[ ! $(command -v restic) ]] ; then
  echo "This script is made to work with [restic]. Please, install"
  echo "[restic] package to proceed. If you have [restic] binary"
  echo "saved in some custom directory, move it to '/usr/bin' or"
  echo "to your PATH so this script can recognize it. You can usually"
  echo "install it via your system's package manager, for example:"
  echo ""
  echo "  sudo apt install restic"
  echo ""
  echo "You can also download the standalone binary in the [restic]"
  echo "release page: https://github.com/restic/restic/releases"
  exit
fi
if [[ ! "$2" || "$2" == -* ]] ; then
  cmd="automatic"
  shift 1
else
  cmd="$2"
  shift 2
fi


function _parse_standard_flags {
  case "$1" in
    -D|--debug) debug_flag="true" ; return 0 ;;
    -E|--email) int="false" ; CONFIRMATION_EMAIL="y" ; return 0 ;;
    -L|--log) log_flag="true" ; return 0 ;;
    -M|--metadata) context_flag="true" ; return 0 ;;
    -Q|--quiet) quiet_flag="true" ; return 0 ;;
    -S|--simulate) simulate_flag="true" ; return 0 ;;
    -T|--timer) time_flag="true" ; return 0 ;;
    *) return 1 ;;
  esac
}

function parse_generic_args {
  local help_func="$1"
  shift
  while [[ $# -gt 0 ]] ; do
    if _parse_standard_flags "$1" ; then shift ; continue ; fi
    case "$1" in
      -h|--help) "$help_func" ; exit 0 ;;
      --) shift ; rest+=( "$@" ) ; break ;;
      -*) rest+=( "$1" ) ;;
      *) rest+=( "$1" ) ;;
    esac
    shift
  done
}

function run_quietly {
  if [[ "$quiet_flag" = "true" ]] ; then
    "$@" > /dev/null
  else
    "$@"
  fi
}

function execute_with_metrics {
  logger
  time_start
  "$@"
  time_end
}

check_flag="false"
cleanup_flag="false"
debug_flag="false"
info_flag="false"
log_flag="false"
metadata_flag="false"
skip_flag="false"
time_flag="false"
catlogs="false"
removelogs="false"
quiet_flag="false"
simulate_flag="false"
rest=()

case "$cmd" in
  automatic)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help|help) usage ; exit 0 ;;
        *) echo "Invalid option [$1]..." ; echo "" ; exit 1 ;;
      esac
      shift
    done
    run_quietly automatic
    ;;
  backup)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -U|--cleanup) cleanup_flag="true" ;;

        -h|--help ) backup-help ; exit 0 ;;
        -I|--info) info_flag="true"  ;;
        -O|--skip-office) skip_flag="true" ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    logger
    time_start
    if [[ "$cleanup_flag" = "true" || "$check_flag" = "true" || "$info_flag" = "true" ]] ; then
      echo -e "${c_cyan}Taking a Snapshot...${c_reset}"
    fi
    run_quietly backup
    if [[ "$cleanup_flag" = "true" ]] ; then
      print_line
      echo -e "${c_cyan}Starting cleanup...${c_reset}"
      run_quietly cleanup
    fi
    if [[ "$check_flag" = "true" ]] ; then
      print_line
      echo -e "${c_cyan}Starting check...${c_reset}"
      run_quietly restic check --cleanup-cache
    fi
    if [[ "$info_flag" = "true" ]] ; then
      print_line
      run_quietly statinfo
    fi
    time_end
    ;;
  cleanup)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -h|--help ) cleanup-help ; exit 0 ;;
        -I|--info) info_flag="true" ;;

        --reset)
          if [[ -f "$config_dir/$repo-datefile" ]] ; then
            echo "Removing datefile for [$repo]:"
            rm -v "${config_dir:?}/$repo-datefile"
            exit 0
          else
            echo "There is no datefile for [$repo]... nothing to do."
            exit 0
          fi
          ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    logger
    time_start
    if [[ "$check_flag" = "true" || "$info_flag" = "true" ]] ; then
      echo -e "${c_cyan}Starting cleanup...${c_reset}"
    fi
    run_quietly cleanup
    if [[ "$check_flag" = "true" ]] ; then
      print_line
      echo -e "${c_cyan}Starting check...${c_reset}"
      run_quietly restic check --cleanup-cache
    fi
    if [[ "$info_flag" = "true" ]] ; then
      print_line
      run_quietly statinfo
    fi
    time_end
    ;;
  diff)
    shopt -u nocasematch
    parse_generic_args "diff-help" "$@"
    execute_with_metrics run_quietly differ
    ;;
  env)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) env-help ; exit 0 ;;
        -V) var_flag="$2" ; shift ;;
        --var=*) var_flag="${1#*=}" ;;
        --var) var_flag="$2" ; shift ;;
        -*) rest+=( "$1" ) ;;
      esac
      shift
    done
    execute_with_metrics env_conf
    ;;
  -h|--help|help)
    usage
    ;;
  next)
    shopt -u nocasematch
    parse_generic_args "next-help" "$@"
    if [[ -z "$CLEAN" ]] ; then
      echo "You have not indicated any policy for the CLEAN value..."
      echo "The script will run check, forget and prune every time it runs"
      echo "unless you change the CLEAN variable at the beginning of this script."
      echo "The number indicated in the CLEAN variable must be in days."
      echo "For more information about the usage check out the following link:"
      echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
    else
      cleanup-next
    fi
    ;;
  extract)
    shopt -u nocasematch
    parse_generic_args "extract-help" "$@"
    execute_with_metrics run_quietly extract
    ;;
  info)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) info-help ; exit 0 ;;
        -H) host_flag="$2" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="$2" ; shift ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    execute_with_metrics statinfo
    ;;
  size)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) size-help ; exit 0 ;;
        -H) host_flag="$2" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="$2" ; shift ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    execute_with_metrics run_quietly size
    ;;
  logs)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -W) catlogs="true" ; logfile="$2" ; shift ;;
        --view=*) catlogs="true" ; logfile="${1#*=}" ;;
        --view) catlogs="true" ; logfile="$2" ; shift ;;
        -h|--help) logs-help ; exit 0 ;;
        -R) removelogs="true" ; logfile="$2" ; shift ;;
        --remove=*) removelogs="true" ; logfile="${1#*=}" ;;
        --remove) removelogs="true" ; logfile="$2" ; shift ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    execute_with_metrics logs
    ;;
  mounter|umounter)
    parse_generic_args "$cmd-help" "$@"
    execute_with_metrics "$cmd"
    ;;
  restorer)
    shopt -u nocasematch
    if [[ ! "$1" ]] ; then
      echo "You have not indicated any option..."
      echo ""
      restorer-help
      exit 1
    fi
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) restorer-help ; exit 0 ;;
        -H) host_flag="$2" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="$2" ; shift ;;
        -P) path_flag="$2" ; shift ;;
        --path=*) path_flag="${1#*=}" ;;
        --path) path_flag="$2" ; shift ;;
        -Z) snap_flag="$2" ; shift ;;
        --snapshot=*) snap_flag="${1#*=}" ;;
        --snapshot) snap_flag="$2" ; shift ;;
        -T) tag_flag="$2" ; shift ;;
        --tag=*) tag_flag="${1#*=}" ;;
        --tag) tag_flag="$2" ; shift ;;
        -*) 
          echo "[$1] is not a valid option..."
          echo ""
          restorer-help
          exit 1 
          ;;
        *) 
          if [[ -z "$snap_flag" ]] ; then
            snap_flag="$1"
          else
            echo "[$1] is not a valid option..."
            echo ""
            restorer-help
            exit 1
          fi
          ;;
      esac
      shift
    done
    execute_with_metrics run_quietly restorer
    ;;
  search|history)
    shopt -u nocasematch
    parse_generic_args "$cmd-help" "$@"
    execute_with_metrics run_quietly "$cmd"
    ;;
  snaps)
    parse_generic_args "snaps-help" "$@"
    execute_with_metrics run_quietly snaps
    ;;
  unlocker)
    parse_generic_args "unlocker-help" "$@"
    execute_with_metrics run_quietly unlocker
    ;;
  upgrade)
    parse_generic_args "upgrade-help" "$@"
    execute_with_metrics run_quietly upgrade_repo
    ;;
  *)
    rest=("$cmd")
    for arg in "$@"; do
      if _parse_standard_flags "$arg" ; then continue ; fi
      rest+=("$arg")
    done
    cmd="${rest[0]}"
    case "$cmd" in
      --repo=*) cmd="${cmd#--repo=}" ;;
      -r|--repo) cmd="${rest[1]}" ;;
    esac
    run_quietly restic_alone
    ;;
esac

job_done

shopt -u nocasematch

# Allow async logging processes (like tee) to finish flushing before returning to shell
sleep 0.1

exit "${exit_code:-$?}"
