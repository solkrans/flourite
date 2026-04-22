#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Erlang Build Dependencies for asdf-erlang
###############################################################################
# Installs the required Fedora/CentOS-style build dependencies listed by the
# asdf-erlang plugin so Erlang can be built successfully via asdf.
###############################################################################

echo "::group:: Install Erlang asdf Build Dependencies"

dnf5 install -y \
    git \
    unzip \
    gcc \
    gcc-c++ \
    automake \
    autoconf \
    ncurses-devel \
    openssl-devel \
    java-21-openjdk-devel \
    libiodbc \
    unixODBC-devel \
    erlang-odbc \
    libxslt \
    fop \
    inotify-tools

# Bazzite excludes mesa-libGLU-devel by default; disable excludes so wx deps resolve.
dnf5 --setopt=disable_excludes=* install -y \
    mesa-libGLU-devel \
    wxGTK-devel \
    wxBase

echo "::endgroup::"
