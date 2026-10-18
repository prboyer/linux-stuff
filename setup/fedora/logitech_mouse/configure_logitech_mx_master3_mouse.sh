#!/bin/bash

# Install Solaar helper application
sudo dnf install -y solaar

# Copy rules into configuration folder
# https://discuss.cachyos.org/t/logitech-wireless-mice-scroll-wheel-issues-in-kernel-7-0/28425
if [ ! -d /home/$USER/.config/solaar ]; then
	mkdir /home/$USER/.config/solaar
fi

cp -f ./solaar/* /home/$USER/.config/solaar/

# Install the logid Service
# https://medium.com/@Tal-Hason/living-with-a-logitech-mx-master-3-mouse-on-my-fedora-os-6e49a4662b5e

sudo dnf install -y logid

sudo cp ./logid/logid.cnf /etc/

sudo systemctl start logid
sudo systemctl enable logid
