#! /bin/bash

# Install linux pacakges that are already hosted in the Fedora repos
FEDORA_PACKAGES=(
    git
    git-lfs
    gh
    bat
    htop
    tmux
    nmap
    vim
    gimp
    ffmpeg
    dos2unix
    ghostscript
    pdfgrep
);

sudo dnf install -y "${FEDORA_PACKAGES[@]}"

# Install Microsoft apps
source /etc/os-release
curl -sSL -O https://packages.microsoft.com/config/$ID/${VERSION_ID%%.*}/packages-microsoft-prod.rpm
sudo dnf install -y ./packages-microsoft-prod.rpm
rm packages-microsoft-prod.rpm

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo dnf update -y
sudo dnf upgrade -y --refresh

## Install Edge
# https://linuxcapable.com/install-microsoft-edge-on-fedora-linux/
printf '%s\n' \
'[microsoft-edge]' \
'name=microsoft-edge' \
'baseurl=https://packages.microsoft.com/yumrepos/edge-stable' \
'enabled=1' \
'gpgcheck=1' \
'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee /etc/yum.repos.d/microsoft-edge.repo > /dev/null

sudo dnf makecache --refresh
sudo dnf install -y microsoft-edge-stable

## Install VSCode
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf makecache --refresh
sudo dnf install -y code

## Install PowerShell
sudo dnf install -y https://github.com/PowerShell/PowerShell/releases/download/v7.6.7/powershell-7.6.7-1.rh.x86_64.rpm

## Install Microsoft fonts
sudo yum install -y curl cabextract xorg-x11-font-utils fontconfig && sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Install Discord
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update -y
sudo dnf install -y discord

# Install Spotify
sudo dnf install -y lpf-spotify-client
lpf update < yes

# Install 1Password
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'

sudo dnf install -y 1password 1password-cli


# Install X11 for RDP
sudo dnf install plasma-workspace-x11