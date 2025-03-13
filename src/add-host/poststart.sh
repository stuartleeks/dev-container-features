#!/usr/bin/env bash

set -e


echo "Activating feature 'add-host'"
echo "User: $(id -un)"
echo "User home: $HOME"

# Parse "HOST_IP HOST_NAME" from /etc/hosts_temp
if [[ -f /etc/hosts_temp ]]; then
    while read -r line; do
        if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            HOST_IP=$(echo "$line" | awk '{print $1}')
            HOST_NAME=$(echo "$line" | awk '{print $2}')
            break
        fi
    done < /etc/hosts_temp
else
    echo "No /etc/hosts_temp file found. Exiting..."
    exit 1
fi

echo "HOST_IP: $HOST_IP"
echo "HOST_NAME: $HOST_NAME"

if [[ $(command -v sudo > /dev/null; echo $?) == 0 ]]; then
    have_sudo=true
else
    have_sudo=false
fi

# backup hosts file
if [[ $have_sudo == true ]]; then
    sudo cp /etc/hosts /etc/hosts_old
else
    cp /etc/hosts /etc/hosts_old
fi

# remove old entry
cat /etc/hosts_old | sed "/$HOST_NAME\$/d" > /tmp/hosts
# add new entry
cat /etc/hosts_temp | tee -a /tmp/hosts > /dev/null

# copy temp hosts file to /etc/hosts
if [[ $have_sudo == true ]]; then
    sudo cp /tmp/hosts /etc/hosts
else
    cp /tmp/hosts /etc/hosts
fi