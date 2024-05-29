#!/bin/sh

# Variables
LKR_URL="https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn"
LKR_PATH="/boot/netboot.xyz.lkrn"
GRUB_CUSTOM_FILE="/etc/grub.d/40_custom"
GRUB_CFG_FILE="/boot/grub/grub.cfg"

# Download the latest Netboot.xyz lkrn file
echo "Downloading Netboot.xyz lkrn file..."
sudo wget -O $LKR_PATH $LKR_URL

# Create a custom GRUB menu entry
echo "Adding custom GRUB entry..."
sudo sh -c "cat >> $GRUB_CUSTOM_FILE" <<EOL

menuentry "Netboot.xyz" {
    linux16 $LKR_PATH
}
EOL

# Update GRUB configuration
echo "Updating GRUB configuration..."
sudo grub-mkconfig -o $GRUB_CFG_FILE

echo "Netboot.xyz has been added to your GRUB boot menu. Please reboot to use it."
