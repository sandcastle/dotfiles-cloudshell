#!/bin/bash
set -e

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed. Please install git and try again." >&2
  exit 1
fi

# Is the repo local or remote?
if [ -f "$(pwd)/install.sh" ] && [ -d "$(pwd)/.git" ]; then
  SRC_DIR="$(pwd)/src"
else
  TMP_DIR=$(mktemp -d)
  git clone --depth=1 https://github.com/sandcastle/dotfiles-cloudshell.git "$TMP_DIR"
  SRC_DIR="$TMP_DIR/src"
fi

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
  # Collect all files (including hidden ones, but not . or ..)
  local items=()
  for item in "$SRC_DIR"/* "$SRC_DIR"/.[!.]* "$SRC_DIR"/..?*; do
    # Skip if the glob didn't match anything
    [ ! -e "$item" ] && continue
    items+=("$item")
  done
  if [ ${#items[@]} -eq 0 ]; then
    echo "Warning: No files found in $SRC_DIR to copy."
    return
  fi
  for item in "${items[@]}"; do
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
