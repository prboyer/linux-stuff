#! /bin/bash

# Install ZSH
sudo dnf install -y zsh

# Install Z Oxide
sudo dnf install -y zoxide fzf
zoxide init zsh > $ZSH/custom/zoxide.conf.zsh

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install fonts
if [ ! -d /usr/local/share/fonts ]; then
    sudo mkdir /usr/local/share/fonts;
fi

sudo tar -xzf ./NerdFont_Powerlevel10k.tar.gz -C /usr/local/share/fonts/ && sudo fc-cache -fv 1>/dev/null

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

