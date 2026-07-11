function update {
  if [[ ! $(command -v wget) ]] ; then
    echo "***$(basename "$0") warning***"
    echo "[wget] not found..."
    echo ""
    echo "[$repo] works with [wget] to download the updated script."
    echo "Please, install [wget] to proceed."
    exit
  fi
  if [[ -d "/tmp" ]] ; then
    tmp_dir="/tmp"
  else
    tmp_dir="$TMPDIR"
  fi
  wget -P "$tmp_dir" https://gitlab.com/sulfuror/rescript.sh/raw/master/rescript 2> /dev/null
  rescript_latest="$tmp_dir/rescript"
  trap 'rm -rf "$rescript_latest" 2> /dev/null' INT QUIT TERM EXIT

  if [[ "$(sed '3!d' "$(command -v rescript)")" = "$(sed '3!d' "$rescript_latest")" ]] ; then
    echo "You are already running rescript $version, which is the latest version."
    exit 0
  else
    chmod 755 "$rescript_latest"
    read -rp "rescript version $(sed '3!d' "$rescript_latest" | sed -e 's/version=//g') is available; do you want to install it? (y/n): " updater
    case "$updater" in
      y|yes)
        if [[ $(command -v rescript) == /usr/bin/rescript || $(command -v rescript) == /bin/rescript || $(command -v rescript) == /usr/local/bin/rescript ]] ; then
          if [[ "$(whoami)" = "root" ]] ; then
            mv "$rescript_latest" "$(command -v rescript)"
            echo "Rescript have been updated to the latest version!"
          else
            echo "Rescript is located at $(command -v rescript)."
            echo "To update in this location you need to run [update] again as [root]:"
            echo ""
            echo "  sudo rescript update"
            echo "" 
            echo "Nothing done... exiting."
            exit 0
          fi
        else
          chmod 700 "$rescript_latest"
          mv "$rescript_latest" "$(command -v rescript)"
          echo "Rescript have been updated to the latest version!"
        fi
        ;;
      *)
        echo "Nothing done... exiting."
        exit 0
        ;;
    esac
  fi
}
