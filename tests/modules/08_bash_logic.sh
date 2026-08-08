#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../src" && pwd)"
export DIR

start_test_module "08_bash_logic (Core Bash Functions)"

# Test array_contains (Positive)
echo -ne " ${c_cyan}Test:${c_reset} array_contains (Positive Match) "
cmd=$(cat << 'EOF'
source "$DIR/01_globals.sh" >/dev/null 2>&1
source "$DIR/02_utils.sh" >/dev/null 2>&1
array_contains "apple" "orange" "apple" "banana"
EOF
)
bash -c "$cmd"
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Expected 0)"
fi

# Test array_contains (Negative)
echo -ne " ${c_cyan}Test:${c_reset} array_contains (Negative Match) "
cmd=$(cat << 'EOF'
source "$DIR/01_globals.sh" >/dev/null 2>&1
source "$DIR/02_utils.sh" >/dev/null 2>&1
array_contains "grape" "orange" "apple" "banana"
EOF
)
bash -c "$cmd"
if [ $? -ne 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Expected non-zero)"
fi

# Test duration math
echo -ne " ${c_cyan}Test:${c_reset} duration calculation "
cmd=$(cat << 'EOF'
source "$DIR/01_globals.sh" >/dev/null 2>&1
source "$DIR/02_utils.sh" >/dev/null 2>&1
SECONDS=125
res=$(duration)
if [[ "$res" == *"2 minutes and 5 seconds"* ]]; then exit 0; else exit 1; fi
EOF
)
bash -c "$cmd"
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Output did not match expected math)"
fi


# Test run_with_spinner to ensure it doesn't crash on simple commands
echo -ne " ${c_cyan}Test:${c_reset} run_with_spinner basic execution "
cmd=$(cat << 'EOF'
source "$DIR/01_globals.sh" >/dev/null 2>&1
source "$DIR/02_utils.sh" >/dev/null 2>&1
run_with_spinner "sleep 0.1" "Testing Spinner" >/dev/null 2>&1
EOF
)
bash -c "$cmd"
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
fi

# Test opsys parsing
echo -ne " ${c_cyan}Test:${c_reset} opsys extraction "
cmd=$(cat << 'EOF'
source "$DIR/01_globals.sh" >/dev/null 2>&1
source "$DIR/02_utils.sh" >/dev/null 2>&1
res=$(opsys)
if [[ -n "$res" ]]; then exit 0; else exit 1; fi
EOF
)
bash -c "$cmd"
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
fi
