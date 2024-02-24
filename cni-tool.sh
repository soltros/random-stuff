#!/bin/bash

# Update and install Podman and CNI plugins
sudo apt update
sudo apt -y install podman containernetworking-plugins

# Define CNI network configuration directory and file
CNI_CONFIG_DIR="/etc/cni/net.d"
CNI_CONFIG_FILE="${CNI_CONFIG_DIR}/87-podman-bridge.conflist"

# Check if the CNI network configuration directory exists
if [ ! -d "$CNI_CONFIG_DIR" ]; then
    echo "Creating CNI configuration directory..."
    sudo mkdir -p "$CNI_CONFIG_DIR"
fi

# Check if the CNI network configuration file already exists
if [ ! -f "$CNI_CONFIG_FILE" ]; then
    echo "Creating default Podman bridge network configuration..."
    # Create a default bridge network configuration
    sudo tee "$CNI_CONFIG_FILE" > /dev/null <<EOL
{
    "cniVersion": "0.4.0",
    "name": "podman",
    "plugins": [
        {
            "type": "bridge",
            "bridge": "cni-podman0",
            "isGateway": true,
            "ipMasq": true,
            "ipam": {
                "type": "host-local",
                "routes": [
                    { "dst": "0.0.0.0/0" }
                ],
                "ranges": [
                    [{ "subnet": "10.88.0.0/16" }]
                ]
            }
        },
        {
            "type": "portmap",
            "capabilities": {
                "portMappings": true
            }
        }
    ]
}
EOL
else
    echo "Podman CNI network configuration already exists."
fi

# Restart Podman service (useful if already installed)
echo "Restarting Podman service to apply changes..."
systemctl restart podman

echo "Podman and CNI setup is complete."
