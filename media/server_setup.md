# Fedora Server Setup Instructions

These are the steps that were taken to setup the server

1. Set the hostname of the system with `hostnamectl`
1. Set the system chasis type with `hostnamectl`
1. Connect to network (WiFi) from terminal
    ```bash
    # List available WiFi networks
    nmcli device wifi list

    # Connect to network
    read -s -p 'Wifi Password: ' WIFI_PASSWORD;
    nmcli device wifi "<SSID>" password $WIFI_PASSWORD

    # Disconnect Network - get interface name, then use 'disconnect' command
    nmcli device status;
    nmcli device disconnect wlp2s0
    ```
1. Run `sudo dnf update -y` to update sources
1. Change permissions on `/srv/` directory
    ```bash
    sudo chgrp $USER /srv;
    sudo chmod g+rwx, g+s /srv;
    ```
1. Install Docker and Docker-Compose
    ```bash
    sudo dnf install -y docker docker-compose
    sudo groupmod -a -U docker $USER
    ```
    1. Sign out and sign back in to re-apply the group membership change.
1. Firewall rules.
    ```bash
  sudo firewall-cmd --zone=FedoraServer --add-port=8123/tcp

# plex
sudo firewall-cmd --zone=FedoraServer --add-port=32400/tcp

sudo firewall-cmd --zone=FedoraServer --add-port=80/tcp
  sudo firewall-cmd --zone=FedoraServer --add-port=443/tcp
  sudo firewall-cmd --zone=FedoraServer --add-port=3000/tcp
    ```

# PiHole Widget Setup
See:
# https://github.com/gethomepage/homepage/discussions/3152
# https://github.com/gethomepage/homepage/discussions/3152#discussioncomment-8859550

# X11 Setup
sudo dnf install xorg-x11-xauth

# Setup NSS Share for Plex
1. Install utils
```bash
sudo dnf install -y nfs-utils
```
1. Create mount point. Not needed to rip
```bash
sudo mkdir /mnt/prb-fs-1
```
1. Enable Synology NFS mounting for server IP
https://share.google/aimode/HM0PgaUV3kNbb1L67

1. Mount NFS Share
```bash
echo "192.168.68.70:/volume1/Media /mnt/prb-fs-1/Media  nfs defaults 0 0" | sudo tee -a /etc/fstab
```
