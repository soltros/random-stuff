sudo apt install curl uidmap

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

curl -s https://raw.githubusercontent.com/soltros/random-stuff/main/install-podman | sh -s -- --prefix ~/.local

echo "#Distrobox settings" >> ~/.bashrc

echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc

echo "export PATH=$HOME/.local/podman/bin:$PATH" >> ~/.bashrc

echo "xhost +si:localuser:$USER" >> ~/.bashrc

echo "alias='cd ~/.local/bin/;./distrobox'" >> ~/.bashrc

source ~/.bashrc
