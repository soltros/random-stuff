#!/bin/bash

# Function to print steps
print_step() {
  echo -e "\n\e[1;32m$1\e[0m\n"
}

print_step "Step 1: Update and Upgrade the System"
sudo apt update
sudo apt upgrade -y

print_step "Step 2: Install Feh"
sudo apt install feh -y

print_step "Step 3: Create the LightDM Session"
sudo bash -c 'cat <<EOF > /usr/share/xsessions/slideshow.desktop
[Desktop Entry]
Name=Slideshow
Comment=Start a slideshow with Feh
Exec=/usr/share/xsessions/start-slideshow.sh
Type=Application
EOF'

print_step "Step 4: Create the Slideshow Script"
sudo bash -c 'cat <<EOF > /usr/share/xsessions/start-slideshow.sh
#!/bin/bash
xset -dpms # Disable DPMS (Energy Star) features.
xset s off # Disable screen saver.
xset s noblank # Don\'t blank the video device.
feh --fullscreen --hide-pointer --randomize --slideshow-delay 5 /home/pi/Pictures/
EOF'

print_step "Step 5: Make the Slideshow Script Executable"
sudo chmod +x /usr/share/xsessions/start-slideshow.sh

print_step "Step 6: Create the LightDM Configuration Script"
cat <<EOF > ~/lightdm-changer.sh
#!/bin/bash

# Update the package list
sudo apt-get update

# Install lightdm-gtk-greeter
sudo apt-get install -y lightdm-gtk-greeter

# Backup the current LightDM configuration file
sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bak

# Configure LightDM to use lightdm-gtk-greeter
sudo bash -c 'cat <<EOL > /etc/lightdm/lightdm.conf
[Seat:*]
greeter-session=lightdm-gtk-greeter
EOL'

# Edit the lightdm-gtk-greeter configuration file
sudo bash -c 'cat <<EOL > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
show-indicators=~language;~session;~power
EOL'

# Restart LightDM to apply the changes
sudo systemctl restart lightdm

echo "Configuration complete. lightdm-gtk-greeter has been installed and configured."
EOF

print_step "Step 7: Make the LightDM Configuration Script Executable"
chmod +x ~/lightdm-changer.sh

print_step "Step 8: Run the LightDM Configuration Script"
sudo ~/lightdm-changer.sh

print_step "Setup Complete! Please reboot your Raspberry Pi."
echo "After rebooting, select the 'Slideshow' session at the login screen to start your slideshow."
