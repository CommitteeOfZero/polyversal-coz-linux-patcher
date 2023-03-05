#!/usr/bin/env bash

# Usage syntax: `./patcher2.sh GAME_SHORTNAME PATCH_FOLDER_PATH`
function print_usage() {
  echo "usage: ./patcher2.sh GAME_SHORTNAME PATCH_FOLDER_PATH" >&2
  echo "  shortnames: 'chn', 'sg', 'rne', 'cc', 'sg0', 'rnd'" >&2
}

# Want `./patcher2.sh chn` and `./patcher2.sh CHN` to work the same
function tolower() {
  echo "$@" | tr '[:upper:]' '[:lower:]'
}

# Returns whether the argument is a relative path or not, based solely on
# whether the path starts with a '/'.
function is_relpath() {
  echo "$1" | grep -qE '^/' - && return 1 || return 0
}

# `command -v COMMAND` prints information about COMMAND, but importantly has
# exit status 0 if the command exists and 1 if it does not. This true/false
# value is what we use in this script to determine whether a command is
# installed and available on the system.
function is_cmd() {
  command -v "$1" > /dev/null
}


if [[ $# -ne 2 ]]; then
  echo "ERR: expected 2 args, got $#" >&2
  print_usage
  exit 1
fi


# Get the app ID and what the installer exe should be, based on the shortname.
# IDs are available in the README.
# CoZ's naming conventions are beautifully consistent, pls never change them
case $(tolower "$1") in
  'chn' | 'ch' | 'chaos'[\;\ ]'head noah')
    appid=1961950
    patch_exe='CHNSteamPatch-Installer.exe'
    ;;
  'sg' | 'steins'[\;\ ]'gate')
    appid=412830
    patch_exe='SGPatch-Installer.exe'
    ;;
  'rne' | 'rn' | 'robotics'[\;\ ]'notes elite')
    appid=1111380
    patch_exe='RNEPatch-Installer.exe'
    ;;
  'cc' | 'chaos'[\;\ ]'child')
    appid=970570
    patch_exe='CCPatch-Installer.exe'
    ;;
  'sg0' | '0' | 'steins'[\;\ ]'gate 0')
    appid=825630
    patch_exe='SG0Patch-Installer.exe'
    ;;
  'rnd' | 'dash' | 'robotics'[\;\ ]'notes dash')
    appid=1111390
    patch_exe='RNDPatch-Installer.exe'
    ;;
  *)
    echo "ERR: shortname '$1' is invalid" >&2
    print_usage
    exit 1
esac

echo "using app ID '$appid', expecting patch EXE name '$patch_exe' ..." >&2


# Make sure the patch directory ($2) is valid.
# "Valid" here means:
# (1) it exists, and
# (2) it contains the expected patch EXE file to execute
if [[ ! -d "$2" ]]; then
  echo "ERR: directory '$2' does not exist" >&2
  exit 1
fi

if [[ ! -f "$2/$patch_exe" ]]; then
  echo "ERR: expected patch EXE '$patch_exe' does not exist within directory '$2'" >&2
  exit 1
fi

patch_dir="$2"


# Detect whether the machine is a Steam Deck.
is_deck=
if grep -qE '^VERSION_CODENAME=holo' /etc/os-release; then
  is_deck=1
  echo "detected Steam Deck environment ..." >&2
fi

# We need either system Protontricks or Flatpak Protontricks to work the magic.
# Prefer system Protontricks if it exists, since there's less to set up.
protontricks_cmd='protontricks'
fp_protontricks='com.github.Matoking.protontricks'
if is_cmd protontricks; then
  echo "detected system install of protontricks ..." >&2
else
  echo "system install of protontricks not found. proceeding with flatpak ..." >&2
  if ! is_cmd flatpak; then
    echo "ERR: neither flatpak nor system protontricks was detected." >&2
    echo "     please install one of the two and then try again." >&2
    exit 1
  fi
  if ! flatpak list | grep -q "$fp_protontricks" -; then
    echo "WARN: protontricks is not installed on flatpak. attempting installation ..." >&2
    flatpak install $fp_protontricks
  fi
  protontricks_cmd="flatpak run $fp_protontricks"

  # Need to grant flatpak protontricks access to the patch directory.  This path
  # can only either be given as an absolute or homedir-relative path, which $2
  # may not have been supplied as.
  # If it's a normal relative path, get an absolute path by concatenating the
  # current working directory and the relative path.
  if [[ $is_deck ]]; then
    fpfs='/run/media/'
  else
    fpfs="$patch_dir"
    # Detect if patch dir was not provided as absolute path.
    # '~[user]/' is expanded to be absolute before script execution.
    if is_relpath "$patch_dir"; then
      if is_cmd realpath; then
        fpfs=$(realpath "$patch_dir")
      else
        echo "WARN: 'realpath' command not available for provided relative path." >&2
        echo "      attempting to manually set absolute path; this might cause issues." >&2
        fpfs="$(pwd)/$patch_dir"
      fi
    fi
  fi
  flatpak override --user --filesystem="$fpfs" $fp_protontricks
fi


# Patch the game
compat_mts=
[[ $is_deck ]] && compat_mts="STEAM_COMPAT_MOUNTS=/run/media"
$protontricks_cmd -c "cd $patch_dir && $compat_mts wine $patch_exe" $appid
