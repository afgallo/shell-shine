#!/bin/bash
set -e # Exit the script if any command fails

# ANSI Escape Codes for colors
RED='\033[0;31m'
NC='\033[0m' # No Color

function undo_changes {
	echo -e "${RED}An error occurred during the setup process. Reviewing changes...${NC}"

	# Check and notify about potential installations
	if [[ "$(uname)" == "Darwin" ]]; then
		if command -v brew &>/dev/null; then
			echo -e "${RED}- Homebrew might've been installed or altered. Consider removing or checking it manually.${NC}"
		fi
		if brew list --cask iterm2 &>/dev/null || [[ -d "/Applications/iTerm.app" ]]; then
			echo -e "${RED}- iTerm2 might've been installed or altered. Consider removing or checking it manually.${NC}"
		fi
	fi

	if command -v git &>/dev/null; then
		echo -e "${RED}- Git might've been installed or altered. Consider removing or checking it manually.${NC}"
	fi

	if [[ -d "$HOME/.oh-my-zsh" ]]; then
		echo -e "${RED}- Oh My Zsh might've been installed or altered. Consider removing or checking it manually.${NC}"
	fi

	if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
		echo -e "${RED}- Powerlevel10k theme might've been installed or altered. Consider removing or checking it manually.${NC}"
	fi

	if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
		echo -e "${RED}- zsh-autosuggestions plugin might've been installed or altered. Consider removing or checking it manually.${NC}"
	fi

	if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
		echo -e "${RED}- zsh-syntax-highlighting plugin might've been installed or altered. Consider removing or checking it manually.${NC}"
	fi

	# Check if Zsh was installed by this script
	if ! command -v zsh &>/dev/null; then
		echo -e "${RED}- Zsh is installed. Consider removing it if you encounter issues.${NC}"
	fi

	echo -e "${RED}Consider reviewing the aforementioned items and deciding on manual removal or adjustments.${NC}"
}

# Trap any errors and undo changes
trap 'undo_changes' ERR

# Go Home
pushd "$HOME"

# Greet the user
echo "Welcome to ShellShine! 🌟"
echo "Let's give your terminal the sparkle it deserves!"

# Create .ssh key
if [ ! -d ~/.ssh ]; then
	echo "Creating a new directory to hold ssh keys..."
	mkdir ~/.ssh
	chmod 700 .ssh
fi

if [ ! -f ~/.ssh/id_rsa ]; then
	echo "Creating a new ssh key..."
	ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_rsa -q -N ""
fi

# Add github.com and bitbucket.com keys to known hosts
echo "Adding github.com and bitbucket.org to known_hosts..."
ssh-keyscan github.com ~/.ssh/known_hosts
ssh-keyscan bitbucket.org ~/.ssh/known_hosts

# Determine if running macOS
if [[ "$(uname)" == "Darwin" ]]; then
	# Install Homebrew if not already present
	if ! command -v brew &>/dev/null; then
		echo "Homebrew is not installed. Installing now..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		# Add Homebrew's bin directory to the current PATH
		export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
		echo "Homebrew installed successfully."
	else
		echo "Homebrew is already installed."
	fi

	# Install iTerm2 if not already present
	if ! brew list --cask iterm2 &>/dev/null && [[ ! -d "/Applications/iTerm.app" ]]; then
		echo "Installing iTerm2..."
		brew install --cask iterm2
		echo "iTerm2 installed successfully. To continue this process, close this terminal and open iTerm2 now. Run the script again and it will resume from where you've left off."
		exit 0
	else
		echo "iTerm2 is already installed."
	fi
fi

# Determine if running Linux and install Homebrew
if [[ "$(uname)" == "Linux" ]]; then
	if ! command -v brew &>/dev/null; then
		curl https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash
		# Add Homebrew's bin directory to the current PATH
		export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
		echo "Homebrew installed successfully."
	else
		echo "Homebrew is already installed."
	fi
fi

echo "Installing dev tools..."
brew install curl awscli tmux jq fzf htop mongosh neovim python3 ruby sqlite tree terraform
echo "dev tools installed successfully."

# Install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
echo "nvm installed successfully."

# Check if Zsh is installed
if ! command -v zsh &>/dev/null; then
	echo "Installing Zsh..."
	brew install zsh
	echo "Zsh installed successfully."
else
	echo "Zsh is already installed."
fi

# Fetch necessary resources
echo "Fetching stardust... I mean, resources... ✨"

# Check if Oh My Zsh is installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	echo "Installing Oh My Zsh..."
	RUNZSH="no" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	echo "Oh My Zsh installed successfully."
else
	echo "Oh My Zsh is already installed."
fi

# Check and set ZSH_CUSTOM if not set
if [[ -z "$ZSH_CUSTOM" ]]; then
	ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
fi

# Check if powerlevel10k is installed
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
	echo "Installing powerlevel10k theme..."
	git clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
	echo "powerlevel10k theme installed successfully."
else
	echo "powerlevel10k theme is already installed."
fi

# Check if ZSH_THEME is set in ~/.zshrc
if grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
	echo "Updating ZSH_THEME to powerlevel10k in ~/.zshrc..."
	# Using sed to replace the ZSH_THEME value based on OS
	if [[ "$(uname)" == "Darwin" ]]; then
		sed -i '' 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
	else
		sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
	fi
	echo "ZSH_THEME updated to powerlevel10k in ~/.zshrc."
else
	echo "Setting powerlevel10k as the default theme in ~/.zshrc..."
	echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >>"$HOME/.zshrc"
	echo "powerlevel10k set as the default theme in ~/.zshrc."
fi

# Check if zsh-autosuggestions plugin is installed
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
	echo "Installing zsh-autosuggestions plugin..."
	git clone "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
	echo "zsh-autosuggestions plugin installed successfully."
else
	echo "zsh-autosuggestions plugin is already installed."
fi

# Check if zsh-syntax-highlighting plugin is installed
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
	echo "Installing zsh-syntax-highlighting plugin..."
	git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
	echo "zsh-syntax-highlighting plugin installed successfully."
else
	echo "zsh-syntax-highlighting plugin is already installed."
fi

# Check if plugins are loaded in ~/.zshrc
if ! grep -q "plugins=(.*zsh-autosuggestions.*" "$HOME/.zshrc"; then
	echo "Loading zsh-autosuggestions in ~/.zshrc..."
	# Using sed to replace the plugins array based on OS
	if [[ "$(uname)" == "Darwin" ]]; then
		sed -i '' 's/plugins=(/plugins=(zsh-autosuggestions /' "$HOME/.zshrc"
	else
		sed -i 's/plugins=(/plugins=(zsh-autosuggestions /' "$HOME/.zshrc"
	fi
	echo "zsh-autosuggestions loaded in ~/.zshrc."
fi

if ! grep -q "plugins=(.*zsh-syntax-highlighting.*" "$HOME/.zshrc"; then
	echo "Loading zsh-syntax-highlighting in ~/.zshrc..."
	# Using sed to replace the plugins array based on OS
	if [[ "$(uname)" == "Darwin" ]]; then
		sed -i '' 's/plugins=(/plugins=(zsh-syntax-highlighting /' "$HOME/.zshrc"
	else
		sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /' "$HOME/.zshrc"
	fi
	echo "zsh-syntax-highlighting loaded in ~/.zshrc."
fi

# Clean up sed backups if they exist
if [[ -f "$HOME/.zshrc.bak" ]]; then
	rm "$HOME/.zshrc.bak"
fi

# Install Starship prompt if not already present
if ! command -v starship &>/dev/null; then
	echo "Installing Starship prompt..."

	# Install using the provided script from Starship's website
	#	curl -sS https://starship.rs/install.sh | sh
	brew install starship
	echo "Starship prompt installed successfully."
else
	echo "Starship prompt is already installed."
fi

# Check if Starship is initialized in ~/.zshrc
if ! grep -q "eval \"\$(starship init zsh)\"" "$HOME/.zshrc"; then
	echo "Initializing Starship in ~/.zshrc..."
	echo -e "\n# Starship prompt configuration\neval \"\$(starship init zsh)\"" >>"$HOME/.zshrc"
else
	echo "Starship prompt is already initialized in ~/.zshrc."
fi

# Get dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
	git clone --bare git@github.com:afgallo/dotfiles.git "$HOME/.dotfiles"
	pushd ~/.dotfiles
	./bootstrap.sh
	popd
fi

echo "Your terminal is now shining bright like a diamond! 💎 Please restart your terminal or source your ~/.zshrc for the changes to take effect."
echo "Don't forget to customize your Powerlevel10k prompt by running 'p10k configure'."

# Exit with success
exit 0
