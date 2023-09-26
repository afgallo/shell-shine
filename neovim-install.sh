#!/bin/bash
set -e

echo "Installing Neovim using the AppImage..."

# Install FUSE first
sudo apt-get install fuse

# Download the AppImage
curl -Lo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage

# Make it executable
chmod u+x /tmp/nvim.appimage

# Move to a location in your PATH, for example, /usr/local/bin
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

echo "Neovim installation via AppImage complete!"
