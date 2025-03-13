#!/usr/bin/env bash

set -e

LIFECYCLE_SCRIPTS_DIR="/usr/local/share/stuartleeks-devcontainer-features/add-host/scripts"

if [[ -z $HOST_IP ]];
then
    echo "HOST_IP is not set. Exiting..."
    exit 1
fi
HOST_NAME=${HOST_NAME:-"host.docker.internal"}


echo "Adding $HOST_NAME to /etc/hosts_temp pointing to $HOST_IP..."
if [[ $(command -v sudo > /dev/null; echo $?) == 0 ]]; then
    echo "$HOST_IP $HOST_NAME" | sudo tee -a /etc/hosts_temp > /dev/null
else
    echo "$HOST_IP $HOST_NAME" >> /etc/hosts_temp
fi

mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
cp poststart.sh "${LIFECYCLE_SCRIPTS_DIR}/poststart.sh"
echo "Done!"
