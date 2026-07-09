function install {
  echo "======================"
  echo "     Installation     "
  echo "======================"
  echo " [1] System-wide      "
  echo " [2] For this user    "
  echo " [3] Exit             "
  echo "======================"
  read -rp "Select an option and press Enter [ 1 - 4 ]: " installation
  case "$installation" in
    1|system)
      chmod 755 "$(basename "$0")"
      if [[ "$(whoami)" = "root" ]] ; then
        if [[ "$unix_name" = "Darwin" ]] ; then
          cp "$(basename "$0")" /usr/local/bin/rescript
        else
          cp "$(basename "$0")" /usr/bin/rescript
        fi
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      else
        echo "You must be [root] for system-wide installation. e.g.:"
        echo "  sudo ./rescript install"
        echo ""
        echo "Nothing done; exiting..."
        exit
      fi
      ;;
    2|user)
      chmod 700 "$(basename "$0")"
      if [[ -d "$HOME/bin" ]] ; then
        cp "$(basename "$0")" "$HOME/bin/rescript"
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      elif [[ -d "$HOME/.local/bin" ]] ; then
        cp "$(basename "$0")" "$HOME/.local/bin/rescript"
        echo "Installation successful!"
        echo "Run [rescript config] to configure your repository."
        exit
      else
        echo "There is no [$HOME/.local/bin] directory present."
        read -rp "Do you wish to create it now? y/n: " ans_install
        case $ans_install in
          y|yes)
            mkdir -p "$HOME/.local/bin"
            cp "$(basename "$0")" "$HOME/.local/bin/rescript"
            echo "Installation successful!"
            echo "Run [rescript config] to configure your repository."
            echo ""
            echo "Remember to include $HOME/.local/bin in your PATH."
            exit
            ;;
          n|no)
            echo "Nothing done; exiting..."
            exit
            ;;
          *)
            echo "No valid action indicated; exiting..."
            exit
            ;;
        esac
      fi
      ;;
    3|exit) echo "Exiting..." ; exit ;;
    *) clear ; echo "No valid action indicated..." ; install ;;
  esac
}

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

# ============================================================== #
