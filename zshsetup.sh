#!/bin/bash
echo Installing Dependencies
sudo apt install zsh git -y
echo Dependencies installed.

echo Configuring ZSH
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
cp -f .zshrc  ~/
sed -i 's/pboyer2/$USER/g' ~/.zshrc
#cp ./.bash_aliases ~/


echo Install a Nerd Font
# you can modify this if you want a different font.
mkdir -p ~/.local/share/fonts
chmod 755 ~/.local/share/fonts
cp RobotoMonoNerdFontCompleteMono.ttf ~/.local/share/fonts
chmod 644 ~/.local/share/fonts/*
fc-cache -vf ~/.local/share/fonts/

# copy themes to local folder
echo copying themes
cp ./themes/* ~/.oh-my-zsh/themes

# change the shell to ZSH
echo Changing Shell
chsh -s /bin/zsh $USER 

echo You must change the font of your termianl to the installed Roboto Mono font in order for glyphs to work.  Or comment out the "nerd-font" line in your ~/.zshrc file
echo Restart your terminal for changes to take effect.
