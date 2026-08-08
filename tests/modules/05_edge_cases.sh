#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "05_edge_cases"

run_test "Command: unlocker (no locks)" "$RESCRIPT test unlocker"

# Force a lock creation using a background process simulation
touch "$TEST_ENV/.rescript/lock/test.lock"
run_test "Command: unlocker (remove lock)" "$RESCRIPT test unlocker"

# Mounter edge cases
run_test "Command: mounter --background" "$RESCRIPT test mounter --background"
sleep 1 # Wait for mount to stabilize
run_test "Command: umounter" "$RESCRIPT test umounter"

# Invalid flags
# This should fail cleanly with bash exit 1, and our run_test expects exit 0.
# So we need to wrap it to expect failure.
echo -ne " ${c_cyan}Test:${c_reset} Error Handling (Invalid Flags) "
eval "$RESCRIPT test backup --fake-flag > $TEST_ENV/out.log 2>&1"
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo -e "[${c_green}PASS${c_reset}] (Successfully rejected invalid flag)"
else
  echo -e "[${c_red}FAIL${c_reset}] (Failed to reject invalid flag)"
  cat "$TEST_ENV/out.log"
fi

# Global Commands Routing Edge Cases (v7.1.0+)
# Commands like config, editor, install, etc. should fail if passed with a repo prefix
echo -ne " ${c_cyan}Test:${c_reset} Global command routing (config with repo) "
eval "$RESCRIPT test config > $TEST_ENV/out_config.log 2>&1"
exit_code=$?
if [ $exit_code -ne 0 ] && grep -q "is a global command" $TEST_ENV/out_config.log; then
  echo -e "[${c_green}PASS${c_reset}] (Successfully rejected global command with repo prefix)"
else
  echo -e "[${c_red}FAIL${c_reset}] (Failed to reject config with repo prefix)"
  cat "$TEST_ENV/out_config.log"
fi

echo -ne " ${c_cyan}Test:${c_reset} Global command routing (editor with repo) "
eval "$RESCRIPT test editor > $TEST_ENV/out_editor.log 2>&1"
exit_code=$?
if [ $exit_code -ne 0 ] && grep -q "is a global command" $TEST_ENV/out_editor.log; then
  echo -e "[${c_green}PASS${c_reset}] (Successfully rejected global command with repo prefix)"
else
  echo -e "[${c_red}FAIL${c_reset}] (Failed to reject editor with repo prefix)"
  cat "$TEST_ENV/out_editor.log"
fi
