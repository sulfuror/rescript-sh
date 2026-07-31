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

LOG_FILE="/tmp/rescript_run_all_$$.log"
trap 'rm -f "$LOG_FILE"' EXIT

# Redirect stdout and stderr to tee to capture output while keeping it on screen
exec 3>&1 4>&2
exec > >(tee "$LOG_FILE") 2>&1

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
  WEBHOOK_SUBJECT="✅ **Rescript Universal Test Framework**\nAll $total_modules test modules PASSED! The codebase is POSIX compliant."
else
  echo -e " ${c_red}Only $modules_passed out of $total_modules test modules PASSED.${c_reset}"
  echo -e " Please check the logs above for detailed failure information."
  WEBHOOK_SUBJECT="❌ **Rescript Universal Test Framework**\nCRITICAL FAILURE: Only $modules_passed out of $total_modules test modules PASSED. Check the logs."
fi
echo "=========================================================="

# Close file descriptors so tee flushes the file completely
exec 1>&3 2>&4

# Send Webhook Notification if configured in global.conf
if [[ -f "$HOME/.rescript/config/global.conf" ]]; then
  WEBHOOK_URL=$(grep -E '^WEBHOOK_URL=' "$HOME/.rescript/config/global.conf" | head -n 1 | sed -e 's/^WEBHOOK_URL=//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
  if [[ -n "$WEBHOOK_URL" ]]; then
    CLEAN_LOG="/tmp/rescript_tests_clean_$$.txt"
    sed -E "s/$(printf '\033')\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$LOG_FILE" | tr -d '\r' > "$CLEAN_LOG"
    curl -s -F "payload_json={\"content\": \"$WEBHOOK_SUBJECT\"}" -F "file=@$CLEAN_LOG" "$WEBHOOK_URL" > /dev/null
    rm -f "$CLEAN_LOG"
  fi
fi
