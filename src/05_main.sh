# ============================================================== #
#                             MAIN                               #
# ============================================================== #

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

if [[ ! "${2:-}" || "${2:-}" == -* ]] ; then
  cmd="automatic"
  shift 1
else
  cmd="${2:-}"
  shift 2
fi



case "$cmd" in
  automatic)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -S|--simulate) simulate_flag="true" ;;
        -h|--help|help) usage ; exit 0 ;;
        *) echo "Invalid option [$1]..." ; echo "" ; exit 1 ;;
      esac
      shift
    done
    run_quietly automatic
    ;;
  status)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -F|--full|--stats) rest+=( "$1" ) ;;
        -X|--ignore-repo)
          if [[ -n "${2:-}" ]]; then
            rest+=( "$1" "$2" )
            shift
          else
            echo "Error: -X/--ignore-repo requires a repository name."
            exit 1
          fi
          ;;
        -h|--help) status-help ; exit 0 ;;
        -*) echo "Invalid option [$1]..." ; echo "" ; status-help ; exit 1 ;;
        *) echo "Invalid option [$1]..." ; echo "" ; status-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly global_status "${rest[@]}"
    ;;
  backup)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -U|--cleanup) cleanup_flag="true" ;;
        -S|--simulate) simulate_flag="true" ;;

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
    _run_post_actions
    time_end
    ;;
  cleanup)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -S|--simulate) simulate_flag="true" ;;
        -h|--help ) cleanup-help ; exit 0 ;;
        -I|--info) info_flag="true" ;;

        --reset)
          if [[ -f "$config_dir/$repo.state" ]] ; then
            echo "Removing state file for [$repo]:"
            rm -v "${config_dir:?}/$repo.state"
            exit 0
          elif [[ -f "$config_dir/$repo-datefile" ]] ; then
            echo "Removing datefile for [$repo]:"
            rm -v "${config_dir:?}/$repo-datefile"
            exit 0
          else
            echo "There is no state file for [$repo]... nothing to do."
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
    _run_post_actions
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
        -S|--simulate) echo "[$1] is not a valid option..." ; echo "" ; env-help ; exit 1 ;;
        -h|--help) env-help ; exit 0 ;;
        -V) var_flag="${2:-}" ; shift ;;
        --var=*) var_flag="${1#*=}" ;;
        --var) var_flag="${2:-}" ; shift ;;
        -*) echo "Invalid option [$1]..." ; echo "" ; env-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly env_conf
    ;;
  -h|--help|help)
    usage
    ;;
  next)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      case "$1" in
        -h|--help) next-help ; exit 0 ;;
        *) echo "Invalid option [$1]..." ; echo "" ; next-help ; exit 1 ;;
      esac
      shift
    done
    if [[ -z "${CLEAN:-}" ]] ; then
      echo "You have not configured a policy for the CLEAN variable..."
      echo "For more information, please visit:"
      echo "https://github.com/sulfuror/rescript-sh/wiki/Configuration-Files#optional-variables"
    else
      cleanup_next
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
        -H) host_flag="${2:-}" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="${2:-}" ; shift ;;
        *) 
          echo "[$1] is not a valid option..."
          echo ""
          info-help
          exit 1 
          ;;
      esac
      shift
    done
    execute_with_metrics run_quietly statinfo
    ;;
  size)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -S|--simulate) echo "[$1] is not a valid option..." ; echo "" ; size-help ; exit 1 ;;
        -h|--help) size-help ; exit 0 ;;
        -H) host_flag="${2:-}" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="${2:-}" ; shift ;;
        -*) echo "Invalid option [$1]..." ; echo "" ; size-help ; exit 1 ;;
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
        -V) catlogs="true" ; logfile="${2:-}" ; shift ;;
        --view=*) catlogs="true" ; logfile="${1#*=}" ;;
        --view) catlogs="true" ; logfile="${2:-}" ; shift ;;
        -S|--simulate) echo "[$1] is not a valid option..." ; echo "" ; logs-help ; exit 1 ;;
        -h|--help) logs-help ; exit 0 ;;
        -R) removelogs="true" ; logfile="${2:-}" ; shift ;;
        --remove=*) removelogs="true" ; logfile="${1#*=}" ;;
        --remove) removelogs="true" ; logfile="${2:-}" ; shift ;;
        -*) echo "Invalid option [$1]..." ; echo "" ; logs-help ; exit 1 ;;
        *) echo "Invalid argument [$1]..." ; echo "" ; logs-help ; exit 1 ;;
      esac
      shift
    done
    run_quietly logs
    ;;
  mounter)
    parse_generic_args "mounter-help" "$@"
    execute_with_metrics run_quietly mounter
    ;;
  umounter)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      case "$1" in
        -h|--help) umounter-help ; exit 0 ;;
        *) echo "Invalid option [$1]..." ; echo "" ; umounter-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly umounter
    ;;
  restorer)
    shopt -u nocasematch
    snap_flag=""
    host_flag=""
    path_flag=""
    tag_flag=""
    interactive_flag=""
    if [[ ! "${1:-}" ]] ; then
      echo "You have not indicated any option..."
      echo ""
      restorer-help
      exit 1
    fi
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) restorer-help ; exit 0 ;;
        -H) host_flag="${2:-}" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="${2:-}" ; shift ;;
        -P) path_flag="${2:-}" ; shift ;;
        --path=*) path_flag="${1#*=}" ;;
        --path) path_flag="${2:-}" ; shift ;;
        -Z) snap_flag="${2:-}" ; shift ;;
        --snapshot=*) snap_flag="${1#*=}" ;;
        --snapshot) snap_flag="${2:-}" ; shift ;;
        --tag=*) tag_flag="${1#*=}" ;;
        --tag) tag_flag="${2:-}" ; shift ;;
        -i|--interactive) interactive_flag="true" ;;
        -S|--simulate) simulate_flag="true" ;;
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
  init)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help ) init-help ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly init
    ;;
  config|editor|install|uninstall|update|version)
    echo "[$cmd] is a global command..."
    echo ""
    "$cmd-help"
    exit 1
    ;;
  *)
    shopt -u nocasematch
    rest=("$cmd")
    for arg in "$@"; do
      if _parse_standard_flags "$arg" ; then continue ; fi
      case "$arg" in
        -S|--simulate) echo "[$arg] is not a valid option..." ; echo "" ; exit 1 ;;
      esac
      rest+=("$arg")
    done
    cmd="${rest[0]}"
    case "$cmd" in
      --repo=*) cmd="${cmd#--repo=}" ;;
      -r|--repo) cmd="${rest[1]}" ;;
    esac
    execute_with_metrics run_quietly restic_alone
    ;;
esac

job_done

if [[ "$simulate_flag" == "true" ]]; then
  echo -e "${c_yellow}SIMULATE: End of simulation.${c_reset}"
fi

shopt -u nocasematch

# Allow async logging processes (like tee) to finish flushing before returning to shell
sleep 0.1

exit "${exit_code:-$?}"
