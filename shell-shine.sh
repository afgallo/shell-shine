#!/bin/bash
set -e # Exit the script if any command fails

# ANSI Escape Codes for colors
RED='\033[0;31m'
NC='\033[0m' # No Color

function undo_changes {
	echo -e "${RED}An error occurred during the setup process...${NC}"
	echo -e "${RED}Consider reviewing the changes made by the script and deciding on manual removal or adjustments.${NC}"
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

# Add github.com and bitbucket.com keys to known hosts
echo "Adding github.com and bitbucket.org to known_hosts..."
ssh-keyscan github.com ~/.ssh/known_hosts
ssh-keyscan bitbucket.org ~/.ssh/known_hosts

# Check if Homebrew is installed, if not install it.
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."

	# Install dependencies for Homebrew
	sudo apt-get update
	sudo apt-get install -y build-essential curl file git

	# Install Homebrew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Ensure Homebrew is added to the PATH for the current session and future sessions
	echo eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >>~/.profile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

	echo "Homebrew installed successfully."
else
	echo "Homebrew is already installed."
fi

echo "Installing dev tools..."
brew install awscli tmux jq fzf htop mongosh neovim python3 ruby sqlite tree terraform
echo "dev tools installed successfully."

# Install nvm using brew
brew install nvm
# Initialize nvm and add to PATH for the current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
# Install Node LTS
nvm install --lts

# Check if Zsh is installed
if ! command -v zsh &>/dev/null; then
	echo "Installing Zsh..."
	brew install zsh
	echo "Zsh installed successfully."
else
	echo "Zsh is already installed."
fi

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

# Install Starship prompt if not already present
if ! command -v starship &>/dev/null; then
	echo "Installing Starship prompt..."
	brew install starship
	echo "Starship prompt installed successfully."
else
	echo "Starship prompt is already installed."
fi

# Get dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
	curl https://raw.githubusercontent.com/afgallo/dotfiles/main/bootstrap.sh | bash -s
fi

# Create a new ssh key for convenience
if [ ! -f ~/.ssh/id_rsa ]; then
	echo "Creating a new ssh key..."
	ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_rsa -q -N ""
fi

echo "Your terminal is now shining bright like a diamond! 💎 Please restart your terminal or source your ~/.zshrc for the changes to take effect."

# Exit with success
popd
exit 0
