#!/bin/bash
set -e

# Install FUSE first
sudo apt-get install fuse -y

# Download the AppImage
curl -Lo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage

# Make it executable
chmod u+x /tmp/nvim.appimage

# Move to a location in your PATH, for example, /usr/local/bin
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
