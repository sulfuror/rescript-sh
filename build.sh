#!/usr/bin/env bash
# Script to compile rescript v5.1 from the modules in src/

echo "Compiling rescript..."
cat src/01_globals.sh src/02_utils.sh src/03_config.sh src/04_install.sh src/05_help.sh src/06_core.sh src/07_commands.sh src/08_main.sh > rescript.new
chmod +x rescript.new
mv rescript.new rescript
echo "Compilation successful!"
