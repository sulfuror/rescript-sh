#!/bin/bash
# ============================================================== #
# Rescript Universal Test Framework - Master Runner              #
# ============================================================== #
# Execute this script to run the entire automated test suite.    #
# ============================================================== #

c_green="\033[1;32m"
c_red="\033[1;31m"
c_cyan="\033[1;36m"
c_reset="\033[0m"

echo "=========================================================="
echo " Starting Rescript Universal Test Framework"
echo "=========================================================="

# Find all scripts in the tests/ directory and sort them alphabetically
TEST_SCRIPTS=($(find "$(dirname "$0")/modules" -maxdepth 1 -name "*.sh" | sort))

total_modules=${#TEST_SCRIPTS[@]}
modules_passed=0

for script in "${TEST_SCRIPTS[@]}"; do
  chmod +x "$script"
  "$script"
  if [ $? -eq 0 ]; then
    ((modules_passed++))
  else
    echo -e "\n${c_red}CRITICAL FAILURE in module: $(basename "$script")${c_reset}"
  fi
done

echo ""
echo "=========================================================="
if [ $modules_passed -eq $total_modules ]; then
  echo -e " ${c_green}All $total_modules test modules PASSED!${c_reset}"
  echo -e " The codebase is POSIX compliant and mathematically sound."
else
  echo -e " ${c_red}Only $modules_passed out of $total_modules test modules PASSED.${c_reset}"
  echo -e " Please check the logs above for detailed failure information."
fi
echo "=========================================================="
