# ============================================================== #
#                       COMMAND: UNINSTALL                       #
# ============================================================== #

function uninstall {
  echo "$ui_line_eq"
  echo "     Uninstallation   "
  echo "$ui_line_eq"
  echo " [1] System-wide      "
  echo " [2] For this user    "
  echo " [3] Exit             "
  echo "$ui_line_eq"
  read -rp "Select an option and press Enter [ 1 - 3 ]: " uninstallation
  case "$uninstallation" in
    1|system)
      if [[ ! -f "/usr/local/bin/rescript" && ! -f "/usr/bin/rescript" ]]; then
        echo ""
        echo "Rescript does not appear to be installed system-wide."
        echo "If you installed it for a specific user, please run the command again"
        echo "and select the 'For this user' option."
        echo ""
        echo "Nothing done; exiting..."
        exit 1
      fi
      if _require_sudo "system-wide uninstallation"; then
        if [[ -f "/usr/local/bin/rescript" ]]; then rm -f "/usr/local/bin/rescript"; fi
        if [[ -f "/usr/bin/rescript" ]]; then rm -f "/usr/bin/rescript"; fi
        if [[ -f "/usr/local/etc/bash_completion.d/rescript" ]]; then rm -f "/usr/local/etc/bash_completion.d/rescript"; fi
        if [[ -f "/etc/bash_completion.d/rescript" ]]; then rm -f "/etc/bash_completion.d/rescript"; fi
        echo "System-wide uninstallation successful!"
      else
        if [[ -f "/usr/local/bin/rescript" ]]; then sudo rm -f "/usr/local/bin/rescript"; fi
        if [[ -f "/usr/bin/rescript" ]]; then sudo rm -f "/usr/bin/rescript"; fi
        if [[ -f "/usr/local/etc/bash_completion.d/rescript" ]]; then sudo rm -f "/usr/local/etc/bash_completion.d/rescript"; fi
        if [[ -f "/etc/bash_completion.d/rescript" ]]; then sudo rm -f "/etc/bash_completion.d/rescript"; fi
        echo ""
        echo "System-wide uninstallation successful!"
      fi
      ;;
    2|user)
      if [[ ! -f "$HOME/bin/rescript" && ! -f "$HOME/.local/bin/rescript" ]]; then
        echo ""
        echo "Rescript does not appear to be installed for this user in [$HOME]."
        echo "If you installed it system-wide, please run the command again"
        echo "and select the 'System-wide' option."
        echo ""
        echo "Nothing done; exiting..."
        exit 1
      fi
      if [[ -f "$HOME/bin/rescript" ]]; then rm -f "$HOME/bin/rescript"; fi
      if [[ -f "$HOME/.local/bin/rescript" ]]; then rm -f "$HOME/.local/bin/rescript"; fi
      if [[ -f "$HOME/.local/share/bash-completion/completions/rescript" ]]; then rm -f "$HOME/.local/share/bash-completion/completions/rescript"; fi
      echo "User uninstallation successful!"
      ;;
    3|exit) echo "Exiting..." ; exit 0 ;;
    *) clear ; echo "No valid action indicated..." ; uninstall ;;
  esac

  echo ""
  read -rp "Do you also wish to delete your configurations and logs in [$HOME/.rescript]? (y/N): " ans_clean
  case ${ans_clean,,} in
    y|yes)
      rm -rf "$HOME/.rescript"
      echo "Configuration directory removed."
      ;;
    *)
      echo "Configurations kept."
      ;;
  esac
  exit 0
}
