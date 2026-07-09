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
