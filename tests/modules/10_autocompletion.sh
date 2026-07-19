#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib_test.sh"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../src" && pwd)"
export DIR

start_test_module "10_autocompletion (Bash Programmable Completion)"

setup_sandbox
mkdir -p "$TEST_ENV/.rescript/config"
mkdir -p "$TEST_ENV/.rescript/logs"
touch "$TEST_ENV/.rescript/config/repo1.conf"
touch "$TEST_ENV/.rescript/config/repo2.conf"
touch "$TEST_ENV/.rescript/logs/test.log"

export HOME="$TEST_ENV"

# Extract the autocomplete logic from the executable and save to a temporary file
sed -n '/_rescript_completions() {/,/^}/p' "$DIR/../rescript" > "$TEST_ENV/autocomplete.sh"

# Test 1: Global commands and repos (CWORD=1)
echo -ne " ${c_cyan}Test:${c_reset} Suggest repos and global commands "
cmd=$(cat << 'EOF'
source "$1/autocomplete.sh"
COMP_WORDS=("rescript" "")
COMP_CWORD=1
_rescript_completions
echo "${COMPREPLY[*]}"
EOF
)
out=$(bash -c "$cmd" _ "$TEST_ENV")
if [[ " $out " == *" repo1 "* && " $out " == *" repo2 "* && " $out " == *" status "* ]]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
  exit 1
fi

# Test 2: Flags (CWORD=1 with -)
echo -ne " ${c_cyan}Test:${c_reset} Suggest global flags on '-' "
cmd=$(cat << 'EOF'
source "$1/autocomplete.sh"
COMP_WORDS=("rescript" "-")
COMP_CWORD=1
_rescript_completions
echo "${COMPREPLY[*]}"
EOF
)
out=$(bash -c "$cmd" _ "$TEST_ENV")
if [[ " $out " == *" --version "* && " $out " == *" --help "* ]]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
  exit 1
fi

# Test 3: Repo Commands (CWORD=2 after a repo)
echo -ne " ${c_cyan}Test:${c_reset} Suggest repo commands after repo name "
cmd=$(cat << 'EOF'
source "$1/autocomplete.sh"
COMP_WORDS=("rescript" "repo1" "")
COMP_CWORD=2
_rescript_completions
echo "${COMPREPLY[*]}"
EOF
)
out=$(bash -c "$cmd" _ "$TEST_ENV")
if [[ " $out " == *" backup "* && " $out " == *" restorer "* ]]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
  exit 1
fi

# Test 4: Logs completion
echo -ne " ${c_cyan}Test:${c_reset} Suggest log files after --view "
cmd=$(cat << 'EOF'
source "$1/autocomplete.sh"
COMP_WORDS=("rescript" "repo1" "logs" "--view" "")
COMP_CWORD=4
_rescript_completions
echo "${COMPREPLY[*]}"
EOF
)
out=$(bash -c "$cmd" _ "$TEST_ENV")
if [[ " $out " == *" test.log "* ]]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
  exit 1
fi

# Test 5: Variables completion
echo -ne " ${c_cyan}Test:${c_reset} Suggest variables after --var "
cmd=$(cat << 'EOF'
source "$1/autocomplete.sh"
COMP_WORDS=("rescript" "repo1" "env" "--var" "")
COMP_CWORD=4
_rescript_completions
echo "${COMPREPLY[*]}"
EOF
)
out=$(bash -c "$cmd" _ "$TEST_ENV")
if [[ " $out " == *" REPO_TARGET "* && " $out " == *" PRE_CMD "* ]]; then
  echo -e "[${c_green}PASS${c_reset}]"
else
  echo -e "[${c_red}FAIL${c_reset}]"
  exit 1
fi

cleanup_sandbox
