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
  echo "  Select Text Editor  "
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
  read -rp "Select the Text Editor you want to use [ 1 - 9 ]: " texteditor
  case "$texteditor" in
    1|nano) echo "nano" > "$config_dir/.editor"; echo "You have selected [Nano] as your default text editor." ;;
    2|vim) echo "vim" > "$config_dir/.editor"; echo "You have selected [Vim] as your default text editor." ;;
    3|gedit) echo "gedit" > "$config_dir/.editor" ; echo "You have selected [Gedit] as your default text editor." ;;
    4|mousepad) echo "mousepad" > "$config_dir/.editor" ; echo "You have selected [Mousepad] as your default text editor." ;;
    5|leafpad) echo "leafpad" > "$config_dir/.editor" ; echo "You have selected [Leafpad] as your default text editor." ;;
    6|pluma) echo "pluma" > "$config_dir/.editor" ; echo "You have selected [Pluma] as your default text editor." ;;
    7|kate) echo "kate" > "$config_dir/.editor" ; echo "You have selected [Kate] as your default text editor." ;;
    8|xed) echo "xed" > "$config_dir/.editor" ; echo "You have selected [Xed] as your default text editor." ;;
    9|other) read -rp "Type the executable name of the Text Editor you want to use: " othertextedit ; echo "$othertextedit" > "$config_dir/.editor" ; echo "You have selected [$othertextedit] as your default text editor." ;;
    10|exit) echo "Exiting..." ; exit ;;
    *) echo "[$texteditor] is not a valid option. If you want to set your" ; echo "own text editor, type [9] or [other] to write your own." ; exit ;;
  esac
}
