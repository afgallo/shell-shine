#!/bin/bash
set -e

echo "Starting Docker installation..."

# Check if a username was passed in
if [ -z "$1" ]; then
    echo "Error: Please provide a username as an argument."
    exit 1
fi

# Remove any previous Docker versions or related packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg
done

# Update and install required packages
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Set up Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker's official repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the user to the docker group to avoid using 'sudo' with Docker commands
if [ -z "$(getent group docker)" ]; then
    sudo groupadd docker
fi

sudo usermod -aG docker $USERNAME

echo "Docker installation complete for user $USERNAME!"
echo "To avoid using 'sudo' with Docker commands, either log out and log back in or execute the 'newgrp docker' command."
