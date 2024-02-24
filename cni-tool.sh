#!/bin/bash

# Define the version of CNI plugins to install
CNI_PLUGINS_VERSION="v1.4.0"

# Define the download URL
CNI_PLUGINS_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-${CNI_PLUGINS_VERSION}.tgz"

# Define the target directory for CNI plugins
CNI_TARGET_DIR="/opt/cni/bin"

echo "Downloading CNI plugins version ${CNI_PLUGINS_VERSION}..."
wget -O /tmp/cni-plugins.tgz "${CNI_PLUGINS_URL}"

if [ $? -ne 0 ]; then
    echo "Failed to download CNI plugins."
    exit 1
fi

echo "Creating target directory at ${CNI_TARGET_DIR}..."
sudo mkdir -p "${CNI_TARGET_DIR}"

echo "Extracting CNI plugins to ${CNI_TARGET_DIR}..."
sudo tar -xvzf /tmp/cni-plugins.tgz -C "${CNI_TARGET_DIR}"

if [ $? -eq 0 ]; then
    echo "CNI plugins have been installed successfully."
else
    echo "Failed to extract CNI plugins."
    exit 1
fi

# Cleanup
rm /tmp/cni-plugins.tgz

## Define path in bashrc
echo "export CNI_PATH=/opt/cni/bin" >> ~/.bashrc

# Add or update cron job to ensure cniVersion remains "1.0.0"

CRON_JOB="@hourly for FILE in /home/derrik/.config/cni/net.d/*.conflist; do sudo sed -i 's/\"cniVersion\": \"1.0.0\"/\"cniVersion\": \"0.4.0\"/g' \$FILE; done"

# Write out current crontab to a temporary file
crontab -l > mycron

# Echo new cron job into the cron file, removing any old job related to this script
grep -v 'cniVersion' mycron > mycron.tmp && mv mycron.tmp mycron
echo "$CRON_JOB" >> mycron

# Install new cron jobs from the file
crontab mycron
rm mycron

echo "Cron job added to maintain cniVersion at 1.0.0"


# Define the directory containing CNI config files
CNI_CONFIG_DIR="/home/derrik/.config/cni/net.d/"

# Define the old and new CNI version values
OLD_CNI_VERSION="\"cniVersion\": \"1.0.0\""
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
