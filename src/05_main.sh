# ============================================================== #
#                              MAIN                              #
# ============================================================== #

main() {
if ! command -v restic >/dev/null 2>&1 ; then
  printf "%s\n" "This script is made to work with [restic]. Please, install"
  printf "%s\n" "[restic] package to proceed. If you have [restic] binary"
  printf "%s\n" "saved in some custom directory, move it to '/usr/bin' or"
  printf "%s\n" "to your PATH so this script can recognize it. You can usually"
  printf "%s\n" "install it via your system's package manager, for example:"
  printf "\n"
  printf "%s\n" "  sudo apt install restic"
  printf "\n"
  printf "%s\n" "You can also download the standalone binary in the [restic]"
  printf "%s\n" "release page: https://github.com/restic/restic/releases"
  exit
fi

if [[ -z "${2:-}" || "${2:-}" == -* ]] ; then
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
        *) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; exit 1 ;;
      esac
      shift
    done
    run_quietly automatic
    ;;
  status)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -F|--full|--stats) rest+=( "$1" ) ;;
        -X|--ignore-repo)
          if [[ -n "${2:-}" ]]; then
            rest+=( "$1" "$2" )
            shift
          else
            printf "%s\n" "Error: -X/--ignore-repo requires a repository name."
            exit 1
          fi
          ;;
        -h|--help) status-help ; exit 0 ;;
        -*) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; status-help ; exit 1 ;;
        *) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; status-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly global_status "${rest[@]}"
    ;;
  backup)
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
      printf "%b\n" "${c_cyan}Taking a Snapshot...${c_reset}"
    fi
    run_quietly backup
    if [[ "$cleanup_flag" = "true" ]] ; then
      print_line
      printf "%b\n" "${c_cyan}Starting cleanup...${c_reset}"
      run_quietly cleanup
    fi
    _run_post_actions
    time_end
    ;;
  cleanup)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -S|--simulate) simulate_flag="true" ;;
        -h|--help ) cleanup-help ; exit 0 ;;
        -I|--info) info_flag="true" ;;

        --reset)
          if [[ -f "$config_dir/$repo.state" ]] ; then
            printf "%s\n" "Removing state file for [$repo]:"
            rm -v "${config_dir:?}/$repo.state"
            exit 0
          elif [[ -f "$config_dir/$repo-datefile" ]] ; then
            printf "%s\n" "Removing datefile for [$repo]:"
            rm -v "${config_dir:?}/$repo-datefile"
            exit 0
          else
            printf "%s\n" "There is no state file for [$repo]... nothing to do."
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
      printf "%b\n" "${c_cyan}Starting cleanup...${c_reset}"
    fi
    run_quietly cleanup
    _run_post_actions
    time_end
    ;;
  diff)
    parse_generic_args "diff-help" "$@"
    execute_with_metrics run_quietly differ
    ;;
  env)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -S|--simulate) printf "%s\n" "[$1] is not a valid option..." ; printf "\n" ; env-help ; exit 1 ;;
        -h|--help) env-help ; exit 0 ;;
        -V) var_flag="${2:-}" ; shift ;;
        --var=*) var_flag="${1#*=}" ;;
        --var) var_flag="${2:-}" ; shift ;;
        -*) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; env-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly env_conf
    ;;
  -h|--help|help)
    usage
    ;;
  next)
    while [[ $# -gt 0 ]] ; do
      case "$1" in
        -h|--help) next-help ; exit 0 ;;
        *) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; next-help ; exit 1 ;;
      esac
      shift
    done
    if [[ -z "${CLEAN:-}" ]] ; then
      printf "%s\n" "You have not configured a policy for the CLEAN variable..."
      printf "%s\n" "For more information, please visit:"
      printf "%s\n" "https://github.com/sulfuror/rescript-sh/wiki/Configuration-Files#optional-variables"
    else
      cleanup_next
    fi
    ;;
  extract)
    parse_generic_args "extract-help" "$@"
    execute_with_metrics run_quietly extract
    ;;
  info)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) info-help ; exit 0 ;;
        -H) host_flag="${2:-}" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="${2:-}" ; shift ;;
        *) 
          printf "%s\n" "[$1] is not a valid option..."
          printf "\n"
          info-help
          exit 1 
          ;;
      esac
      shift
    done
    execute_with_metrics run_quietly statinfo
    ;;
  size)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -S|--simulate) printf "%s\n" "[$1] is not a valid option..." ; printf "\n" ; size-help ; exit 1 ;;
        -h|--help) size-help ; exit 0 ;;
        -H) host_flag="${2:-}" ; shift ;;
        --host=*) host_flag="${1#*=}" ;;
        --host) host_flag="${2:-}" ; shift ;;
        -*) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; size-help ; exit 1 ;;
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
        -S|--simulate) printf "%s\n" "[$1] is not a valid option..." ; printf "\n" ; logs-help ; exit 1 ;;
        -h|--help) logs-help ; exit 0 ;;
        -R) removelogs="true" ; logfile="${2:-}" ; shift ;;
        --remove=*) removelogs="true" ; logfile="${1#*=}" ;;
        --remove) removelogs="true" ; logfile="${2:-}" ; shift ;;
        -*) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; logs-help ; exit 1 ;;
        *) printf "%s\n" "Invalid argument [$1]..." ; printf "\n" ; logs-help ; exit 1 ;;
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
    while [[ $# -gt 0 ]] ; do
      case "$1" in
        -h|--help) umounter-help ; exit 0 ;;
        *) printf "%s\n" "Invalid option [$1]..." ; printf "\n" ; umounter-help ; exit 1 ;;
      esac
      shift
    done
    execute_with_metrics run_quietly umounter
    ;;
  restorer)
    snap_flag=""
    host_flag=""
    path_flag=""
    tag_flag=""
    interactive_flag=""
    if [[ -z "${1:-}" ]] ; then
      printf "%s\n" "You have not indicated any option..."
      printf "\n"
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
          printf "%s\n" "[$1] is not a valid option..."
          printf "\n"
          restorer-help
          exit 1 
          ;;
        *) 
          if [[ -z "$snap_flag" ]] ; then
            snap_flag="$1"
          else
            printf "%s\n" "[$1] is not a valid option..."
            printf "\n"
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
    printf "%s\n" "[$cmd] is a global command..."
    printf "\n"
    "$cmd-help"
    exit 1
    ;;
  *)
    rest=("$cmd")
    for arg in "$@"; do
      if _parse_standard_flags "$arg" ; then continue ; fi
      case "$arg" in
        -S|--simulate) printf "%s\n" "[$arg] is not a valid option..." ; printf "\n" ; exit 1 ;;
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
  printf "%b\n" "${c_yellow}SIMULATE: End of simulation.${c_reset}"
fi

# Allow async logging processes (like tee) to finish flushing before returning to shell
sleep 0.1

exit "${exit_code:-$?}"
}

main "$@"
