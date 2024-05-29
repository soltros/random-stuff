#!/bin/sh

# Variables
ISO_URL="https://boot.netboot.xyz/ipxe/netboot.xyz.iso"
ISO_PATH="/boot/iso/netboot.xyz.iso"
GRUB_CUSTOM_FILE="/etc/grub.d/40_custom"
GRUB_CFG_FILE="/boot/grub/grub.cfg"

# Download the latest Netboot.xyz ISO
echo "Downloading Netboot.xyz ISO..."
sudo mkdir -p /boot/iso
sudo wget -O $ISO_PATH $ISO_URL

# Create a custom GRUB menu entry
echo "Adding custom GRUB entry..."
sudo sh -c "cat >> $GRUB_CUSTOM_FILE" <<EOL

menuentry "Netboot.xyz" {
    set iso_path="$ISO_PATH"
    loopback loop \$iso_path
    linux (loop)/boot/netboot.xyz-linux boot=live iso-scan/filename=\$iso_path
    initrd (loop)/boot/netboot.xyz-initrd.img
}
EOL

# Update GRUB configuration
echo "Updating GRUB configuration..."
sudo grub-mkconfig -o $GRUB_CFG_FILE

echo "Netboot.xyz has been added to your GRUB boot menu. Please reboot to use it."
