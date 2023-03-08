#!/usr/bin/env bash

# Usage syntax: `./polyversal.sh GAME_SHORTNAME PATCH_FOLDER_PATH`
function print_usage() {
  echo "usage: $0 GAME_SHORTNAME PATCH_FOLDER_PATH" >&2
  echo "  shortnames: 'chn', 'sg', 'rne', 'cc', 'sg0', 'rnd'" >&2
}

# Want `./polyversal.sh chn` and `./polyversal.sh CHN` to work the same
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

# I like colors. `tput` seems fairly portable, so it's used here to dictate
# logging capabilities. Only log with colors if `tput` is available, stderr
# outputs to a terminal, and it supports 8 or more colors.
txt_normal=''
txt_yellow=''
txt_red=''
if is_cmd tput && test -t 2 && [[ "$(tput colors)" -ge 8 ]]; then
  txt_normal="$(tput sgr0)"
  txt_yellow="$(tput setaf 3)"
  txt_red="$(tput setaf 1)"
fi

# log_msg <info|warn|err> <message>
function log_msg() {
  case $(tolower "$1") in
    'warn' | 'w')
      sevpfx="${txt_yellow}$0: WARN:"
      ;;
    'error' | 'err' | 'e')
      sevpfx="${txt_red}$0: ERR:"
      ;;
    'info' | 'i')
      sevpfx="$0: INFO:"
      ;;
    *)
      # Well I don't necessarily want the program to die immediately, so just do
      # whatever ig
      sevpfx="$0: $1:"
      ;;
  esac
  echo "${sevpfx} ${@:2}${txt_normal}" >&2
}
function log_info() { log_msg info "$@"; }
function log_warn() { log_msg warn "$@"; }
function log_err() { log_msg err "$@"; }


if [[ $# -ne 2 ]]; then
  log_err "expected 2 args, got $#"
  print_usage
  exit 1
fi


# Get the app ID and what the installer exe should be, based on the shortname.
# IDs are available in the README.
# CoZ's naming conventions are beautifully consistent, pls never change them
steamgrid=
gamename=
case $(tolower "$1") in
  'chn' | 'ch' | 'chaos'[\;\ ]'head noah')
    appid=1961950
    patch_exe='CHNSteamPatch-Installer.exe'
    gamename="Chaos;Head NoAH"
    steamgrid=1
    ;;
  'sg' | 'steins'[\;\ ]'gate')
    appid=412830
    patch_exe='SGPatch-Installer.exe'
    gamename="Steins;Gate"
    ;;
  'rne' | 'rn' | 'robotics'[\;\ ]'notes elite')
    appid=1111380
    patch_exe='RNEPatch-Installer.exe'
    gamename="Robotics;Notes Elite"
    ;;
  'cc' | 'chaos'[\;\ ]'child')
    appid=970570
    patch_exe='CCPatch-Installer.exe'
    gamename="Chaos;Child"
    ;;
  'sg0' | '0' | 'steins'[\;\ ]'gate 0')
    appid=825630
    patch_exe='SG0Patch-Installer.exe'
    gamename="Steins;Gate 0"
    ;;
  'rnd' | 'dash' | 'robotics'[\;\ ]'notes dash')
    appid=1111390
    patch_exe='RNDPatch-Installer.exe'
    gamename="Robotics;Notes DaSH"
    ;;
  *)
    log_err "shortname '$1' is invalid"
    print_usage
    exit 1
    ;;
esac

log_info "patching $gamename using app ID $appid, expecting patch EXE name '$patch_exe' ..."
[[ $steamgrid ]] && log_info "using custom SteamGrid images ..."


# Make sure the patch directory ($2) is valid.
# "Valid" here means:
# (1) it exists, and
# (2) it contains the expected patch EXE file to execute
if [[ ! -d "$2" ]]; then
  log_err "directory '$2' does not exist"
  exit 1
fi

if [[ ! -f "$2/$patch_exe" ]]; then
  log_err "expected patch EXE '$patch_exe' does not exist within directory '$2'"
  exit 1
fi

# Since we're running `cd` from within protontricks, we need to get the absolute
# path to the patch directory. Relative paths won't work for this since the
# shell invoked by `protontricks -c` sets its CWD to the game's directory.
# Prefer `realpath` to do the job, but if it's not available then get it by
# concatenating the user's CWD and the relative path. Simple testing shows that
# this hack does not work on Flatpak Protontricks.
patch_dir="$2"
if is_relpath "$2"; then
  if is_cmd realpath; then
    patch_dir=$(realpath "$2")
  else
    log_warn "'realpath' not available as a command."
    log_warn "attempting to manually set absolute path; this might cause issues."
    log_warn "if you get an error citing a non-existent file or directory, try supplying the path to the patch directory as absolute or homedir-relative."
    patch_dir="$(pwd)/$2"
  fi
fi


# Detect whether the machine is a Steam Deck.
is_deck=
if grep -qE '^VERSION_CODENAME=holo' /etc/os-release; then
  is_deck=1
  log_info "detected Steam Deck environment ..."
fi

# We need either system Protontricks or Flatpak Protontricks to work the magic.
# Prefer system Protontricks if it exists since there's less to set up.
protontricks_cmd='protontricks'
fp_protontricks='com.github.Matoking.protontricks'
if is_cmd protontricks; then
  log_info "detected system install of protontricks ..."
else
  log_info "system install of protontricks not found. proceeding with flatpak ..."
  if ! is_cmd flatpak; then
    log_err "neither flatpak nor system protontricks was detected."
    log_err "please install one of the two and then try again."
    exit 1
  fi
  if ! flatpak list | grep -q "$fp_protontricks" -; then
    log_info "protontricks is not installed on flatpak. attempting installation ..."
    if ! flatpak install $fp_protontricks; then
      log_err "an error occurred while installing flatpak protontricks."
      exit 1
    fi
    log_info "flatpak protontricks installed successfully"
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
log_info "patching $gamename ..."
compat_mts=
[[ $is_deck ]] && compat_mts="STEAM_COMPAT_MOUNTS=/run/media/"
$protontricks_cmd -c "cd \"$patch_dir\" && $compat_mts wine $patch_exe" $appid
if [[ $? -ne 0 ]]; then
  log_warn "patch installation exited with nonzero status."
  log_warn "consult the output for errors."
fi

# CHN CoZ patch includes custom SteamGrid images, but since the patch is built for
# Windows, the placement of those files ends up happening within the Wine prefix 
# instead of the system-level Steam install. The following code will detect the 
# STEAMGRID folder within the patch directory, and if it exists, copy any *.png 
# files at its root to Steam userdata/<user_id>/config/grid within a default Steam 
# path install ($HOME/.local/share/Steam)
#
# TODO: Add support for flatpak Steam installs.
if [[ $steamgrid ]]; then
  log_info "copying custom SteamGrid images ..."
  for grid_dir in "$HOME/.local/share/Steam/userdata/"*/config/grid; do
    cp "$patch_dir/STEAMGRID/"*.png "$grid_dir/"
  done
fi
