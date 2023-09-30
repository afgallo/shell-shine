#!/bin/bash
set -e

echo "Welcome to ShellShine! 🌟"

# Ask user for a desired username
read -p "Enter the desired username so we don't run as sudo (default: afgallo): " USERNAME
USERNAME=${USERNAME:-afgallo}

# 1. Create a new user if it doesn't exist (so we don't use sudo)
if ! id "$USERNAME" &>/dev/null; then
	echo "User '$USERNAME' doesn't exist. Creating now..."
	sudo adduser $USERNAME
	sudo usermod -aG sudo $USERNAME

	# Copy the shell-shine.sh script to the user's home directory and set correct permissions
	sudo cp -a "$HOME/shell-shine/." "/home/$USERNAME/shell-shine/"
	sudo chown $USERNAME:$USERNAME "/home/$USERNAME/shell-shine/shell-shine.sh"
	sudo chmod +x "/home/$USERNAME/shell-shine/shell-shine.sh"

	echo "Switch now to user '$USERNAME'. Once you are the '$USERNAME' user, you can re-run this script to continue the setup."
	exit 0
else
	echo "User '$USERNAME' already exists. Continuing ..."
fi

# 2. Update and upgrade the system
sudo apt update && sudo apt upgrade -y
sudo apt-get install build-essential unzip python3 python3-pip ruby-full -y

# 3. Install and configure packages

# Install zsh
if ! command -v zsh &>/dev/null; then
	echo "Installing zsh..."
	sudo apt install -y zsh
else
	echo "Zsh is already installed."
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "Oh My Zsh is already installed."
fi

# Install oh-my-zsh plugins
if [ -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing Oh My Zsh plugins..."
	# Install zsh-autosuggestions
	if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	fi

	# Install zsh-syntax-highlighting
	if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
	fi
else
	echo "oh-my-zsh is not installed. Skipping plugin installation."
fi

# Install Starship
#if ! command -v starship &>/dev/null; then
#	echo "Installing starship..."
#	curl -sS https://starship.rs/install.sh | sh
#else
#	echo "Starship is already installed."
#fi

# Install powerlevel10k (optional)
./powerlevel10k_install.sh

# Initialize starship for zsh (you might want to add this in the zsh section)
# This checks if the init command is already present in .zshrc, if not, it appends it.
if ! grep -q "eval \"\$(starship init zsh)\"" ~/.zshrc; then
	echo 'eval "$(starship init zsh)"' >>~/.zshrc
fi

# Install git
if ! command -v git &>/dev/null; then
	echo "Installing git..."
	sudo apt install -y git
else
	echo "Git is already installed."
fi

# Install tmux
if ! command -v tmux &>/dev/null; then
	echo "Installing tmux..."
	sudo apt install -y tmux
else
	echo "Tmux is already installed."
fi

# Install neovim
if ! command -v nvim &>/dev/null; then
	echo "Installing neovim..."
	./neovim-install.sh
else
	echo "Neovim is already installed."
fi

# Install Docker
if ! command -v docker &>/dev/null; then
	echo "Installing Docker from official repositories..."
	./docker-install.sh $USERNAME
else
	echo "Docker is already installed."
fi

# Install Dotnet
if ! command -v dotnet &>/dev/null; then
	echo "Installing dotnet..."
	sudo apt-get install -y dotnet-sdk-7.0
	echo "dotnet installed successfully."
else
	echo "dotnet is already installed."
fi

# Install nvm
if [ ! -d "$NVM_DIR" ]; then
	echo "Installing nvm..."
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
	echo "Nvm is already installed."
fi

# 4. Setup Astronvim
# Replace the below path with the actual path if different
if [ ! -d "$HOME/.config/nvim/lua/user" ]; then
	echo "Setting up Astronvim..."
	git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
	git clone git@github.com:afgallo/astronvim_config.git ~/.config/nvim/lua/user
else
	echo "Astronvim is already set up."
fi

# 5. Install sonokai theme
# Sonokai Theme Installation
SONOKAI_DIR="$HOME/.vim/colors"
if [ ! -f "${SONOKAI_DIR}/sonokai.vim" ]; then
	./sonokai-theme-install.sh
else
	echo "Sonokai theme is already installed."
fi

sudo timedatectl set-timezone Australia/NSW

echo "ShellShine setup complete! Enjoy! 🚀"
