#!/usr/bin/env bash

set -e


FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/railway-cli"
LOG_FILE="$FEATURE_DIR/log.txt"

log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

if command -v sudo > /dev/null; then
  sudo chown -R "$(id -u):$(id -g)" "$LOG_FILE"
else
  chown -R "$(id -u):$(id -g)" "$LOG_FILE"
fi

log "In OnCreate script"


fix_permissions() {
    local dir
    dir="${1}"

    if [ ! -w "${dir}" ]; then
        log "Fixing permissions of '${dir}'..."
        sudo chown -R "$(id -u):$(id -g)" "${dir}"
        log "Done!"
    else
        log "Permissions of '${dir}' are OK!"
    fi
}

fix_permissions "/dc/railway-cli"

# Docs: https://docs.railway.com/cli
# Run the install as the remote user
log "Installing railway CLI and agents"
bash <(curl -fsSL railway.com/install.sh) --agents -y

# Set up bash completion for the railway CLI
log "Setting up bash completion for railway CLI"
echo 'source <(railway completion bash)' >> ~/.bashrc


# TODO
# - Add option for installing the CLI without agents
# - Add option for disabling telemetry

log "Done"

