# Apple SuperDrive on Linux
The USB [*Apple SuperDrive* DVD reader/writer](https://theapplewiki.com/wiki/Apple_USB_SuperDrive) is seemingly a proprietary piece of hardware that only works with Macs. Bah! In the age of AI and the Linux desktop, anything is possible.

To get this device working, I did the following (on Fedora Server 44 FWIW):
1. Install the `sg3-utils` package
    ```bash
    sudo dnf install -y sg3_utils
    ```
1. Send a binary command to the device to wake it up using the `sg_raw` executable
    ```bash
    sudo sg_raw /dev/sr0 EA 00 00 00 00 00 01
    ```
1. Now test if you can feed a disc into the slot-loading drive. After sending the wakeup signal, it should accept the disc.
1. Now that the disc is inserted, you can choose to mount it on the file system to browse the contents
    ```bash
    if [[ ! -d /mnt/dvdrom ]]; then
        sudo mkdir /mnt/dvdrom;
    fi;

    sudo mount /dev/sr0 /mnt/dvdrom
    ```
    1. Don't forget to unmount and eject when finished
        ```bash
        sudo umount /dev/dvdrom;
        eject /dev/sr0
        ```
1. To configure the system to always communicate with the USB SuperDrive (persist settings after reboot), use this command to apply the permanent rules
    ```bash
    sudo tee /etc/udev/rules.d/90-mac-superdrive.rules > /dev/null << 'EOF'
    # Apple SuperDrive initialization rule
    ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw --cmdset=1 %r/sr%n EA 00 00 00 00 00 01"
    EOF

    sudo udevadm control --reload-rules && sudo udevadm trigger
    ````
1. Finally, add your user account to the _cdrom_ Linux group so that it has permissions to access the raw device
    ```bash
    sudo usermod -aG cdrom $USER
    ```