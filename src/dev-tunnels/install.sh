#!/bin/sh
set -e

echo "Activating feature 'dev-tunnels'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

# Docs point to:
# curl -sL https://aka.ms/DevTunnelCliInstall | bash
# Run that as the remote user
su ${_REMOTE_USER} -c "curl -sL https://aka.ms/DevTunnelCliInstall | bash"



# NOTE for devcontainer-feature.json
# TODO - once devtunnel supports writing auth to HOME dir, set up a mount and symlink to persist login across dev container rebuilds
# "mounts": [
#     {
#         "source": "${devcontainerId}-devtunnels",
#         "target": "/dc/devtunnels",
#         "type": "volume"
#     }
# ]
