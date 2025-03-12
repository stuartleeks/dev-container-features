#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/hugo.md
# Maintainer: The VS Code and Codespaces Teams

set -e

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
echo "Done!"

