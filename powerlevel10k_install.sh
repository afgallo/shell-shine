#!/bin/bash
set -e

# Check if powerlevel10k is desired and not already installed
read -p "Do you want to install powerlevel10k? (y/n) " install_p10k
if [[ $install_p10k == "y" ]] && [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
	echo "Installing powerlevel10k..."

	# Clone the repository
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

	# Set ZSH_THEME to powerlevel10k
	sed -i.bak 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

	echo "Powerlevel10k installed and set as the default theme."
else
	echo "Powerlevel10k installation skipped or already installed."
fi
