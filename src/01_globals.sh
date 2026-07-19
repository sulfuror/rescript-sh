#!/usr/bin/env bash
# ============================================================== #
set -euo pipefail
# Initialize internal variables to prevent unbound variable errors
context_flag=""
rescript_lock_created=""
var_flag=""
log_flag=""
time_flag=""
simulate_flag=""
debug_flag=""
skip_flag=""
prev_cmd=""
host_flag=""
error_message=""
ping_code=""
rest_cmd=""
cmd=""
exit_code=""
latest_cmd=""
context_printed=""
version="6.1"
function hide_cursor {
  tput civis 2> /dev/null || true
}

function show_cursor {
  tput cnorm 2> /dev/null || true
}

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

Configuration commands:
  config                Rescript configuration.
  editor                Change default text editor used by rescript.
  help                  Display rescript usage.
  install               Install rescript.
  update                Check/install new rescript version.
  version               Display rescript version.
  
Commands:
  automatic             Run backup and cleanup policies sequentially.
  backup                Take a snapshot.
  cleanup               Apply retention policies and prune.
  diff                  Compare two snapshots.
  env                   Display values in your configurations.
  extract               Extract a specific file or directory.
  history               Show version history of a given file.
  info                  Display stats for latest and all snapshots.
  init                  Initialize a new restic repository.
  logs                  List, view or remove your log files.
  mounter               Mount a restic repo.
  next                  Display next scheduled automatic cleanup time.
  restorer              Restore a restic snapshot.
  search                Find a file or directory across snapshots.
  size                  Calculate recursive size of a given path.
  snaps                 List snapshots in your repository (compact mode).
  status                Print a dashboard with the status of your repositories.
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
ui_line_eq="======================"
ui_line_dash="----------------------"

repo="${1:-}"

# Rescript directories and files
rescript_dir="$HOME/.rescript"
config_dir="$rescript_dir/config"
lock_dir="$rescript_dir/lock"
logs_dir="$rescript_dir/logs"
tmplog=$(mktemp)
excludes="$config_dir/${1:-}-exclusions"
lock="$lock_dir/$repo.lock"
config_global="$config_dir/global.conf"
config_repo="$config_dir/$repo.conf"
unix_name=$(uname -s)

if [[ -d "/tmp" ]] ; then
  tmp_dir="/tmp"
else
  tmp_dir="$TMPDIR"
fi

shopt -s nocasematch

#Handle interrupt
