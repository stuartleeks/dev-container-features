#!/bin/sh

set -e

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/powerapps-cli"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

mkdir -p "$LIFECYCLE_SCRIPTS_DIR"

echo "" > "$LOG_FILE"
log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'powerapps-cli'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

log "Installing Power Platform CLI..."
dotnet tool install Microsoft.PowerApps.CLI.Tool --tool-path "$FEATURE_DIR/bin"
ln -s "$FEATURE_DIR/bin/pac" /usr/local/bin/pac
log "Power Platform CLI installed"

cp oncreate.sh "$LIFECYCLE_SCRIPTS_DIR/oncreate.sh"
chmod +x "$LIFECYCLE_SCRIPTS_DIR/oncreate.sh"
