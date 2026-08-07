#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "11_exhaustive_options"

# Global Flags Exhaustive Matrix
commands=(
  "status"
  "snaps --latest 1"
  "info"
  "logs"
  "size $SRC_PATH/docs"
)
flags=(
  "-D"
  "-M"
  "-T"
  "-Q"
  "-L"
)

for cmd in "${commands[@]}"; do
  for flag in "${flags[@]}"; do
    run_test "Global Flag $flag on cmd: $cmd" "$RESCRIPT test $cmd $flag"
  done
done
# Note: -E and -W (Email/Webhook) require external network configuration, skipping in unit tests to prevent false negatives.

# Core Commands & Options Tests
run_test "Command: backup (all options)" "$RESCRIPT test backup -C -U -I"
run_test "Command: backup (simulate)" "$RESCRIPT test backup --simulate"
run_test "Command: cleanup (simulate)" "$RESCRIPT test cleanup --simulate"
run_test "Command: status (full)" "$RESCRIPT test status --full"
run_test "Command: snaps (latest 1)" "$RESCRIPT test snaps --latest 1"
run_test "Command: snaps (group-by)" "$RESCRIPT test snaps --group-by host"
run_test "Command: history" "$RESCRIPT test history $SRC_PATH/docs/test.txt"
run_test "Command: search" "$RESCRIPT test search test.txt"
run_test "Command: size" "$RESCRIPT test size $SRC_PATH/docs"
run_test "Command: info" "$RESCRIPT test info"
run_test "Command: diff" "$RESCRIPT test diff"
run_test "Command: logs" "$RESCRIPT test logs"
run_test "Command: extract" "$RESCRIPT test extract $SRC_PATH/docs/test.txt"
run_test "Command: restorer" "$RESCRIPT test restorer -P $SRC_PATH"
