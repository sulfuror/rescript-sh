function update {
  if [[ ! $(command -v curl) ]] ; then
    echo "***$(basename "$0") warning***"
    echo "[curl] not found..."
    echo ""
    echo "[$repo] works with [curl] to download the updated script."
    echo "Please, install [curl] to proceed."
    exit
  fi

  echo "Checking for the latest official release..."
  local latest_release
  latest_release=$(curl -s "https://api.github.com/repos/sulfuror/rescript-sh/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -n 1 | cut -d'"' -f4)
  
  if [[ -z "$latest_release" ]]; then
    echo -e "\n${c_red}Failed to fetch the latest release from GitHub.${c_reset}"
    echo "Check your internet connection or the repository status."
    exit 1
  fi

  curl -s -L "https://github.com/sulfuror/rescript-sh/releases/download/${latest_release}/rescript" -o "$tmp_dir/rescript" || true
  rescript_latest="$tmp_dir/rescript"
  trap 'rm -rf "$rescript_latest" 2> /dev/null' INT QUIT TERM EXIT

  local rescript_bin
  rescript_bin=$(command -v rescript || echo "$0")

  local current_version
  current_version=$(grep '^version=' "$rescript_bin" | head -n 1 | cut -d'"' -f2 || echo "unknown")
  local remote_version
  remote_version=$(grep '^version=' "$rescript_latest" | head -n 1 | cut -d'"' -f2 || echo "unknown")

  if [[ "$current_version" == "$remote_version" ]] ; then
    echo "You are already running rescript $version, which is the latest version."
    exit 0
  else
    chmod 755 "$rescript_latest"
    read -rp "rescript version $remote_version is available; do you want to install it? (y/n): " updater
    case "$updater" in
      y|yes)
        if [[ $rescript_bin == /usr/bin/rescript || $rescript_bin == /bin/rescript || $rescript_bin == /usr/local/bin/rescript ]] ; then
          if [[ "$(whoami)" = "root" ]] ; then
            mv "$rescript_latest" "$rescript_bin"
            echo "Rescript have been updated to the latest version!"
            read -rp "Do you want to install/update the bash autocomplete feature? (y/N): " ans_auto
            if [[ "$ans_auto" =~ ^[Yy] ]]; then
              "$rescript_bin" install --autocomplete-only
            fi
          else
            echo "Rescript is located at $rescript_bin."
            echo "To update in this location you need to run [update] again as [root]:"
            echo ""
            echo "  sudo rescript update"
            echo "" 
            echo "Nothing done... exiting."
            exit 0
          fi
        else
          chmod 700 "$rescript_latest"
          mv "$rescript_latest" "$rescript_bin"
          echo "Rescript have been updated to the latest version!"
          read -rp "Do you want to install/update the bash autocomplete feature? (y/N): " ans_auto
          if [[ "$ans_auto" =~ ^[Yy] ]]; then
            "$rescript_bin" install --autocomplete-only
          fi
        fi
        ;;
      *)
        echo "Nothing done... exiting."
        exit 0
        ;;
    esac
  fi
}
