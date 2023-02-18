#!/usr/bin/env bash
# Inputs
STEAM_GAME_ID=$1
PATCH_DIR_NAME=$2
PATCH_EXE_NAME=$3


# Deck detection
if [[ $(cat /etc/os-release | grep "VERSION_CODENAME=holo") ]]; then deck=1; fi

if [[ ! $(command -v protontricks) ]]; then
  # Set up and install Protontricks
  flatpak install com.github.Matoking.protontricks
  flatpak override --user --filesystem="~/Downloads" com.github.Matoking.protontricks
  if [[ $deck ]]; then
    flatpak override --user --filesystem=/run/media/mmcblk0p2/
  fi
  protontricks="flatpak run com.github.Matoking.protontricks"
else
  protontricks="protontricks"
fi


# Detect patch STEAMGRID folder and copy *.png contents to Steam userdata
if [[ $(ls -d "$HOME/Downloads/$PATCH_DIR_NAME/STEAMGRID/"*.png) ]]; then
  if [[ $(ls -d "$HOME/.local/share/Steam/userdata/"*/config/grid) ]]; then
    echo -n "Copying custom grid images..."
      for GRID_DIR in $(ls -d "$HOME/.local/share/Steam/userdata/"*/config/grid); do
        $(cp "$HOME/Downloads/$PATCH_DIR_NAME/STEAMGRID/"*.png "$GRID_DIR/")
      done
    echo "Complete."
  fi
fi


# Patch the game
if [[ $deck ]]; then
  $protontricks -c "cd ~/Downloads/$PATCH_DIR_NAME && STEAM_COMPAT_MOUNTS=/run/media/mmcblk0p2 wine $PATCH_EXE_NAME" $STEAM_GAME_ID
else
  $protontricks -c "cd ~/Downloads/$PATCH_DIR_NAME && wine $PATCH_EXE_NAME" $STEAM_GAME_ID
fi


