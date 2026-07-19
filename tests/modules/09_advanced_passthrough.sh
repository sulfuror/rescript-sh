#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "09_advanced_passthrough (Complex User Commands)"

# 1. Complex backup with multiple restic flags
run_test "Advanced: backup with --exclude, --tag, --dry-run" "$RESCRIPT test backup $SRC_PATH --exclude='*.log' --tag 'complex-test' --dry-run"

# 2. Complex snapshots query
run_test "Advanced: snapshots --compact --group-by" "$RESCRIPT test snapshots --compact --group-by paths"

# 3. Find with filters
run_test "Advanced: find with --host filter" "$RESCRIPT test find --host $(hostname) 'test.txt'"

# 4. Raw restic 'ls' command
run_test "Advanced: raw restic 'ls latest'" "$RESCRIPT test ls latest $SRC_PATH"

# 5. Raw restic 'dump' command
run_test "Advanced: raw restic 'dump'" "$RESCRIPT test dump latest $SRC_PATH/docs/test.txt > /dev/null"

# 6. Raw restic 'stats' command with mode
run_test "Advanced: raw restic 'stats --mode'" "$RESCRIPT test stats --mode restore-size"

# 7. Raw restic 'forget' with complex retention rules
run_test "Advanced: raw restic 'forget' with retentions" "$RESCRIPT test forget --keep-last 5 --keep-daily 7 --keep-weekly 4 --dry-run"

# 8. Mix of Rescript global flags and Restic flags
# -Q (Quiet) and -T (Timer) are rescript flags, --read-data-subset is a restic flag
run_test "Advanced: mixed rescript & restic flags" "$RESCRIPT test check -Q --read-data-subset=5% -T"

# 9. Restore with specific target and include
run_test "Advanced: raw restic 'restore' with filters" "$RESCRIPT test restore latest --target $TEST_ENV/restore_test --include $SRC_PATH/docs"
