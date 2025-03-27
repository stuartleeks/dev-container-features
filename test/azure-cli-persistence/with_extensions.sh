#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "cache dir permission" bash -c "test -w /dc/azure"
check "check symlink" bash -c 'test $(readlink "$HOME/.azure") == "/dc/azure/"'

check "check cliextensions" bash -c 'test $(az extension list --output tsv --query "length(@)") -eq 2'

reportResults