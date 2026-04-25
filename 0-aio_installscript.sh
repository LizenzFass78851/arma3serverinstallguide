#!/bin/bash

set -e

download_source_repo="github.com/LizenzFass78851/arma3serverinstallguide"
download_source_path="raw/refs/heads/main/files"

echo "Arma 3 Server Installation Script"
echo "---------------------------------"
echo "This script will install Arma 3 server on your system."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Unsupported OS"
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
if [[ "$OS" == "ubuntu" ]]; then
  sudo apt update
  # Check if steamcmd is installed
  if ! command -v steamcmd &> /dev/null; then
  echo "steamcmd not found. Installing steamcmd..."
    sudo add-apt-repository multiverse
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y steamcmd
  else
    echo "steamcmd is already installed."
  fi
  sudo apt install -y net-tools rename
elif [[ "$OS" == "debian" ]]; then
  sudo apt update
  # Check if steamcmd is installed
  if ! command -v steamcmd &> /dev/null; then
  echo "steamcmd not found. Installing steamcmd..."
    sudo apt install -y software-properties-common
    sudo apt-add-repository non-free
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y steamcmd
  else
    echo "steamcmd is already installed."
  fi
  sudo apt install -y net-tools rename
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# Fix PATH for steamcmd
if ! grep -qxF 'export PATH=$PATH:/usr/games' ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/games' >> ~/.bashrc
  source ~/.bashrc
fi

# Create Arma 3 folder
echo "Creating Arma 3 folder..."
if [ ! -d /srv/steamlibrary/steamapps/common/arma3 ]; then
  mkdir -p /srv/steamlibrary/steamapps/common/arma3
fi

# Prompt for Steam login credentials
echo "Please enter your Steam login credentials."
read -p "Steam Username: " steamcmd_username
read -s -p "Steam Password: " steamcmd_password
echo
if [ -z "$steamcmd_username" ] || [ -z "$steamcmd_password" ]; then
  echo "Error: SteamCMD user and password are required."
  exit 1
fi

# Run steamcmd to install Arma 3 server
echo "Installing Arma 3 server via steamcmd..."
if ! command -v steamcmd &> /dev/null; then
  echo "Please rerun the script to use the proper PATH for steamcmd."
  echo "If this problem persists, run the following command: source ~/.bashrc"
  echo "and start this script again."
  exit 1
fi
steamcmd +force_install_dir /srv/steamlibrary/steamapps/common/arma3 \
  +login ${steamcmd_username} ${steamcmd_password} +app_update 233780 validate +quit || \
  { echo "Error: Failed to install Arma 3 server."; exit 1; }
unset steamcmd_username steamcmd_password

# Download server.cfg
if [ ! -f /srv/steamlibrary/steamapps/common/arma3/server.cfg ]; then
  echo "Downloading server.cfg..."
  wget https://${download_source_repo}/${download_source_path}/server.cfg \
  -O /srv/steamlibrary/steamapps/common/arma3/server.cfg
fi

# Download arma3.sh
if [ ! -f /srv/steamlibrary/steamapps/common/arma3/arma3.sh ]; then
  echo "Downloading arma3.sh..."
  wget https://${download_source_repo}/${download_source_path}/arma3.sh \
  -O /srv/steamlibrary/steamapps/common/arma3/arma3.sh
  chmod +x /srv/steamlibrary/steamapps/common/arma3/arma3.sh
fi

# Install arma3server.service
if [ ! -f /etc/systemd/system/arma3server.service ]; then
  echo "Installing arma3server.service..."
  wget https://${download_source_repo}/${download_source_path}/arma3server.service \
  -O /etc/systemd/system/arma3server.service
  echo "Enabling and starting Arma 3 server..."
  systemctl enable --now arma3server
elif [ "$(systemctl is-active arma3server)" == "active" ]; then
  echo "Arma 3 server is already running."
else
  echo "Starting Arma 3 server..."
  systemctl start arma3server
fi

echo "Installation complete. Use 'systemctl status arma3server' to check the server status."
