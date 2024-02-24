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

# Process for correcting CNI version in config files remains unchanged...
# [Insert the rest of your script here for updating CNI versions]

# Handling the cron job setup with improved reliability
CRON_JOB="@hourly for DIR in /home/derrik/.config/cni/net.d/ ~/.config/net.d/; do for FILE in \$DIR*.conflist; do sudo sed -i 's/\"cniVersion\": \"1.0.0\"/\"cniVersion\": \"0.4.0\"/g' \$FILE; done; done"

# Add logging to the cron job
CRON_JOB_LOGGED="$CRON_JOB >> /var/log/cni_cron.log 2>&1"

# Use a temp file to safely edit crontab
TEMP_CRON_FILE=$(mktemp)
crontab -l > "$TEMP_CRON_FILE" 2>/dev/null || true # Suppress errors if no crontab exists
# Ensure the cron job is not duplicated
grep -Fv "cniVersion" "$TEMP_CRON_FILE" > "${TEMP_CRON_FILE}_tmp" && mv "${TEMP_CRON_FILE}_tmp" "$TEMP_CRON_FILE"
echo "$CRON_JOB_LOGGED" >> "$TEMP_CRON_FILE"
crontab "$TEMP_CRON_FILE"
rm "$TEMP_CRON_FILE"

echo "Cron job added to maintain cniVersion at 0.4.0 in all .conflist files and logged to /var/log/cni_cron.log"
