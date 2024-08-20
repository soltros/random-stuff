#!/bin/bash

# Introduction
echo "Welcome to the BorgBackup setup script!"
echo "This script will guide you through the process of setting up a BorgBackup repository on your Debian Raspberry Pi."

# Step 1: Choose the repository folder
echo "Step 1: Choose the repository folder"
read -p "Enter the path to the folder where you want to store your BorgBackup repository (e.g. /mnt/backups/borg): " repo_folder

# Create the repository folder if it doesn't exist
if [ ! -d "$repo_folder" ]; then
  sudo mkdir -p "$repo_folder"
fi

# Step 2: Initialize the BorgBackup repository
echo "Step 2: Initialize the BorgBackup repository"
sudo borg init -e repokey "$repo_folder"

# Step 3: Set up the BorgBackup environment
echo "Step 3: Set up the BorgBackup environment"
read -p "Enter a secret passphrase for your BorgBackup repository: " passphrase
echo "export BORG_REPO=$repo_folder" | sudo tee /etc/borg.env
echo "export BORG_PASSPHRASE='$passphrase'" | sudo tee -a /etc/borg.env

# Step 4: Configure BorgBackup
echo "Step 4: Configure BorgBackup"
echo "[repository]" | sudo tee /etc/borg.conf
echo "location = $repo_folder" | sudo tee -a /etc/borg.conf
echo "encryption = repokey" | sudo tee -a /etc/borg.conf

# Step 5: Test BorgBackup
echo "Step 5: Test BorgBackup"
sudo borg create --stats --list "$repo_folder::test"

# Step 6: Schedule regular backups
echo "Step 6: Schedule regular backups"
read -p "Do you want to schedule regular backups? (y/n): " schedule_backups
if [ "$schedule_backups" = "y" ]; then
  read -p "Enter the frequency of the backups (e.g. daily, weekly, monthly): " frequency
  sudo crontab -e
  echo "0 2 * * * borg create --stats --list $repo_folder::$frequency" | sudo tee -a /etc/crontab
fi

echo "Congratulations! Your BorgBackup repository is now set up."
