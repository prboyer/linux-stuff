#!/bin/bash
echo Insall Updates
sudo apt update && sudo apt upgrade

echo Remove Firefox
sudo apt remove firefox

echo Install Chromium
sudo apt install chromium-browser

echo Install VSCode
# see https://code.visualstudio.com/docs/setup/linux for more information
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

echo Install Remmina Remote Desktop
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice

echo Install PaloAlto GlobalProtect
tar -xvzf ./PanGPLinux-4.1.9-c3.tgz
