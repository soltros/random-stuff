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

echo "Installation completed. CNI plugins are located in ${CNI_TARGET_DIR}"
