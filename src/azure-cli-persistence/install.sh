#!/bin/sh

LIFECYCLE_SCRIPTS_DIR="/usr/local/share/stuartleeks-devcontainer-features/azure-cli-persistence/scripts"

set -e

echo "Activating feature 'azure-cli-persistence'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

if [ -e "$_REMOTE_USER_HOME/.azure" ]; then
  echo "Moving existing .azure folder to .azure-old"
  mv "$_REMOTE_USER_HOME/.azure" "$_REMOTE_USER_HOME/.azure-old"
fi

ln -s /dc/azure/ "$_REMOTE_USER_HOME/.azure"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.azure"

# Set Lifecycle scripts
if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi
