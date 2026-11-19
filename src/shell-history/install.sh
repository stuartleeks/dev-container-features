#!/bin/sh

LIFECYCLE_SCRIPTS_DIR="/usr/local/share/stuartleeks-devcontainer-features/shell-history/scripts"

set -e

echo "Activating feature 'shell-history'"

# Set Lifecycle script
if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi
