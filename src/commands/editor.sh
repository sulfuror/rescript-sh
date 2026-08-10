# ============================================================== #
#                        COMMAND: EDITOR                         #
# ============================================================== #

function rescript_editor_cmd {
  select_editor
}

# Select Editor Menu
function select_editor {
  clear
  echo "$ui_line_eq"
  echo "  Select Default Editor "
  echo "$ui_line_eq"
  echo " [1] Nano             "
  echo " [2] Vim              "
  echo " [3] Gedit            "
  echo " [4] Mousepad         "
  echo " [5] Leafpad          "
  echo " [6] Pluma            "
  echo " [7] Kate             "
  echo " [8] Xed              "  
  echo " [9] Other            "
  echo " [10] Exit            "
  echo "$ui_line_eq"
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
    10|exit) echo "Exiting..." ; exit 0 ;;
    *) echo "[$texteditor] is not a valid option." ; exit 1 ;;
  esac

  if command -v "$chosen" >/dev/null 2>&1 ; then
    echo "$chosen" > "$config_dir/.editor"
    echo "You have selected [$chosen] as your default text editor."
  else
    echo "Error: The editor [$chosen] is not installed or not found in your PATH."
    echo "Please install it first or select a different one."
    exit 1
  fi
}
