#!/bin/bash
echo Install Git
sudo apt install cowsay
cowthink "how'd you clone the repo without git?"

echo Install Updates
sudo apt update && sudo apt upgrade

echo Remove Firefox
sudo apt remove firefox

echo Install OpenSSH
sudo apt install openssh-server

echo Install Net Tools
sudo apt install net-tools

echo Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo Install VSCode
# see https://code.visualstudio.com/docs/setup/linux for more information
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

# trying to install via snap
sudo snap install --classic code 

echo Install Remmina Remote Desktop
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next -y
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice

echo Install PaloAlto GlobalProtect
tar -xvzf ./PanGPLinux-4.1.9-c3.tgz
sudo dpkg -i ./*.deb
# post-instal cleanup
rm -rf ./GlobalProtect*
rm ./manifest
rm ./relinfo

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

echo Cleanup
rm -f packages.*

echo Install ZSH
sh ./zshsetup.sh


