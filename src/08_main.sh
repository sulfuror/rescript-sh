if [[ ! $(command -v restic) ]] ; then
  echo "This script is made to work with [restic]. Please, install"
  echo "[restic] package to proceed. If you have [restic] binary"
  echo "saved in some custom directory, move it to '/usr/bin' or"
  echo "to your PATH so this script can recognize it. If you need"
  echo "to install [restic] and you are using Debian or some Debian"
  echo "based distribution like Ubuntu, you can add the [rescript]"
  echo "PPA with the following commands:"
  echo ""
  echo "  sudo add-apt-repository ppa:sulfuror/restic-tools"
  echo "  sudo apt update"
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
    -Q|--quiet) quiet_flag="true" ; return 0 ;;
    -S|--simulate) simulate_flag="true" ; return 0 ;;
    -T|--timer) time_flag="true" ; return 0 ;;
    *) return 1 ;;
  esac
}

function run_quietly {
  if [[ "$quiet_flag" = "true" ]] ; then
    "$@" > /dev/null
  else
    "$@"
  fi
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
        -c|--cleanup) cleanup_flag="true" ;;

        -h|--help ) backup-help ; exit 0 ;;
        -i|--info) info_flag="true"  ;;
        -S|--skip-office) skip_flag="true" ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly backup
    ;;
  cleanup)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -C|--check) check_flag="true" ;;
        -h|--help ) cleanup-help ; exit 0 ;;
        -i|--info) info_flag="true" ;;
        -n|--next)
          if [[ -z "$CLEAN" ]] ; then
            echo -e "$yellow""You have not indicated any policy for the CLEAN value...""$endcolor"
            echo "The scrip will run check, forget and prune every time it runs"
            echo "unless you change the CLEAN variable at the beginning of this script."
            echo "The number indicated in the CLEAN variable must be in days."
            echo "For more information about the usage check out the following link:"
            echo "https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#usage"
            exit
          else
            cleanup-next
            exit
          fi
          ;;
        --reset)
          if [[ -f "$config_dir/$repo-datefile" ]] ; then
            echo -e "$yellow""Removing datefile for [$repo]:""$endcolor"
            rm -v "${config_dir:?}/$repo-datefile"
            exit 0
          else
            echo -e "$yellow""There is no datefile for [$repo]... nothing to do.""$endcolor"
            exit 0
          fi
          ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly cleanup
    ;;
  diff)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) diff-help ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly differ
    ;;
  env)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) env-help ; exit 0 ;;
        -v) var_flag="$2" ; shift ;;
        --var=*) var_flag="${1#*=}" ;;
        --var) var_flag="$2" ; shift ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    env_conf
    ;;
  -h|--help|help)
    usage
    ;;
  extract)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) extract-help ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly extract
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
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    statinfo
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
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly size
    ;;
  logs)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -c) catlogs="true" ; logfile="$2" ; shift ;;
        --cat=*) catlogs="true" ; logfile="${1#*=}" ;;
        --cat) catlogs="true" ; logfile="$2" ; shift ;;
        -h|--help) logs-help ; exit 0 ;;
        -r) removelogs="true" ; logfile="$2" ; shift ;;
        --remove=*) removelogs="true" ; logfile="${1#*=}" ;;
        --remove) removelogs="true" ; logfile="$2" ; shift ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    logs
    ;;
  mounter|umounter)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) "$cmd-help" ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    "$cmd"
    ;;
  restorer)
    shopt -u nocasematch
    if [[ ! "$1" ]] ; then
      echo "You have not indicated any option..."
      echo ""
      restorer-help
      exit 1
    elif [[ "$1" != -* ]] ; then
      echo "[$1] is not a valid option..."
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
        -p) path_flag="$2" ; shift ;;
        --path=*) path_flag="${1#*=}" ;;
        --path) path_flag="$2" ; shift ;;
        -s) snap_flag="$2" ; shift ;;
        --snapshot=*) snap_flag="${1#*=}" ;;
        --snapshot) snap_flag="$2" ; shift ;;
        -T) tag_flag="$2" ; shift ;;
        --tag=*) tag_flag="${1#*=}" ;;
        --tag) tag_flag="$2" ; shift ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly restorer
    ;;
  search|history)
    shopt -u nocasematch
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) "$cmd-help" ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly "$cmd"
    ;;
  snaps)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) snaps-help ; exit 0 ;;
        --) shift ; rest+=( "$@" ) ; break ;;
        -*) rest+=( "$1" ) ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly snaps
    ;;
  unlocker)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) unlocker-help ; exit 0 ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly unlocker
    ;;
  upgrade)
    while [[ $# -gt 0 ]] ; do
      if _parse_standard_flags "$1" ; then shift ; continue ; fi
      case "$1" in
        -h|--help) upgrade-help ; exit 0 ;;
        *) rest+=( "$1" ) ;;
      esac
      shift
    done
    run_quietly upgrade_repo
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

exit $exit_code
