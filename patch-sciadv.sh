#!/usr/bin/env bash

# Deck detection
if [[ $(cat /etc/os-release | grep "VERSION_CODENAME=holo") ]]; then deck=1; fi

# Set up and install Protontricks
flatpak install com.github.Matoking.protontricks
flatpak override --user --filesystem="~/Downloads" com.github.Matoking.protontricks
if [[ $deck ]]; then
  flatpak override --user --filesystem=/run/media/mmcblk0p2/
fi

# Patch the game
protontricks="flatpak run com.github.Matoking.protontricks"
if [[ $deck ]]; then
  $protontricks -c "cd ~/Downloads/$2 && STEAM_COMPAT_MOUNTS=/run/media/mmcblk0p2 wine $3" $1
else
  $protontricks -c "cd ~/Downloads/$2 && wine $3" $1
fi
