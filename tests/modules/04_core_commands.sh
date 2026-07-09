#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "04_core_commands"

run_test "Command: history" "$RESCRIPT test history test.txt"
run_test "Command: search" "$RESCRIPT test search test.txt"
run_test "Command: diff" "$RESCRIPT test diff"
run_test "Command: size" "$RESCRIPT test size $SRC_PATH"
run_test "Command: info" "$RESCRIPT test info"
run_test "Command: snaps" "$RESCRIPT test snaps"
run_test "Command: logs" "$RESCRIPT test logs"
run_test "Command: extract (auto-latest)" "$RESCRIPT test extract $SRC_PATH/docs/test.txt"
run_test "Command: restorer (-P path filter)" "$RESCRIPT test restorer -P $SRC_PATH"
