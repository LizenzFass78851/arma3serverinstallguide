#!/bin/bash

set -e

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
grep -qxF 'export PATH=$PATH:/usr/games' ~/.bashrc || \
  echo 'export PATH=$PATH:/usr/games' >> ~/.bashrc && \
  source ~/.bashrc

# Create Arma 3 folder
echo "Creating Arma 3 folder..."
if [ ! -x /srv/steamlibrary/steamapps/common/arma3 ] && \
  mkdir -p /srv/steamlibrary/steamapps/common/arma3

# Prompt for Steam login credentials
echo "Please enter your Steam login credentials."
read -p "Steam Username: " steam_username
read -s -p "Steam Password: " steam_password
echo

# Run steamcmd to install Arma 3 server
echo "Installing Arma 3 server via steamcmd..."
steamcmd +force_install_dir /srv/steamlibrary/steamapps/common/arma3 \
  +login "$steam_username" "$steam_password" +app_update 233780 validate +quit || \
  { echo "Error: Failed to install Arma 3 server."; exit 1; }
unset steam_username steam_password

# Download server.cfg
if [ ! -x /srv/steamlibrary/steamapps/common/arma3/server.cfg ]; then
  echo "Downloading server.cfg..."
  wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/server.cfg \
  -O /srv/steamlibrary/steamapps/common/arma3/server.cfg
fi

# Download arma3.sh
fi [ ! -x /srv/steamlibrary/steamapps/common/arma3/arma3.sh ]; then
  echo "Downloading arma3.sh..."
  wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/arma3.sh \
  -O /srv/steamlibrary/steamapps/common/arma3/arma3.sh
  chmod +x /srv/steamlibrary/steamapps/common/arma3/arma3.sh
fi


# Install arma3server.service
if [ ! -x /etc/systemd/system/arma3server.service ]; then
  echo "Installing arma3server.service..."
  wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/arma3server.service \
  -O /etc/systemd/system/arma3server.service
  systemctl enable arma3server
fi

# Start the Arma 3 server
[ "$(systemctl is-active arma3server)" == "active" ] && \
  echo "Arma 3 server is already running." || \
  echo "Starting Arma 3 server..." && \
  systemctl start arma3server

echo "Installation complete. Use 'systemctl status arma3server' to check the server status."
