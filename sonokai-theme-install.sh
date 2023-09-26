#!/bin/bash

set -e

echo "Installing Sonokai theme..."

# Step 1: Clone the repository
git clone --depth 1 https://github.com/sainnhe/sonokai.git

# Define the path
SONOKAI_PATH="$(pwd)/sonokai"

# Check if .vim directory exists, if not, create it
mkdir -p ~/.vim/autoload ~/.vim/colors ~/.nvim/doc

# Step 2: Copy autoload vim file
cp "${SONOKAI_PATH}/autoload/sonokai.vim" ~/.nvim/autoload/

# Step 3: Copy colors vim file
cp "${SONOKAI_PATH}/colors/sonokai.vim" ~/.nvim/colors/

# Step 4: Copy doc file and generate help tags
cp "${SONOKAI_PATH}/doc/sonokai.txt" ~/.nvim/doc/
vim -E -c "helptags ~/.nvim/doc/" -c "q"

# Step 5: Install airline theme
mkdir -p ~/.vim/autoload/airline/themes
cp "${SONOKAI_PATH}/autoload/airline/themes/sonokai.vim" ~/.nvim/autoload/airline/themes/

# Step 6: Install lightline theme
mkdir -p ~/.vim/autoload/lightline/colorscheme
cp "${SONOKAI_PATH}/autoload/lightline/colorscheme/sonokai.vim" ~/.nvim/autoload/lightline/colorscheme/

# Step 7: Install lualine theme
mkdir -p ~/.config/nvim/lua/lualine/themes
cp "${SONOKAI_PATH}/lua/lualine/themes/sonokai.lua" ~/.config/nvim/lua/lualine/themes/

# Cleanup
rm -rf sonokai

echo "Sonokai theme installed successfully!"
