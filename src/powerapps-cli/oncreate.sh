#!/usr/bin/env bash

set -e

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/powerapps-cli"
LOG_FILE="$FEATURE_DIR/log.txt"
PERSISTENCE_DIR="/dc/powerapps-cli"

log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

if command -v sudo > /dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi

$SUDO chown "$(id -u):$(id -g)" "$LOG_FILE"
log "In OnCreate script"

$SUDO mkdir -p "$PERSISTENCE_DIR/data" "$PERSISTENCE_DIR/config"
$SUDO chown -R "$(id -u):$(id -g)" "$PERSISTENCE_DIR"
chmod 700 "$PERSISTENCE_DIR" "$PERSISTENCE_DIR/data" "$PERSISTENCE_DIR/config"

persist_directory() {
  local source_dir="$1"
  local target_dir="$2"
  local backup_dir="${source_dir}-old"

  if [ -L "$source_dir" ] && [ "$(readlink "$source_dir")" = "$target_dir" ]; then
    log "'$source_dir' is already persisted"
    return
  fi

  mkdir -p "$(dirname "$source_dir")"
  if [ -e "$source_dir" ] || [ -L "$source_dir" ]; then
    if [ -e "$backup_dir" ] || [ -L "$backup_dir" ]; then
      log "Cannot back up '$source_dir': '$backup_dir' already exists"
      exit 1
    fi
    log "Moving '$source_dir' to '$backup_dir'"
    mv "$source_dir" "$backup_dir"
  fi

  if [ -d "$backup_dir" ]; then
    # Keep persisted credentials when the rebuilt image also contains configuration.
    cp -an "$backup_dir/." "$target_dir/"
  fi
  chmod 700 "$target_dir"
  ln -s "$target_dir" "$source_dir"
  log "Persisting '$source_dir' in '$target_dir'"
}

persist_directory "$HOME/.local/share/Microsoft/PowerAppsCli" "$PERSISTENCE_DIR/data"
persist_directory "$HOME/.config/Microsoft/PowerAppsCli" "$PERSISTENCE_DIR/config"

log "Done"
