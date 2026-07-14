#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "08_bash_logic (Core Bash Functions)"

# Test array_contains (Positive)
echo -ne " ${c_cyan}Test:${c_reset} array_contains (Positive Match) "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
array_contains "apple" "orange" "apple" "banana"
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Expected 0)"
fi

# Test array_contains (Negative)
echo -ne " ${c_cyan}Test:${c_reset} array_contains (Negative Match) "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
array_contains "grape" "orange" "apple" "banana"
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Expected non-zero)"
fi

# Test duration math
echo -ne " ${c_cyan}Test:${c_reset} duration calculation "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
TIME_START=1000
TIME_END=1125
# 125 seconds = 00h 02m 05s
res=$(duration)
if [[ "$res" == *"00:02:05"* ]]; then exit 0; else exit 1; fi
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}] (Output did not match expected math)"
fi

# Test print_progress calculation
echo -ne " ${c_cyan}Test:${c_reset} print_progress math "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
res=$(print_progress 50 200 "Test")
# 50 out of 200 is 25%
if [[ "$res" == *"25%"* ]]; then exit 0; else exit 1; fi
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
fi

# Test run_with_spinner to ensure it doesn't crash on simple commands
echo -ne " ${c_cyan}Test:${c_reset} run_with_spinner basic execution "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
run_with_spinner "sleep 0.5" "Testing Spinner"
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
fi

# Test latest_error extraction
echo -ne " ${c_cyan}Test:${c_reset} latest_error log parsing "
cmd=$(cat << 'EOF'
source src/01_globals.sh >/dev/null 2>&1
source src/02_utils.sh >/dev/null 2>&1
log="$HOME/fake_log.log"
echo "Starting backup" > "$log"
echo "Fatal: unable to read config" >> "$log"
res=$(latest_error)
if [[ "$res" == *"Fatal: unable to read config"* ]]; then exit 0; else exit 1; fi
EOF
)
eval "$cmd" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
fi
