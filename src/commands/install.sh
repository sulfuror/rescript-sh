# ============================================================== #
#                        COMMAND: INSTALL                        #
# ============================================================== #

install_autocomplete() {
  local target_dir="$1"
  local target_file="$target_dir/rescript"
  
  if [[ ! -d "$target_dir" ]] ; then
    mkdir -p "$target_dir" 2>/dev/null
  fi
  
  if [[ -w "$target_dir" ]] ; then
    cat << 'EOF' > "$target_file"
_rescript_completions() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  
  if [[ $COMP_CWORD -eq 1 ]]; then
    if [[ "$cur" == -* ]]; then
      local global_flags="-D --debug -E --email -h --help -L --log -M --metadata -Q --quiet -S --simulate -T --timer --version"
      COMPREPLY=( $(compgen -W "${global_flags}" -- "${cur}") )
      return 0
    fi
    
    local repos=""
    if [[ -d "$HOME/.rescript/config" ]]; then
      for f in "$HOME/.rescript/config"/*.conf; do
        if [[ -f "$f" ]]; then
          repos="${repos} $(basename "$f" .conf)"
        fi
      done
    fi
    local global_commands="all config editor help install status uninstall update version"
    COMPREPLY=( $(compgen -W "${repos} ${global_commands}" -- "${cur}") )
    return 0
  fi
  
  if [[ "$prev" == "-X" || "$prev" == "--exclude" || "$prev" == "--ignore-repo" ]]; then
    local repos=""
    if [[ -d "$HOME/.rescript/config" ]]; then
      for f in "$HOME/.rescript/config"/*.conf; do
        if [[ -f "$f" ]]; then
          repos="${repos} $(basename "$f" .conf)"
        fi
      done
    fi
    COMPREPLY=( $(compgen -W "${repos}" -- "${cur}") )
    return 0
  fi
  
  if [[ "$prev" == "--view" || "$prev" == "-R" || "$prev" == "--remove" ]]; then
    local logfiles=""
    if [[ -d "$HOME/.rescript/logs" ]]; then
      for f in "$HOME/.rescript/logs"/*; do
        if [[ -f "$f" ]]; then
          logfiles="${logfiles} $(basename "$f")"
        fi
      done
    fi
    if [[ "$prev" == "-R" || "$prev" == "--remove" ]]; then
      logfiles="${logfiles} all"
    fi
    COMPREPLY=( $(compgen -W "${logfiles}" -- "${cur}") )
    return 0
  fi
  
  if [[ "$prev" == "-P" || "$prev" == "--path" ]]; then
    # Enable bash built-in file and directory completion
    compopt -o default 2>/dev/null || true
    COMPREPLY=( $(compgen -f -- "${cur}") )
    return 0
  fi
  
  if [[ "$prev" == "-V" ]]; then
    # -V can be used for 'logs --view' or 'env/search --var'
    if [[ "${COMP_LINE}" == *"logs "* || "${COMP_LINE}" == *"logs" ]]; then
      local logfiles=""
      if [[ -d "$HOME/.rescript/logs" ]]; then
        for f in "$HOME/.rescript/logs"/*; do
          if [[ -f "$f" ]]; then
            logfiles="${logfiles} $(basename "$f")"
          fi
        done
      fi
      COMPREPLY=( $(compgen -W "${logfiles}" -- "${cur}") )
      return 0
    else
      local vars="REPO_TARGET RESTIC_PASSWORD RESTIC_PASSWORD_COMMAND CLEAN KEEP_LAST KEEP_HOURLY KEEP_DAILY KEEP_WEEKLY KEEP_MONTHLY KEEP_YEARLY PRE_CMD POST_CMD NOTIFY WEBHOOK_URL CONFIRMATION_EMAIL EXCLUDE_FILE HOST BIONIC MAX_LOG LOG_RETENTION"
      COMPREPLY=( $(compgen -W "${vars}" -- "${cur}") )
      return 0
    fi
  fi

  if [[ "$prev" == "--var" ]]; then
    local vars="REPO_TARGET RESTIC_PASSWORD RESTIC_PASSWORD_COMMAND CLEAN KEEP_LAST KEEP_HOURLY KEEP_DAILY KEEP_WEEKLY KEEP_MONTHLY KEEP_YEARLY PRE_CMD POST_CMD NOTIFY WEBHOOK_URL CONFIRMATION_EMAIL EXCLUDE_FILE HOST BIONIC MAX_LOG LOG_RETENTION"
    COMPREPLY=( $(compgen -W "${vars}" -- "${cur}") )
    return 0
  fi
  
  if [[ "$prev" == "-Z" || "$prev" == "--snapshot" ]]; then
    COMPREPLY=( $(compgen -W "latest" -- "${cur}") )
    return 0
  fi

  if [[ "$cur" == -* ]]; then
    local all_flags="-C --check -D --debug -E --email -F --full -H --host -I --info -L --log -M --metadata -O --skip-office -P --path --parallel -Q --quiet -R --remove -S --simulate -T --tag --timer -U --cleanup -V --var --view -W --webhook -X --exclude --ignore-repo -Z --snapshot -g --global -h --help -i --interactive --ignore-case --reset --wizard --version --autocomplete-only --background"
    COMPREPLY=( $(compgen -W "${all_flags}" -- "${cur}") )
    return 0
  fi

  if [[ $COMP_CWORD -eq 2 ]]; then
    if [[ "$prev" == "config" || "$prev" == "status" || "$prev" == "install" || "$prev" == "uninstall" || "$prev" == "update" || "$prev" == "editor" || "$prev" == "version" || "$prev" == "help" ]]; then
      return 0
    else
      local repo_commands="automatic backup cleanup diff env extract history info init logs mounter next restorer search size snaps status umounter unlocker upgrade"
      COMPREPLY=( $(compgen -W "${repo_commands}" -- "${cur}") )
      return 0
    fi
  fi
}
complete -F _rescript_completions rescript
EOF
    printf "%b\n" " \033[1;32m*\033[0m Bash autocompletion installed at: \033[1;37m$target_file\033[0m"
  fi
}
install() {
  if [[ "${1:-}" == "--autocomplete-only" ]]; then
    local target="${2:-}"
    if [[ -z "$target" ]]; then
      printf "%s\n" "$ui_line_eq"
      printf "%s\n" "  Autocomplete Installation   "
      printf "%s\n" "$ui_line_eq"
      printf "%s\n" " [1] System-wide              "
      printf "%s\n" " [2] For this user            "
      printf "%s\n" "$ui_line_eq"
      read -rp "Select an option [ 1 - 2 ]: " target_opt
      case "$target_opt" in
        1|system) target="system" ;;
        2|user) target="user" ;;
        *) printf "%s\n" "No valid action indicated; exiting..."; exit 1 ;;
      esac
    fi

    if [[ "$target" == "system" ]]; then
      if [[ "$EUID" -ne 0 ]]; then
        printf "\n"
        printf "%s\n" "The system-wide installation copies files to protected system"
        printf "%s\n" "directories (like /usr/bin and /etc/bash_completion.d)."
        printf "%s\n" "Administrative privileges are required to complete these actions."
        printf "\n"
        printf "%s\n" "Please enter your sudo password to proceed."
        printf "\n"
        sudo "$0" install --autocomplete-only system
        exit $?
      fi
      if [[ "$unix_name" = "Darwin" ]] ; then
        install_autocomplete "/usr/local/etc/bash_completion.d"
      else
        install_autocomplete "/etc/bash_completion.d"
      fi
    else
      install_autocomplete "$HOME/.local/share/bash-completion/completions"
    fi
    exit 0
  fi

  printf "%s\n" "$ui_line_eq"
  printf "%s\n" "     Installation     "
  printf "%s\n" "$ui_line_eq"
  printf "%s\n" " [1] System-wide      "
  printf "%s\n" " [2] For this user    "
  printf "%s\n" " [3] Exit             "
  printf "%s\n" "$ui_line_eq"
  read -rp "Select an option and press Enter [ 1 - 3 ]: " installation
  case "$installation" in
    1|system)
      chmod 755 "$0"
      if _require_sudo "system-wide installation"; then
        if [[ "$unix_name" = "Darwin" ]] ; then
          cp "$0" /usr/local/bin/rescript
          install_autocomplete "/usr/local/etc/bash_completion.d"
        else
          cp "$0" /usr/bin/rescript
          install_autocomplete "/etc/bash_completion.d"
        fi
        printf "%s\n" "Installation successful!"
        printf "%s\n" "Run [rescript config] to configure your repository."
        exit
      else
        if [[ "$unix_name" = "Darwin" ]] ; then
          sudo cp "$0" /usr/local/bin/rescript
          sudo /usr/local/bin/rescript install --autocomplete-only system
        else
          sudo cp "$0" /usr/bin/rescript
          sudo /usr/bin/rescript install --autocomplete-only system
        fi
        
        printf "\n"
        printf "%s\n" "Installation successful!"
        printf "%s\n" "Run [rescript config] to configure your repository."
        exit
      fi
      ;;
    2|user)
      chmod 700 "$0"
      if [[ -d "$HOME/bin" ]] ; then
        cp "$0" "$HOME/bin/rescript"
        install_autocomplete "$HOME/.local/share/bash-completion/completions"
        printf "%s\n" "Installation successful!"
        printf "%s\n" "Run [rescript config] to configure your repository."
        exit
      elif [[ -d "$HOME/.local/bin" ]] ; then
        cp "$0" "$HOME/.local/bin/rescript"
        install_autocomplete "$HOME/.local/share/bash-completion/completions"
        printf "%s\n" "Installation successful!"
        printf "%s\n" "Run [rescript config] to configure your repository."
        exit
      else
        printf "%s\n" "There is no [$HOME/.local/bin] directory present."
        read -rp "Do you wish to create it now? y/n: " ans_install
        case $ans_install in
          y|yes)
            mkdir -p "$HOME/.local/bin"
            cp "$0" "$HOME/.local/bin/rescript"
            install_autocomplete "$HOME/.local/share/bash-completion/completions"
            printf "%s\n" "Installation successful!"
            printf "%s\n" "Run [rescript config] to configure your repository."
            printf "\n"
            printf "%s\n" "Remember to include $HOME/.local/bin in your PATH."
            exit
            ;;
          n|no)
            printf "%s\n" "Nothing done; exiting..."
            exit
            ;;
          *)
            printf "%s\n" "No valid action indicated; exiting..."
            exit
            ;;
        esac
      fi
      ;;
    3|exit) printf "%s\n" "Exiting..." ; exit ;;
    *) clear ; printf "%s\n" "No valid action indicated..." ; install ;;
  esac
}
