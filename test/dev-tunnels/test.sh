#!/bin/bash
set -e

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'color' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "color": {}
#    },
#    "remoteUser": "root"
# }
#
# Thus, the value of all options will fall back to the default value in the
# Feature's 'devcontainer-feature.json'.
# For the 'color' feature, that means the default favorite color is 'red'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    devcontainer features test    \ 
#               --features color   \
#               --remote-user root \
#               --skip-scenarios   \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#               /path/to/this/repo


# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# NOTE: currently have to run the test using zsh as the devtunnel install script only adds the PATH to the first shell config it finds
#       and when running as root in the dev container base image used for testing, that is .zshrc
# check "Check devtunnel is installed" zsh --interactive -c "devtunnel --version" | grep 'Tunnel CLI'

devtunnel --version

check "Check devtunnel is installed" bash -c "devtunnel --version" | grep 'Tunnel CLI'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
