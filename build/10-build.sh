#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Prepare ujust Files"

# Ensure custom just destination exists. Base image provides standard ujust files.
mkdir -p /usr/share/ublue-os/just/

# Recreate custom just file on each build so content is deterministic.
: > /usr/share/ublue-os/just/60-custom.just

echo "::endgroup::"

echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Ensure custom just file is imported by ujust entrypoint.
if [[ -f /usr/share/ublue-os/just/00-entry.just ]]; then
    if ! grep -q '60-custom\.just' /usr/share/ublue-os/just/00-entry.just; then
        printf '\nimport "60-custom.just"\n' >> /usr/share/ublue-os/just/00-entry.just
    fi
else
    cat > /usr/share/ublue-os/just/00-entry.just << 'EOF'
import "60-custom.just"
EOF
fi

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
# Example: dnf5 install -y tmux

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket
# Example: systemctl mask unwanted-service

echo "::endgroup::"

echo "::group:: Apply flourite Branding"

if [[ -f /usr/lib/os-release ]]; then
    sed -i \
        -e 's/^NAME=.*/NAME="flourite"/' \
        -e 's/^ID=.*/ID=flourite/' \
        -e 's/^PRETTY_NAME=.*/PRETTY_NAME="flourite"/' \
        -e 's/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=flourite/' \
        /usr/lib/os-release
fi

echo "::endgroup::"

echo "::group:: Run Additional Build Scripts"

for script in "$@"; do
    if [[ ! -x "$script" ]]; then
        echo "Skipping non-executable script: $script"
        continue
    fi

    echo "Running: $script"
    "$script"
done

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
