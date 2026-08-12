# ============================================================== #
#                       COMMAND: UPDATE                          #
# ============================================================== #
update() {
  if ! command -v curl >/dev/null ; then
    printf "%s\n" "***$(basename "$0") warning***"
    printf "%s\n" "[curl] not found..."
    printf "\n"
    printf "%s\n" "[$repo] works with [curl] to download the updated script."
    printf "%s\n" "Please, install [curl] to proceed."
    exit 1
  fi

  printf "%s\n" "Checking for the latest official release..."
  local latest_release
  latest_release=$(curl -s "https://api.github.com/repos/sulfuror/rescript-sh/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -n 1 | cut -d'"' -f4)
  
  if [[ -z "$latest_release" ]]; then
    printf "%b\n" "\n${c_red}Failed to fetch the latest release from GitHub.${c_reset}"
    printf "%s\n" "Check your internet connection or the repository status."
    exit 1
  fi

  local rescript_latest="$tmp_dir/rescript"
  if ! curl -s -L "https://github.com/sulfuror/rescript-sh/releases/download/${latest_release}/rescript" -o "$rescript_latest" || ! grep -q "^#!/usr/bin/env bash" "$rescript_latest" 2>/dev/null; then
    printf "%b\n" "\n${c_red}Failed to download the latest release or the file is corrupted.${c_reset}"
    rm -f "$rescript_latest"
    exit 1
  fi


  local rescript_bin
  rescript_bin=$(command -v rescript || printf "%s\n" "$0")

  local current_version
  current_version=$("$rescript_bin" -v 2>/dev/null | awk -F': ' '/^Version/{print $2}' || true)
  if [[ -z "$current_version" ]]; then
    current_version=$(grep -oE '^version="[^"]+"' "$rescript_bin" 2>/dev/null | head -n 1 | cut -d'"' -f2 || printf "%s\n" "unknown")
  fi

  local remote_version
  remote_version=$("$rescript_latest" -v 2>/dev/null | awk -F': ' '/^Version/{print $2}' || true)
  if [[ -z "$remote_version" ]]; then
    remote_version=$(grep -oE '^version="[^"]+"' "$rescript_latest" 2>/dev/null | head -n 1 | cut -d'"' -f2 || printf "%s\n" "unknown")
  fi

  if [[ "$current_version" == "$remote_version" ]] ; then
    printf "%s\n" "You are already running rescript $version, which is the latest version."
    exit 0
  else
    chmod 755 "$rescript_latest"
    local updater
    read -rp "rescript version $remote_version is available; do you want to install it? (y/n): " updater
    case "$updater" in
      y|yes)
        if [[ $rescript_bin == /usr/bin/rescript || $rescript_bin == /bin/rescript || $rescript_bin == /usr/local/bin/rescript ]] ; then
          if ! _require_sudo "update process"; then
            sudo mv "$rescript_latest" "$rescript_bin"
          else
            mv "$rescript_latest" "$rescript_bin"
          fi

          printf "%s\n" "Rescript has been updated to the latest version!"
          if [[ "$EUID" -ne 0 ]] ; then
            sudo "$rescript_bin" install --autocomplete-only system
          else
            "$rescript_bin" install --autocomplete-only system
          fi
        else
          chmod 700 "$rescript_latest"
          mv "$rescript_latest" "$rescript_bin"
          printf "%s\n" "Rescript has been updated to the latest version!"
          "$rescript_bin" install --autocomplete-only user
        fi
        ;;
      *)
        printf "%s\n" "Nothing done... exiting."
        exit 0
        ;;
    esac
  fi
}
