#!/bin/bash

echo Install Updates
sudo apt update && sudo apt upgrade -y

# install Snapd
sudo apt install snapd

echo Remove Firefox
sudo apt remove firefox -y 
sudo apt remove thunderbird -y


# Microsoft-ify the image!
## Setup

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg

sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/

sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'

sudo rm microsoft.gpg

## Install MS Edge

sudo apt update

sudo apt install microsoft-edge-dev

# Install VS Code from Snapd
sudo snap install code --classic

echo Install PowerShell
# Download the Microsoft repository GPG keys
wget -q ./ https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

#if fails try via snap
# Install PowerShell
sudo snap install powershell --classic

# install Microsoft Teams
sudo snap install teams-for-linux
# make a link to the teams binary
sudo ln -s -T /snap/bin/teams-for-linux /snap/bin/teams

echo Install OpenSSH
sudo apt install openssh-server -y

echo Install Net Tools
sudo apt install net-tools -y

echo Install Remmina Remote Desktop
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next -y
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice -y

# install GParted
sudo apt install GParted -y

echo Cleanup
rm -f packages*

# run the ZSH installation
echo Install ZSH
sudo sh zshsetup.sh
