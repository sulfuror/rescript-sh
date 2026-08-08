#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "03_orchestrator"

# Create a second dummy repo configuration to test exclusions
cat << EOF > "$CONFIG_DIR/dummy.conf"
RESTIC_PASSWORD="test"
RESTIC_REPO="$TEST_ENV/dummyrepo"
BACKUP_DIR="$SRC_PATH"
KEEP_LAST="3"
EOF

restic -r "$TEST_ENV/dummyrepo" init >/dev/null 2>&1

run_test "Orchestrator: all info" "$RESCRIPT all info"
run_test "Orchestrator: all help (-h)" "$RESCRIPT all -h"
run_test "Orchestrator: all exclusion (-X)" "$RESCRIPT all info -X test"
run_test "Orchestrator: all exclusion (--ignore-repo)" "$RESCRIPT all info --ignore-repo dummy"

# Test Orchestrator executing raw commands
run_test "Orchestrator: all raw command (check)" "$RESCRIPT all check"

# Orchestrator validation for global commands (v7.1.0+)
echo -ne " ${c_cyan}Test:${c_reset} Orchestrator rejection of global command (status) "
eval "$RESCRIPT all status > $TEST_ENV/out_all_status.log 2>&1"
exit_code=$?
if [ $exit_code -ne 0 ] && grep -q "Invalid option for \[all\]" $TEST_ENV/out_all_status.log; then
  echo -e "[${c_green}PASS${c_reset}] (Successfully rejected all status)"
else
  echo -e "[${c_red}FAIL${c_reset}] (Failed to reject all status)"
  cat "$TEST_ENV/out_all_status.log"
fi

echo -ne " ${c_cyan}Test:${c_reset} Orchestrator rejection of global command (editor) "
eval "$RESCRIPT all editor > $TEST_ENV/out_all_editor.log 2>&1"
exit_code=$?
if [ $exit_code -ne 0 ] && grep -q "is a global command" $TEST_ENV/out_all_editor.log; then
  echo -e "[${c_green}PASS${c_reset}] (Successfully rejected all editor)"
else
  echo -e "[${c_red}FAIL${c_reset}] (Failed to reject all editor)"
  cat "$TEST_ENV/out_all_editor.log"
fi
