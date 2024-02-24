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

# Define the directories containing CNI config files
CNI_CONFIG_DIRS=("/home/derrik/.config/cni/net.d/" "~/.config/cni/net.d/")

# Correct the CNI version in config files to avoid plugin compatibility issues
for CNI_CONFIG_DIR in "${CNI_CONFIG_DIRS[@]}"; do
    if [ -d "$CNI_CONFIG_DIR" ]; then
        echo "Correcting CNI configuration files in $CNI_CONFIG_DIR to version 0.4.0..."
        for FILE in ${CNI_CONFIG_DIR}*.conflist; do
            if grep -q "\"cniVersion\": \"1.0.0\"" "$FILE"; then
                echo "Setting cniVersion in $FILE to 0.4.0..."
                sudo sed -i 's/"cniVersion": "1.0.0"/"cniVersion": "0.4.0"/g' "$FILE"
            fi
        done
    else
        echo "CNI configuration directory $CNI_CONFIG_DIR does not exist. Skipping version correction."
    fi
done

echo "CNI plugin installation and configuration update complete. CNI plugins are located in ${CNI_TARGET_DIR}"

# Create and enable systemd service and timer for regular updates

# Service file content
SERVICE_FILE_CONTENT="[Unit]
Description=Update CNI Configurations to version 0.4.0

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for DIR in /home/derrik/.config/cni/net.d/ ~/.config/cni/net.d/; do for FILE in \$DIR*.conflist; do sudo sed -i \"s/\\\"cniVersion\\\": \\\"1.0.0\\\"/\\\"cniVersion\\\": \\\"0.4.0\\\"/g\" \$FILE; done; done'

[Install]
WantedBy=multi-user.target"

# Timer file content
TIMER_FILE_CONTENT="[Unit]
Description=Timer to regularly update CNI configurations

[Timer]
OnCalendar=*:0/10
Persistent=true

[Install]
WantedBy=timers.target"

# Create service and timer files
echo "$SERVICE_FILE_CONTENT" | sudo tee /etc/systemd/system/update_cni.service > /dev/null
echo "$TIMER_FILE_CONTENT" | sudo tee /etc/systemd/system/update_cni.timer > /dev/null

# Reload systemd, enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable --now update_cni.timer

echo "Systemd timer created and started to maintain cniVersion at 0.4.0 in all .conflist files every 10 minutes."
