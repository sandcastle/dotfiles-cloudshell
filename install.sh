#!/bin/bash
set -e

# Parse flags
VERBOSE=0
QUIET=0
for arg in "$@"; do
  case $arg in
  --verbose)
    VERBOSE=1
    ;;
  --quiet)
    QUIET=1
    ;;
  esac
done

# Logging functions
log() {
  if [ "$QUIET" -eq 0 ]; then
    echo "$@"
  fi
}
vlog() {
  if [ "$VERBOSE" -eq 1 ] && [ "$QUIET" -eq 0 ]; then
    echo "$@"
  fi
}

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
  log "Error: git is not installed. Please install git and try again." >&2
  exit 1
fi

BACKUP_DIR="$HOME/.backup/$(date +%s)"
mkdir -p "$BACKUP_DIR"

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
    mkdir -p "$(dirname "$BACKUP_DIR/$target")"
    mv "$target" "$BACKUP_DIR/$target"
    vlog " → Backed up $BACKUP_DIR/$target"
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
    log "Warning: No files found in $SRC_DIR to copy."
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
      vlog "Copied directory $base_item to $target"
    else
      # If it's a file, copy and backup if needed
      if [ -e "$target" ]; then
        backup_file "$target"
      fi
      cp "$item" "$target"
      vlog "Copied file $base_item to $target"
    fi
  done
}

# Main
copy_dotfiles

log
log "Dotfiles installed!"
log
log "Reloading shell"

exec zsh -l

log
log "Customizing environment"

zsh $HOME/.customize_environment --force

log
log "All done"
