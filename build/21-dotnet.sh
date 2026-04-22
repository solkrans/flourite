#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Dotnet SDK
###############################################################################
# Installs dotnet SDK for development use in the image.
###############################################################################

echo "::group:: Install dotnet SDK"

dnf5 install -y dotnet-sdk-10.0

echo "::endgroup::"
