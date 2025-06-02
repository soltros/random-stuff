#!/bin/bash

echo "Installing recommended Flatpaks..."

flatpak install -y flathub \
  com.valvesoftware.Steam \
  com.github.tchx84.Flatseal \
  com.bitwarden.desktop \
  org.filezillaproject.Filezilla \
  io.github.shiftey.Desktop \
  im.riot.Riot \
  com.github.iwalton3.jellyfin-media-player \
  io.github.dweymouth.supersonic \
  com.github.wwmm.easyeffects \
  org.mozilla.Thunderbird
