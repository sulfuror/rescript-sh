#!/usr/bin/env bash
# Script to compile rescript from the modules in src/

echo "Compiling rescript..."
cat src/01_globals.sh src/02_utils.sh src/templates/*.sh src/03_help.sh src/commands/*.sh src/04_core.sh src/05_main.sh > rescript
chmod +x rescript
echo "Compilation successful!"
