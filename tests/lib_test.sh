#!/bin/bash

# ============================================================== #
# Rescript Universal Test Framework - Core Library               #
# ============================================================== #
# This library provides isolated sandbox creation, auto-cleanup, #
# and standardized UI output for all modular tests.              #
# ============================================================== #

c_green="\033[1;32m"
c_red="\033[1;31m"
c_cyan="\033[1;36m"
c_yellow="\033[0;33m"
c_reset="\033[0m"

# Locate the compiled rescript binary relative to the test_suite folder
# This file is loaded from test_suite/tests/, so we go up two levels.
RESCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/rescript"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"

function setup_sandbox {
  TEST_ENV="/tmp/rescript_test_env_$$"
  
  # Override environment variables for total isolation
  export HOME="$TEST_ENV"
  export SUDO_USER="" 
  export RESTIC_PASSWORD="test"

  REPO_PATH="$TEST_ENV/testrepo"
  SRC_PATH="$TEST_ENV/testrepo_src"
  CONFIG_DIR="$TEST_ENV/.rescript/config"

  if [[ ! -x "$RESCRIPT" ]]; then
    echo -e "${c_red}Error: Compiled rescript binary not found at $RESCRIPT.${c_reset}"
    echo "Please run ./build.sh in the project root first."
    exit 1
  fi

  # Build directory structure
  mkdir -p "$SRC_PATH/docs" "$SRC_PATH/images"
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$TEST_ENV/.rescript/lock"

  # Create dummy files
  echo "hello world" > "$SRC_PATH/docs/test.txt"
  echo "image data" > "$SRC_PATH/images/logo.png"

  # Create mock config file for 'test' repo
  cat << EOF > "$CONFIG_DIR/test.conf"
RESTIC_PASSWORD="test"
RESTIC_REPO="$REPO_PATH"
BACKUP_DIR="$SRC_PATH"
KEEP_LAST="3"
EXCLUDE_FILE="no"
EXCLUDE_CACHE="no"
EOF

  # Initialize repository
  restic -r "$REPO_PATH" init >/dev/null 2>&1
  $RESCRIPT test backup >/dev/null 2>&1
  sleep 1
  echo "updated text" > "$SRC_PATH/docs/test.txt"
  $RESCRIPT test backup >/dev/null 2>&1
}

function cleanup_sandbox {
  if [[ -d "$TEST_ENV" ]]; then
    rm -rf "$TEST_ENV"
  fi
}

function start_test_module {
  local module_name="$1"
  echo "======================================"
  echo -e " ${c_yellow}Module:${c_reset} $module_name"
  echo "======================================"
  setup_sandbox
  cd "$TEST_ENV" || exit 1
  trap cleanup_sandbox EXIT INT TERM
}

function run_test {
  local desc="$1"
  local cmd="$2"
  
  echo -ne " ${c_cyan}Test:${c_reset} $desc "
  
  # Run the command in the isolated env
  eval "$cmd" > "$TEST_ENV/out.log" 2>&1
  local exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo -e "[${c_green}PASS${c_reset}]"
  else
    echo -e "[${c_red}FAIL${c_reset}] (Exit Code: $exit_code)"
    echo -e "${c_yellow}--- Output Log ---${c_reset}"
    cat "$TEST_ENV/out.log"
    echo -e "${c_yellow}------------------${c_reset}"
    # Stop the module execution on failure if desired, or let it continue.
    # For CI, we often want to let it continue to see all errors.
  fi
  return $exit_code
}
