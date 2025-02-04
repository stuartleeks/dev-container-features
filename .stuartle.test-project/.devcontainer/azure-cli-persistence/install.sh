#!/bin/sh
set -e

echo "Activating feature 'azure-cli-persistence'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

if [  -z "$_REMOTE_USER" ] || [ -z "$_REMOTE_USER_HOME" ]; then
  echo "***********************************************************************************"
  echo "*** Require _REMOTE_USER and _REMOTE_USER_HOME to be set (by dev container CLI) ***"
  echo "***********************************************************************************"
  exit 1
fi

echo "Here...."


if [ -e "$_REMOTE_USER_HOME/.azure" ]; then
  echo "Moving existing .azure folder to .azure-old"
  mv "$_REMOTE_USER_HOME/.azure" "$_REMOTE_USER_HOME/.azure-old"
fi

echo "Hi...."
ls -al "$_REMOTE_USER_HOME"
echo "Bye...."
ln -s /dc/azure/ "$_REMOTE_USER_HOME/.azure"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.azure"

# chown mount (only attached on startup)
cat << EOF >> "$_REMOTE_USER_HOME/.bashrc"
sudo chown -R "${_REMOTE_USER}:${_REMOTE_USER}" /dc/azure
EOF
chown -R $_REMOTE_USER $_REMOTE_USER_HOME/.bashrc
