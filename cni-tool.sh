#!/bin/bash

set -e

# Define the version of CNI plugins to install
CNI_PLUGINS_VERSION="v1.4.0"

# Define the download URL
CNI_PLUGINS_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-${CNI_PLUGINS_VERSION}.tgz"

# Define the target directory for CNI plugins
CNI_TARGET_DIR="/opt/cni/bin"

echo "Downloading CNI plugins version ${CNI_PLUGINS_VERSION}..."
curl --fail -Lo /tmp/cni-plugins.tgz "${CNI_PLUGINS_URL}"

echo "Creating target directory at ${CNI_TARGET_DIR}..."
sudo mkdir -p "${CNI_TARGET_DIR}"

echo "Extracting CNI plugins to ${CNI_TARGET_DIR}..."
sudo tar -xvzf /tmp/cni-plugins.tgz -C "${CNI_TARGET_DIR}"
echo "CNI plugins have been installed successfully."

# Cleanup
rm /tmp/cni-plugins.tgz

## Define path in bashrc
if ! grep -q 'export CNI_PATH=/opt/cni/bin' ~/.bashrc; then
    echo "export CNI_PATH=/opt/cni/bin" >> ~/.bashrc
fi

# Define the directory containing CNI config files
CNI_CONFIG_DIR="/home/derrik/.config/cni/net.d/"

# Define the old and new CNI version values
OLD_CNI_VERSION="\"cniVersion\": \"0.4.0\""
NEW_CNI_VERSION="\"cniVersion\": \"0.4.0\""

# Check if the CNI configuration directory exists
if [ -d "$CNI_CONFIG_DIR" ]; then
    echo "Updating CNI configuration files in $CNI_CONFIG_DIR..."
    
    # Find and update CNI version in all .conflist files in the directory
    for FILE in ${CNI_CONFIG_DIR}*.conflist; do
        if grep -q "$OLD_CNI_VERSION" "$FILE"; then
            echo "Updating cniVersion in $FILE to 0.4.0..."
            sudo sed -i "s/$OLD_CNI_VERSION/$NEW_CNI_VERSION/g" "$FILE"
        fi
    done
else
    echo "CNI configuration directory $CNI_CONFIG_DIR does not exist. Skipping version update."
fi

echo "CNI plugin installation and configuration update complete. CNI plugins are located in ${CNI_TARGET_DIR}"

# Add or update cron job to ensure cniVersion remains "0.4.0"
CRON_JOB="@hourly for FILE in ${CNI_CONFIG_DIR}*.conflist; do sudo sed -i 's/\"cniVersion\": \".*\"/\"cniVersion\": \"0.4.0\"/g' \$FILE; done"

# Check if the cron job exists, and add it if it doesn't
(crontab -l 2>/dev/null | grep -Fv "cniVersion"; echo "$CRON_JOB") | crontab -

echo "Cron job added to maintain cniVersion at 0.4.0"
