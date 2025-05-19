#!/bin/bash
# Script for installing configurations + managing packages. ONLY FOR LINUX MINT

ARCHIVE=$1
TEMP_DIR=$(mktemp -d)
INSTALL_PKGS="plasma-nm kde-standard system-config-printer msttcorefonts ttf-mscorefonts-installer tree"
REMOVE_PKGS="nemo cinnamon mintchat kmail akregator rhythmbox celluloid gnome-disk-utility gnome-system-monitor timeshift mintbackup file-roller warpinator xviewer bulky xed"

printf "\033[91mWARNING! This script for only LINUX MINT and desktop environments cinnamon!\033[0m\n"
printf "Already done? [y/n] "
read USER_RESPONSE
if [[ $USER_RESPONSE = "y" || $USER_RESPONSE = "Y" ]]; then
    printf "\033[93mAlright, at your own risk.\033[0m\n"
elif [[ $USER_RESPONSE = "n" || $USER_RESPONSE = "N" ]]; then
    printf "\n\033[91mAlright, aborting operation!\033[0m\n"
    exit
else
    printf "What?..\n"
    exit
fi

if [ "$EUID" -ne 0 ]; then
    printf "\033[91mPlease run as root!\033[0m\n"
    exit 1
fi
if [ ! -f "$ARCHIVE" ]; then
    echo "Error: archive file $ARCHIVE not found"
    exit 1
fi

# Unpack the archive
tar -xzvf "$ARCHIVE" -C "$TEMP_DIR"

# 1. Install the necessary packages
echo "Installing required packages..."
sudo apt update
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to update system!" >&2
    exit 1
fi
sudo apt install -y $INSTALL_PKGS
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install packages!" >&2
    exit 1
fi
sudo dpkg --configure -a

# 2. Removing unnecessary packages
echo "Removing unnecessary packages..."
sudo apt purge -y $REMOVE_PKGS
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to remove packages!" >&2
    exit 1
fi
sudo apt autoremove -y
if [ $? -ne 0 ]; then
    echo "ERROR: autoremove failed!" >&2
    exit 1
fi
echo "Verifying packages were removed..."
for pkg in $REMOVE_PKGS; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        echo "WARNING: Package $pkg is still installed!" >&2
        exit 1
    fi
done
sudo apt clean

# 3. Install configurations (as in the previous version)
echo "Setting configurations..."
cp -rf "$TEMP_DIR/etc/"* /etc/
cp -rf "$TEMP_DIR/usr/"* /usr/

# Clearing temporary files
rm -rf "$TEMP_DIR"

echo "The archive has been unpacked successfully, please reboot your PC!"
