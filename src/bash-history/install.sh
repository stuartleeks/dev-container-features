#!/bin/bash
set -e

echo "Activating feature 'bash-history'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"
printenv | sort

if [[ "$_REMOTE_USER" == "" || "$_REMOTE_USER_HOME" == "" ]]; then
  echo "***********************************************************************************"
  echo "*** Require _REMOTE_USER and _REMOTE_USER_HOME to be set (by dev container CLI) ***"
  echo "***********************************************************************************"
  exit 1
fi

echo "export HISTFILE=/dc/bashhistory/.bash_history" >> "$_REMOTE_USER_HOME/.bashrc" \
    && echo "export PROMPT_COMMAND='history -a'" >> "$_REMOTE_USER_HOME/.bashrc" \
    && echo "sudo chown -R $_REMOTE_USER /dc/bashhistory" >> "$_REMOTE_USER_HOME/.bashrc"
