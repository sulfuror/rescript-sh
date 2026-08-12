# ============================================================== #
#                        COMMAND: EDITOR                         #
# ============================================================== #

rescript_editor_cmd() {
  select_editor
}

# Select Editor Menu
select_editor() {
  clear
  printf "%s\n" "$ui_line_eq"
  printf "%s\n" "  Select Default Editor "
  printf "%s\n" "$ui_line_eq"
  printf "%s\n" " [1] Nano             "
  printf "%s\n" " [2] Vim              "
  printf "%s\n" " [3] Gedit            "
  printf "%s\n" " [4] Mousepad         "
  printf "%s\n" " [5] Leafpad          "
  printf "%s\n" " [6] Pluma            "
  printf "%s\n" " [7] Kate             "
  printf "%s\n" " [8] Xed              "  
  printf "%s\n" " [9] Other            "
  printf "%s\n" " [10] Exit            "
  printf "%s\n" "$ui_line_eq"
  local texteditor
  read -rp "Select an option [ 1 - 10 ]: " texteditor
  
  local chosen=""
  case "$texteditor" in
    1|nano) chosen="nano" ;;
    2|vim) chosen="vim" ;;
    3|gedit) chosen="gedit" ;;
    4|mousepad) chosen="mousepad" ;;
    5|leafpad) chosen="leafpad" ;;
    6|pluma) chosen="pluma" ;;
    7|kate) chosen="kate" ;;
    8|xed) chosen="xed" ;;
    9|other) 
      read -rp "Type the executable name of the Text Editor you want to use: " chosen 
      ;;
    10|exit) printf "%s\n" "Exiting..." ; exit 0 ;;
    *) printf "%s\n" "[$texteditor] is not a valid option." ; exit 1 ;;
  esac

  if command -v "$chosen" >/dev/null 2>&1 ; then
    if [[ ! -f "$config_global" ]]; then
      global_config_template > "$config_global"
      chmod 600 "$config_global"
    fi
    grep -v "^RESCRIPT_EDITOR=" "$config_global" > "${config_global}.tmp" 2>/dev/null || true
    printf "%s\n" "RESCRIPT_EDITOR=\"$chosen\"" >> "${config_global}.tmp"
    mv "${config_global}.tmp" "$config_global"
    
    # Just in case they had a rogue legacy file
    rm -f "$config_dir/.editor" 2>/dev/null || true
    printf "%s\n" "You have selected [$chosen] as your default text editor."
  else
    printf "%s\n" "Error: The editor [$chosen] is not installed or not found in your PATH."
    printf "%s\n" "Please install it first or select a different one."
    exit 1
  fi
}
