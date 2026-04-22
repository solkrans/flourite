#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Rust Toolchain
###############################################################################
# Installs Rust compiler and Cargo package manager for development use.
###############################################################################

echo "::group:: Install Rust Toolchain"

dnf5 install -y \
    rust \
    cargo

echo "::endgroup::"
