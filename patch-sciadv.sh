#!/usr/bin/env bash

# Set up and install Protontricks
flatpak install com.github.Matoking.protontricks
flatpak override --user --filesystem="~/Downloads" com.github.Matoking.protontricks
if [[ "$4" == "deck" ]]; then
  flatpak override --user --filesystem=/run/media/mmcblk0p2/
fi

# Patch the game
protontricks="flatpak run com.github.Matoking.protontricks"
if [[ "$4" == "deck" ]]; then
  $protontricks -c "cd ~/Downloads/$2 && STEAM_COMPAT_MOUNTS=/run/media/mmcblk0p2 wine $3" $1
else
  $protontricks -c "cd ~/Downloads/$2 && wine $3" $1
fi
