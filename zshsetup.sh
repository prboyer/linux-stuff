#!/bin/bash
sudo apt install zsh git -y
echo Dependencies installed.
#echo Configure Shell
#chsh --shell /etc/zsh
echo Configuring Zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
mv ./.zshrc  ~/
mv ./.bash_aliases ~/

#echo Install a Nerd Font
# you can modify this if you want a different font.
#git clone https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/RobotoMono/Regular

