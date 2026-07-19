#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

start_test_module "07_strict_mode_edge_cases"

# Test missing flag argument (--host)
echo -ne " ${c_cyan}Test:${c_reset} Missing Flag Argument (--host) "
out=$(eval "$RESCRIPT test info --host" 2>&1)
if echo "$out" | grep -qi "unbound variable"; then
  echo -e "[${c_red}FAIL${c_reset}] (Bash crashed with unbound variable)"
  echo "$out"
else
  echo -e "[${c_green}PASS${c_reset}] (Handled without bash crash)"
fi

# Test missing flag argument (-V)
echo -ne " ${c_cyan}Test:${c_reset} Missing Flag Argument (-V) "
out=$(eval "$RESCRIPT test env -V" 2>&1)
if echo "$out" | grep -qi "unbound variable"; then
  echo -e "[${c_red}FAIL${c_reset}] (Bash crashed with unbound variable)"
  echo "$out"
else
  echo -e "[${c_green}PASS${c_reset}] (Handled without bash crash)"
fi

# Test duration edge case
echo -ne " ${c_cyan}Test:${c_reset} Duration Edge Case (Timer without crash) "
out=$(eval "$RESCRIPT test check -T" 2>&1)
if echo "$out" | grep -qi "unbound variable"; then
  echo -e "[${c_red}FAIL${c_reset}] (Bash crashed with unbound array on duration)"
  echo "$out"
else
  echo -e "[${c_green}PASS${c_reset}] (Timer executed successfully)"
fi

# Test raw command with unsupported restic flag
echo -ne " ${c_cyan}Test:${c_reset} Raw command unsupported flag "
out=$(eval "$RESCRIPT test check --dry-run" 2>&1)
if echo "$out" | grep -qi "unbound variable"; then
  echo -e "[${c_red}FAIL${c_reset}] (Bash crashed)"
  echo "$out"
else
  echo -e "[${c_green}PASS${c_reset}] (Handled by restic cleanly)"
fi
