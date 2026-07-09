#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "06_secondary_commands"

# Test secondary info commands
run_test "Command: env" "$RESCRIPT test env"
run_test "Command: next" "$RESCRIPT test next"

# Test specific backup flags
run_test "Command: backup -C (Check after backup)" "$RESCRIPT test backup -C"
run_test "Command: backup -U (Cleanup after backup)" "$RESCRIPT test backup -U"
run_test "Command: backup -O (Skip Office)" "$RESCRIPT test backup -O"

# Test cleanup explicitly
run_test "Command: cleanup" "$RESCRIPT test cleanup"

# Test specific info flags
run_test "Command: info -H (Filter by Host)" "$RESCRIPT test info -H localhost"

# Test Logging System Flags
# First generate a log file
eval "$RESCRIPT test backup -L > /dev/null 2>&1"
# Get the log file name
LOG_FILE=$(ls -t "$TEST_ENV/.rescript/logs" | head -n 1)

if [[ -n "$LOG_FILE" ]]; then
  run_test "Command: logs -W (View Log)" "$RESCRIPT test logs -W $LOG_FILE"
  run_test "Command: logs -R (Remove Log)" "$RESCRIPT test logs -R $LOG_FILE"
else
  echo -e "[${c_red}FAIL${c_reset}] (Could not generate log file to test -W and -R flags)"
fi

# Test Debug Flag (-D)
run_test "Global Flag: Debug (-D)" "$RESCRIPT test info -D"
