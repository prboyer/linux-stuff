# Fedora Server Setup Instructions
This document includes inscrutions for setting up a home media server

## Basic Setup
1. Set the hostname of the system
    ```bash
    hostnamectl hostname my-host
    ```
1. Set the system chasis type
    ```bash
    hostnamectl chassis desktop
    ```
    1. Get accepted "types" via
        ```bash
        man hostnamectl | grep chassis
        ```
## Wireless Network Configuration
```bash
# List available WiFi networks
nmcli device wifi list

# Connect to network
read -s -p 'Wi-Fi Password: ' WIFI_PASSWORD;
nmcli device wifi "<SSID>" password $WIFI_PASSWORD

# Disconnect Network - get interface name, then use 'disconnect' command
nmcli device status;
nmcli device disconnect wlp2s0
```
## Configure Docker Directory and Container Service
1. Create `/srv/` directory to store `docker-compose` files
    ```bash
    sudo mkdir -p /srv/docker;
    sudo chgrp $USER /srv;
    sudo chmod g+rwx, g+s /srv;
    ```
1. Install Docker and Docker-Compose
    ```bash
    sudo dnf install -y docker docker-compose
    ```
1. Add the current user as a member of the _docker_ group so that commands can be passed to the `docker` binary without the need to `sudo`.
    ```bash
     sudo groupmod -a -U docker $USER
     ```
    1. Sign out and sign back in to re-apply the group membership change.
1. Firewall rules.
```bash
  sudo firewall-cmd --zone=FedoraServer --add-port=8123/tcp
  ```

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

# Apple USB Super Drive
1. Install utils
```bash
sudo dnf install sg3_utils -y
```
1. Wake up drive
```bash
sudo sg_raw /dev/sr0 EA 00 00 00 00 00 01
```
1. Add permanent mounting rules
```bash
sudo tee /etc/udev/rules.d/90-mac-superdrive.rules > /dev/null << 'EOF'
# Apple SuperDrive initialization rule
ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw --cmdset=1 %r/sr%n EA 00 00 00 00 00 01"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger
```
1. Access mounted CD/DVD at `/mnt/dvdrom`
```bash
if [[ ! -d /mnt/dvdrom ]]; then
sudo mkdir /mnt/dvdrom;
fi;

sudo mount /dev/sr0 /mnt/dvdrom
```

1. Eject when done
```bash
sudo umount /dev/dvdrom;
eject /dev/sr0
```
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

# Ripping DVDs for Plex

Organize the plex media library according to vendor documentation: https://support.plex.tv/articles/naming-and-organizing-your-movie-media-files/

TV shows needs to be handled slightly different: https://support.plex.tv/articles/naming-and-organizing-your-tv-show-files/

Handle multiple versions (resolutions) of the same movie: https://support.plex.tv/articles/200381043-multi-version-movies/

1. Install tools
```bash
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y rpmfusion-free-release-tainted;

sudo dnf install -y libdvdcss makemkv

sudo dnf install -y ffmpeg dvdbackup HandBrake;
```

1. Add user to _cdrom_ linux group so that it has permissions to access the raw device
```bash
sudo usermod -aG cdrom $USER
```

1. Use Handbrake CLI to RIP DVD to H.265 MP4
```bash
HandBrakeCLI -i /dev/sr0 -o /mnt/prb-fs-1/Media/output.mp4 -e x265 -q 22 --encoder-preset fast --format av_mp4 --subtitle-lang-list eng --audio-lang-list eng --main-feature
```
1. If Handbrake doesn't work, then use MakeMKV to rip
```bash
makemkvcon mkv dev:/dev/sr0 all /tmp/

HandBrakeCLI -i /tmp/ -o /mnt/prb-fs-1/Media/output.mp4 -e x265 -q 22 --encoder-preset fast --format av_mp4 --subtitle-lang-list eng --audio-lang-list eng
```

1. Use Handbrake to compress large 4K movies
```bash
HandBrakeCLI -i "input.mkv" -o "output.mkv" -f av_mkv -e x265_10bit -q 18 --encoder-preset slow --encoder-profile main10 --all-audio -E copy --audio-fallback ac3 --all-subtitles
```

1. Ripping TV Seasons with Handbrake
https://support.plex.tv/articles/naming-and-organizing-your-tv-show-files/

Do a preliminary scan of titles
```bash
HandBrakeCLI -i /dev/sr0 --title 0 --scan 2>&1 | grep -E "^\+ title|duration:"

```

Do the ripping

```bash
rip_tv_disc() {
    local show_name="$1"   # e.g., "The Paper"
    local season="$2"      # e.g., 1
    local start_ep="$3"    # e.g., 1
    local min_mins="$4"    # Minimum episode length in minutes (e.g., 20)
    local max_mins="$5"    # Maximum episode length in minutes (e.g., 33)
    local out_dir="$6"     # e.g., "/mnt/prb-fs-1/Media/television/The Paper (2025) {imdb-tt32159809}/Season 01"
    local dvd_dev="$7"     # e.g., "/dev/sr0"

    mkdir -p "$out_dir"
    echo "Scanning $dvd_dev for titles between ${min_mins} and ${max_mins} minutes..."

    local titles=()
    mapfile -t titles < <(
        HandBrakeCLI -i "$dvd_dev" --title 0 --scan 2>&1 | awk -v min="$min_mins" -v max="$max_mins" '
            /^\+ title [0-9]+:/ {
                gsub(/:/, "", $3)
                t = $3
            }
            /duration:/ {
                split($3, d, ":")
                mins = (d[1] * 60) + d[2] + (d[3] / 60)
                if (mins >= min && mins <= max && $3 != prev_dur) {
                    print t
                    prev_dur = $3
                }
            }
        '
    )

    if [ ${#titles[@]} -eq 0 ]; then
        echo "No titles found matching ${min_mins}-${max_mins} minutes."
        return 1
    fi

    echo "Found matching titles: ${titles[*]}"
    local ep="$start_ep"

    for t in "${titles[@]}"; do
        local s_pad=$(printf "%02d" "$season")
        local e_pad=$(printf "%02d" "$ep")
        local out_file="${out_dir}/${show_name} - s${s_pad}e${e_pad}.mp4"

        echo "Ripping DVD Title $t -> $out_file"
        HandBrakeCLI -i "$dvd_dev" \
            -t "$t" \
            -o "$out_file" \
            -e x265 -q 20 --encoder-preset medium \
            --all-audio --all-subtitles

        ((ep++))
    done
}

```

For half-hour shows, invoke with:
```bash
rip_tv_disc "Show Name" 1 1 20 26 "/media/tv/Show Name/Season 01" /dev/sr0
```

For longer shows, use:
```bash
rip_tv_disc "Show Name" 1 1 40 50 "/media/tv/Show Name/Season 01" /dev/sr0
```
