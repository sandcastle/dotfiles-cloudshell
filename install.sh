#!/bin/bash
set -e

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

# Function to backup existing files
backup_file() {
  local target="$1"
  if [ -e "$target" ]; then
    mv "$target" "$target.bak.$(date +%s)"
    echo "Backed up $target to $target.bak.$(date +%s)"
  fi
}

# Copy files and directories from src to home
copy_dotfiles() {
  for item in "$SRC_DIR"/*; do
    base_item="$(basename "$item")"
    target="$HOME/$base_item"
    if [ -d "$item" ]; then
      # If it's a directory, copy recursively
      if [ -e "$target" ]; then
        backup_file "$target"
      fi
      cp -r "$item" "$target"
      echo "Copied directory $base_item to $target"
    else
      # If it's a file, copy and backup if needed
      if [ -e "$target" ]; then
        backup_file "$target"
      fi
      cp "$item" "$target"
      echo "Copied file $base_item to $target"
    fi
  done
}

# Main
copy_dotfiles

echo
echo "Dotfiles installed!"
echo
echo "Reloading shell"

exec zsh
