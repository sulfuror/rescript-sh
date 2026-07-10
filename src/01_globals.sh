#!/usr/bin/env bash
# ============================================================== #
version="5.2"
function usage {
cat <<EOF
Name        : rescript
Author      : Sulfuror, Copyright (c) 2018 <sulfuror@gmail.com>
URL         : https://gitlab.com/sulfuror/rescript.sh
License     : BSD 2-Clause License
Version     : $version
Description : rescript is a bash shell wrapper for restic

Information about restic: https://restic.net

This script will run backup, snapshots, forget, prune, check and
stats commands automatically by just indicating the name given
to your configuration file (repo_name). e.g.:

  rescript [repo_name]

Usage:
  rescript [config_command]
  rescript [repo_name] [command] [flags] ...
  rescript [repo_name] [restic_command] [flags] ...

To execute a command across ALL configured repositories sequentially,
use the 'all' keyword instead of a specific repo name. You can use
--ignore-repo to ignore specific repositories. e.g.:

  rescript all [command] --ignore-repo [repo_name]

Commands that run automatically with rescript [repo_name]:

Configuration commands:
  config                Rescript configuration.
  editor                Change default text editor used by rescript.
  help                  Display rescript usage.
  install               Install rescript.
  update                Check/install new rescript version.
  version               Display rescript version.
  
Commands:
  backup                Take a snapshot.
  cleanup               Apply retention policies and prune.
  diff                  Compare two snapshots.
  env                   Display values in your configurations.
  extract               Extract a specific file or directory.
  history               Show version history of a given file.
  info                  Display stats for latest and all snapshots.
  logs                  List, view or remove your log files.
  mounter               Mount a restic repo.
  next                  Display next scheduled automatic cleanup time.
  restorer              Restore a restic snapshot.
  search                Find a file or directory across snapshots.
  size                  Calculate recursive size of a given path.
  snaps                 List snapshots in your repository (compact mode).
  umounter              Unmount a previously mounted restic repository.
  unlocker              Remove lock created by rescript.
  upgrade               Upgrade restic repository to the latest format.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -M, --metadata        Display execution context metadata.
  -Q, --quiet           Silence output.
  -S, --simulate        Run destructive operations in dry-run mode.
  -T, --timer           Display output with date, time and duration.

Commands usage:
  rescript help [command]

EOF
}
# ============================================================== #
c_blue="\033[1;34m"
c_cyan="\033[1;36m"
c_green="\033[1;32m"
c_yellow="\033[0;33m"
c_gray="\033[1;30m"
c_white="\033[1;37m"
c_red="\033[0;31m"
c_reset="\033[0m"
if [[ "$1" == "all" ]]; then
  shift 1
  excluded_repos=()
  forward_args=()
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ignore-repo|-X)
        if [[ -n "$2" && "$2" != -* ]]; then
          excluded_repos+=("$2")
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
        forward_args+=("$1")
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
      echo "repositories sequentially."
      echo ""
      echo "Flags specific to 'all':"
      echo "  -X, --ignore-repo <repo>    Exclude a repository. Can be used multiple times."
      echo ""
      echo "Examples:"
      echo "  rescript all backup -q"
      echo "  rescript all cleanup --simulate --ignore-repo [repo_name]"
      exit 0
    fi
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

  cols=$(tput cols 2>/dev/null || echo 80)
  for r_name in "${repos[@]}"; do
    if [[ "$has_metadata" == "false" && "$is_automatic" == "false" ]]; then
      if [[ "$has_help" == "false" ]]; then
        printf "%b" "${c_gray}"
        for ((i=0; i<cols; i++)); do printf "="; done; echo -e "${c_reset}"
        printf "${c_white}Running on repository:${c_reset} ${c_cyan}%s${c_reset}\n" "$r_name"
        printf "%b" "${c_gray}"
        for ((i=0; i<cols; i++)); do printf "="; done; echo -e "${c_reset}"
      fi
    fi
    "$0" "$r_name" "${forward_args[@]}" || true
    if [[ "$has_help" == "true" ]]; then
      exit 0
    fi
    echo ""
  done
  
  exit 0
fi

repo="$1"

# Rescript directories and files
rescript_dir="$HOME/.rescript"
config_dir="$rescript_dir/config"
lock_dir="$rescript_dir/lock"
logs_dir="$rescript_dir/logs"
tmplog=$(mktemp)
excludes="$config_dir/$1-exclusions"
lock="$lock_dir/$repo.lock"
config_file="$config_dir/$repo.conf"
unix_name=$(uname -s)

if [[ -d "/tmp" ]] ; then
  tmp_dir="/tmp"
else
  tmp_dir="$TMPDIR"
fi

shopt -s nocasematch

#Handle interrupt
