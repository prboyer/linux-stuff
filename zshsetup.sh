#!/bin/bash

# Initialize variables that control script behavior
local wsl_mode=false;

# Handle command line switches
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; 
    do case $1 in
    -w | --WSL )
        wsl_mode=true;
        ;;
    -t | --theme )
        shift; theme=$1;
        ;;
    -u | --username )
        shift; username=$1
        ;;
    esac; shift; done
if [[ "$1" == '--' ]]; then 
    shift; 
fi

echo Installing Dependencies
sudo apt install zsh git -y
echo Dependencies installed.

echo Configuring ZSH
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
cp -f .zshrc  ~/

echo Update zshrc With Username 
sed -i "s/DEFAULT_USER/DEFAULT_USER=$username/g" ~/.zshrc

echo Install a Nerd Font
# you can modify this if you want a different font.
mkdir -p ~/.local/share/fonts
chmod 755 ~/.local/share/fonts
curl https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf -o ~/.local/share/fonts/MesloLGS\ NF\ Regular.ttf &
chmod 644 ~/.local/share/fonts/*
fc-cache -vf ~/.local/share/fonts/

# FONT IN WSL
# You need to install the .ttf font in Windows manually. Then in the windows terminal JSON settings, set 'fontFace':"MesloLGS NF"; This will enable glyphs

# copy themes to local folder
echo copying themes
cp ./themes/* ~/.oh-my-zsh/custom/themes

# set the theme
sed -i "s/ZSH_THEME=/ZSH_THEME=\"$theme\"/gi" ~/.zshrc

if [[ $wsl_mode == true ]]; then
echo "

# ONLY NEEDED IN WSL
#Setting GUI Display for WSL
export DISPLAY=:0

" >> ~/.zshrc
fi 

# change the shell to ZSH
echo Changing Shell
chsh -s /bin/zsh $USER;

echo "You must change the font of your terminal to the installed nerd font in order for glyphs to work.  Or comment out the "nerd-font" line in your ~/.zshrc file"
echo "Restart your terminal for changes to take effect."

# restart the shell
source ~/.zshrc &>/dev/null