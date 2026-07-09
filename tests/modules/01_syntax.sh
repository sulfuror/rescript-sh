#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "01_syntax (POSIX & Standards)"

# Test if shellcheck is available
if ! command -v shellcheck &> /dev/null; then
  echo -e " ${c_yellow}Warning: shellcheck is not installed. Skipping syntax test.${c_reset}"
  exit 0
fi

# Run shellcheck on all src modules
run_test "ShellCheck Validation (src/*.sh)" "shellcheck -s bash --severity=error $SRC_DIR/*.sh"
run_test "ShellCheck Validation (rescript root)" "shellcheck -s bash --severity=error $RESCRIPT"
