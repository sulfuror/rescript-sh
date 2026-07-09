#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "02_global_flags"

run_test "Help Flag (-h)" "$RESCRIPT -h"
run_test "Help Flag on Command (test backup -h)" "$RESCRIPT test backup -h"
run_test "Simulate Flag (-S)" "$RESCRIPT test backup -S"
run_test "Quiet Flag (-Q)" "$RESCRIPT test info -Q"
run_test "Timer Flag (-T)" "$RESCRIPT test info -T"
run_test "Metadata Flag (-M)" "$RESCRIPT test info -M"
