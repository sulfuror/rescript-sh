function install {
  echo "$ui_line_eq"
  echo "     Installation     "
  echo "$ui_line_eq"
  echo " [1] System-wide      "
  echo " [2] For this user    "
  echo " [3] Exit             "
  echo "$ui_line_eq"
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
