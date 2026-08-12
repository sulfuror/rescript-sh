# ============================================================== #
#                       COMMAND: UNINSTALL                       #
# ============================================================== #
uninstall() {
  printf "%s\n" "$ui_line_eq"
  printf "%s\n" "     Uninstallation   "
  printf "%s\n" "$ui_line_eq"
  printf "%s\n" " [1] System-wide      "
  printf "%s\n" " [2] For this user    "
  printf "%s\n" " [3] Exit             "
  printf "%s\n" "$ui_line_eq"
  local uninstallation
  read -rp "Select an option and press Enter [ 1 - 3 ]: " uninstallation
  case "$uninstallation" in
    1|system)
      if [[ ! -f "/usr/local/bin/rescript" && ! -f "/usr/bin/rescript" ]]; then
        printf "\n"
        printf "%s\n" "Rescript does not appear to be installed system-wide."
        printf "%s\n" "If you installed it for a specific user, please run the command again"
        printf "%s\n" "and select the 'For this user' option."
        printf "\n"
        printf "%s\n" "Nothing done; exiting..."
        exit 1
      fi
      if _require_sudo "system-wide uninstallation"; then
        if [[ -f "/usr/local/bin/rescript" ]]; then rm -f "/usr/local/bin/rescript"; fi
        if [[ -f "/usr/bin/rescript" ]]; then rm -f "/usr/bin/rescript"; fi
        if [[ -f "/usr/local/etc/bash_completion.d/rescript" ]]; then rm -f "/usr/local/etc/bash_completion.d/rescript"; fi
        if [[ -f "/etc/bash_completion.d/rescript" ]]; then rm -f "/etc/bash_completion.d/rescript"; fi
        printf "%s\n" "System-wide uninstallation successful!"
      else
        if [[ -f "/usr/local/bin/rescript" ]]; then sudo rm -f "/usr/local/bin/rescript"; fi
        if [[ -f "/usr/bin/rescript" ]]; then sudo rm -f "/usr/bin/rescript"; fi
        if [[ -f "/usr/local/etc/bash_completion.d/rescript" ]]; then sudo rm -f "/usr/local/etc/bash_completion.d/rescript"; fi
        if [[ -f "/etc/bash_completion.d/rescript" ]]; then sudo rm -f "/etc/bash_completion.d/rescript"; fi
        printf "\n"
        printf "%s\n" "System-wide uninstallation successful!"
      fi
      ;;
    2|user)
      if [[ ! -f "$HOME/bin/rescript" && ! -f "$HOME/.local/bin/rescript" ]]; then
        printf "\n"
        printf "%s\n" "Rescript does not appear to be installed for this user in [$HOME]."
        printf "%s\n" "If you installed it system-wide, please run the command again"
        printf "%s\n" "and select the 'System-wide' option."
        printf "\n"
        printf "%s\n" "Nothing done; exiting..."
        exit 1
      fi
      if [[ -f "$HOME/bin/rescript" ]]; then rm -f "$HOME/bin/rescript"; fi
      if [[ -f "$HOME/.local/bin/rescript" ]]; then rm -f "$HOME/.local/bin/rescript"; fi
      if [[ -f "$HOME/.local/share/bash-completion/completions/rescript" ]]; then rm -f "$HOME/.local/share/bash-completion/completions/rescript"; fi
      printf "%s\n" "User uninstallation successful!"
      ;;
    3|exit) printf "%s\n" "Exiting..." ; exit 0 ;;
    *) clear ; printf "%s\n" "No valid action indicated..." ; uninstall ;;
  esac

  printf "\n"
  local ans_clean
  read -rp "Do you also wish to delete your configurations and logs in [$HOME/.rescript]? (y/N): " ans_clean
  case ${ans_clean,,} in
    y|yes)
      rm -rf "$HOME/.rescript"
      printf "%s\n" "Configuration directory removed."
      ;;
    *)
      printf "%s\n" "Configurations kept."
      ;;
  esac
  exit 0
}
