#!/usr/bin/env bash
set -euo pipefail
# ============================================================== #
#                            GLOBALS                             #
# ============================================================== #
# Initialize internal variables to prevent unbound variable errors
version="7.1.0"
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
log=""
repo="${1:-}"

# Variables for text colors and UI lines
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
