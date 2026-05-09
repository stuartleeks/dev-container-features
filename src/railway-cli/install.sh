#!/bin/sh
FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/railway-cli"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

set -e

mkdir -p "${FEATURE_DIR}"

echo "" > "$LOG_FILE"
log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'railway-cli'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

# Set up symlink for .railway folder to persistent volume
got_old_railway_folder=false
if [ -e "$_REMOTE_USER_HOME/.railway" ]; then
  log "Moving existing .railway folder to .railway-old"
  mv "$_REMOTE_USER_HOME/.railway" "$_REMOTE_USER_HOME/.railway-old"
  got_old_railway_folder=true
else
  log "No existing .railway folder found at '$_REMOTE_USER_HOME/.railway'"
fi

ln -s /dc/railway-cli/ "$_REMOTE_USER_HOME/.railway"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.railway"
log "Symlink created for .railway folder to /dc/railway-cli/"

# Defer installation to oncreate script
# This allows fixing up the /dc/railway-cli/ folder permissions before the CLI is installed and creates files in that folder
mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"

