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

# Since we're running `cd` from within protontricks, we need to get the absolute
# path to the patch directory. Relative paths won't work for this since testing
# shows that the shell invoked by `protontricks -c` sets its CWD to the game's
# directory.
# Prefer `realpath` to do the job, but if it's not available then get it by
# concatenating the user's CWD and the relative path. Simple testing shows that
# this hack does not work on Flatpak Protontricks.
patch_dir="$2"
if is_relpath "$2"; then
  if is_cmd realpath; then
    patch_dir=$(realpath "$2")
  else
    echo "WARN: 'realpath' not available as a command." >&2
    echo "WARN: attempting to manually set absolute path; this might cause issues." >&2
    echo "WARN: if you get an error citing a non-existent file or directory, try supplying the path to the patch directory as absolute or homedir-relative." >&2
    patch_dir="$(pwd)/$2"
  fi
fi


# Detect whether the machine is a Steam Deck.
is_deck=
if grep -qE '^VERSION_CODENAME=holo' /etc/os-release; then
  is_deck=1
  echo "detected Steam Deck environment ..." >&2
fi

# We need either system Protontricks or Flatpak Protontricks to work the magic.
# Prefer system Protontricks if it exists since there's less to set up.
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

  # Flatpak Protontricks has to be given access to the game's Steam folder to
  # make changes. On Deck this is (hopefully) as easy as giving it access to all
  # of its mounts and partitions; on PC, this could involve some tricky parsing
  # of VDF files to give it access to different library folders.
  [[ $is_deck ]] && flatpak override --user --filesystem=/run/media/ $fp_protontricks

  # TODO: parse VDF files to give it access to different library folders. For
  # now, FP Protontricks gives the user a prompt telling it which folder to give
  # access to anyway, so it's not too big of an issue as long as the user can
  # (a) read, and (b) copy and paste a single command.
fi


# Patch the game
compat_mts=
[[ $is_deck ]] && compat_mts="STEAM_COMPAT_MOUNTS=/run/media/"
$protontricks_cmd -c "cd $patch_dir && $compat_mts wine $patch_exe" $appid
