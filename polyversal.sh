#!/usr/bin/env bash

# Usage syntax: `./polyversal.sh GAME_SHORTNAME PATCH_FOLDER_PATH`
function print_usage() {
  cat << EOF >&2
Usage:
 GUI:
  $0
 CLI:
  $0 <game_shortname> <patch_folder_path>

Game shortnames:
  'chn', 'sg', 'rne', 'cc', 'sg0', 'rnd'

EOF
}

# Want `./polyversal.sh chn` and `./polyversal.sh CHN` to work the same
function tolower() {
  printf '%s' "$*" | tr '[:upper:]' '[:lower:]'
}

# Returns whether the argument is a relative path or not, based solely on
# whether the path starts with a '/'.
function is_relpath() {
  printf '%s' "$1" | grep -qE '^/' - && return 1 || return 0
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
txt_green=''
txt_yellow=''
txt_red=''
txt_purple=''
if is_cmd tput && test -t 2 && [[ "$(tput colors)" -ge 8 ]]; then
  txt_normal="$(tput sgr0)"
  txt_green="$(tput setaf 2)"
  txt_yellow="$(tput setaf 3)"
  txt_red="$(tput setaf 1)"
  txt_purple="$(tput setaf 5)"
fi

# log_msg <info|warn|err> <message>
function log_msg() {
  local sevpfx
  case "$(tolower "$1")" in
    'info' | 'i')
      sevpfx="${txt_green}INFO:"
      ;;
    'warn' | 'w')
      sevpfx="${txt_yellow}WARN:"
      ;;
    'error' | 'err' | 'e')
      sevpfx="${txt_red}ERR:"
      ;;
    'fatal' | 'fat' | 'f')
      sevpfx="${txt_purple}FATAL:"
      ;;
    *)
      # Well I don't necessarily want the program to die immediately, so just do
      # whatever ig
      sevpfx="$1:"
      ;;
  esac
  printf '%s %s%s\n' "$0: $sevpfx" "${*:2}" "$txt_normal" >&2
}
function log_info() { log_msg info "$*"; }
function log_warn() { log_msg warn "$*"; }
function log_err() { log_msg err "$*"; }
function log_fatal() { log_msg fatal "$*"; }

# Handle non-zero exit statuses from Zenity.
# **Must be called immediately after zenity command.**
# Single optional argument is the message to be displayed in the case that the
# user closes the window.
function handle_zenity() {
  local zen_ret=$?
  local closedmsg="$*"
  [[ ! "$closedmsg" ]] && closedmsg="You must select an option."
  case $zen_ret in
    1)
      log_fatal "$closedmsg"
      exit 1
      ;;
    5)
      log_fatal "The input dialogue timed out."
      exit 1
      ;;
    -1)
      log_fatal "An unexpected error occurred using Zenity."
      exit 1
      ;;
  esac
}

# Protontricks version is output as 'protontricks (x.y.z)'
function ptx_ver() {
  local ptx_cmd
  case "$1" in
    'fp')
      ptx_cmd='flatpak run com.github.Matoking.protontricks'
      ;;
    'sys')
      ptx_cmd='protontricks'
      ;;
  esac
  $ptx_cmd --version | sed -E 's/^protontricks \((.*)\)$/\1/g'
}

# Determines whether the specified Protontricks is up to date, i.e. its version
# number is semantically greater than '1.10.1'. Otherwise running the EXE will
# fail with a cryptic error message about magic numbers in the proton
# executable, or something.
# Single argument is which Protontricks to check:
# 'fp' = Flatpak, 'sys' = system install
# Other arguments don't do anything. Don't use them!
# is_ptx_valid <fp|sys>
function is_ptxvalid() {
  local cur_ver
  local older_ver
  local min_ver=1.10.1
  cur_ver="$(ptx_ver "$1")"
  older_ver="$(printf '%s\n%s\n' "$min_ver" "$cur_ver" | sort -V | head -n 1)"
  [[ $older_ver == "$min_ver" ]]
}


# Detect whether the machine is a Steam Deck.
is_deck=
if grep -qE '^VERSION_CODENAME=holo' /etc/os-release; then
  is_deck=1
  log_info "detected Steam Deck environment ..."
fi

# We need Protontricks either through a system install or through Flatpak to
# work the magic.
# Prefer system install since it plays nice with relative dirs and doesn't need
# permissions to be setup, but if it's unavailable or outdated then use Flatpak.
protontricks_cmd='protontricks'
fp_protontricks='com.github.Matoking.protontricks'
is_flatpak=
if is_cmd protontricks && is_ptxvalid sys; then
  log_info "detected valid system install of protontricks ..."
else
  if is_cmd protontricks; then
    log_warn "system install of protontricks has insufficient version: $(ptx_ver sys) < 1.10.1"
  else
    log_info "system install of protontricks not found"
  fi

  log_info "proceeding with flatpak ..."
  if ! is_cmd flatpak; then
    log_fatal "neither flatpak nor a valid system protontricks was detected."
    log_fatal "please install one of the two and then try again."
    exit 1
  fi

  # Install protontricks if it's not already
  if ! flatpak list | grep -q "$fp_protontricks" -; then
    log_warn "protontricks is not installed on flatpak. attempting installation ..."
    if ! flatpak install "$fp_protontricks"; then
      log_fatal "an error occurred while installing flatpak protontricks."
      exit 1
    fi
    log_info "flatpak protontricks installed successfully"
  fi

  # Has to have version >= 1.10.1
  if ! is_ptxvalid fp; then
    log_warn "flatpak protontricks has insufficient version: $(ptx_ver fp) < 1.10.1"
    log_warn "attempting to update ..."
    if ! flatpak update "$fp_protontricks"; then
      log_fatal "an error occurred while updating flatpak protontricks."
      exit 1
    fi
    log_info "flatpak protontricks updated successfully"
  fi

  is_flatpak=1
  protontricks_cmd="flatpak run $fp_protontricks"
fi


arg_game=
arg_patchdir=
if [[ $# -eq 0 ]]; then
  # Assume GUI mode
  if ! is_cmd zenity; then
    log_fatal "Zenity is required to run this script in GUI mode. Please make sure you have it installed, then try again."
    # TODO (maybe): implement with Kdialog. probably not worth until someone files an issue/PR
    print_usage
    exit 1
  fi

  arg_game="$(zenity --list --radiolist --title "Choose Which Game to Patch" \
      --height 400 --width 600            \
      --column "Select" --column "Title"  \
      TRUE  'Chaos;Head NoAH'             \
      FALSE 'Steins;Gate'                 \
      FALSE 'Robotics;Notes Elite'        \
      FALSE 'Chaos;Child'                 \
      FALSE 'Steins;Gate 0'               \
      FALSE 'Robotics;Notes DaSH')"
  handle_zenity "You must select which game to patch for the script to work."

  arg_patchdir="$(zenity --file-selection --title "Choose Patch Directory for $arg_game" \
      --directory --filename "$HOME/Downloads")"
  handle_zenity "You must select the directory containing the patch for the script to work."
elif [[ $# -eq 2 ]]; then
  arg_game="$1"
  arg_patchdir="$2"
else
  printf '%s\n' 'Invalid syntax' >&2
  print_usage
  exit 1
fi


# Get the app ID and what the installer exe should be, based on the shortname.
# IDs are available in the README.
# CoZ's naming conventions are beautifully consistent, pls never change them
appid=
patch_exe=
gamename=
has_steamgrid=
needs_sgfix=
case "$(tolower "$arg_game")" in
  'chn' | 'ch' | 'chaos'[\;\ ]'head noah')
    appid=1961950
    patch_exe='CHNSteamPatch-Installer.exe'
    gamename="Chaos;Head NoAH"
    has_steamgrid=1
    ;;
  'sg' | 'steins'[\;\ ]'gate')
    appid=412830
    patch_exe='SGPatch-Installer.exe'
    gamename="Steins;Gate"
    needs_sgfix=1
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
    log_fatal "shortname '$arg_game' is invalid"
    print_usage
    exit 1
    ;;
esac

log_info "patching $gamename using app ID $appid, expecting patch EXE name '$patch_exe' ..."
[[ $has_steamgrid ]] && log_info "using custom SteamGrid images ..."

# Make sure the patch directory ($arg_patchdir) is valid.
# "Valid" here means:
# (1) it exists, and
# (2) it contains the expected patch EXE file to execute
if [[ ! -d "$arg_patchdir" ]]; then
  log_fatal "directory '$arg_patchdir' does not exist"
  exit 1
fi

if [[ ! -f "$arg_patchdir/$patch_exe" ]]; then
  log_fatal "expected patch EXE '$patch_exe' does not exist within directory '$arg_patchdir'"
  exit 1
fi

# Since we're running `cd` from within protontricks, we need to get the absolute
# path to the patch directory. Relative paths won't work for this since the
# shell invoked by `protontricks -c` sets its CWD to the game's directory.
# Prefer `realpath` to do the job, but if it's not available then get it by
# concatenating the user's CWD and the relative path. Simple testing shows that
# this hack does not work on Flatpak Protontricks.
patch_dir="$arg_patchdir"
if is_relpath "$arg_patchdir"; then
  if is_cmd realpath; then
    patch_dir="$(realpath "$arg_patchdir")"
  else
    log_warn "'realpath' not available as a command."
    log_warn "attempting to manually set absolute path; this might cause issues."
    log_warn "if you get an error citing a non-existent file or directory, try supplying the path to the patch directory as absolute or homedir-relative."
    patch_dir="$(pwd)/$arg_patchdir"
  fi
fi

# Patch the game
log_info "patching $gamename ..."

# Flatpak Protontricks has to be given access to the game's Steam folder to
# make changes. On Deck this is (hopefully) as easy as giving it access to all
# of its mounts and partitions; on PC, this could involve some tricky parsing
# of VDF files to give it access to different library folders.
# TODO: parse VDF files to give it access to different library folders. For
# now, FP Protontricks gives the user a prompt telling it which folder to give
# access to anyway, so it's not too big of an issue as long as the user can
# (a) read, and (b) copy and paste a single command.
compat_mts=
if [[ $is_deck ]]; then
  flatpak override --user --filesystem=/run/media/ "$fp_protontricks"
  compat_mts="STEAM_COMPAT_MOUNTS=/run/media/"
fi
[[ $is_flatpak ]] && flatpak override --user --filesystem="$patch_dir" "$fp_protontricks"

if ! $protontricks_cmd -c "cd \"$patch_dir\" && $compat_mts wine $patch_exe" $appid
then
  log_err "patch installation exited with nonzero status."
  log_err "consult the output for errors."
else
  log_info "patch installation finished, no errors signaled."
fi
stty sane  # band-aid for newline wonkiness that wine sometimes creates


# CHN CoZ patch includes custom SteamGrid images, but since the patch is built for
# Windows, the placement of those files ends up happening within the Wine prefix 
# instead of the system-level Steam install. The following code will detect the 
# STEAMGRID folder within the patch directory, and if it exists, copy any *.png 
# files at its root to Steam userdata/<user_id>/config/grid within a default Steam 
# path install ($HOME/.local/share/Steam)
#
# TODO: Add support for flatpak Steam installs.
if [[ $has_steamgrid ]]; then
  something_happened=
  log_info "copying custom SteamGrid images ..."

  for user in "$HOME"/.local/share/Steam/userdata/*; do
    if ! { mkdir -p "$user"/config/grid && cp "$patch_dir"/STEAMGRID/* "$user"/config/grid; }
    then
      log_err "error occured while installing SteamGrid files to $user/config/grid"
      something_happened=1
    fi
  done

  [[ ! $something_happened ]] && log_info "SteamGrid images installed."
fi


# S;G launches the default launcher via `Launcher.exe` for some reason instead
# of the patched `LauncherC0.exe`.
# Fix by symlinking Launcher to LauncherC0.
if [[ $needs_sgfix ]]; then
  log_info "fixing STEINS;GATE launcher issue ..."

  # Return info about symlinking process via exit code.
  # 0 means everything was fine and dandy,
  # 1 means Launcher.exe already points to LauncherC0.exe,
  # 2 means one or both of the files doesn't exist.
  sg_shcmd="$(cat << EOF
if [[ ! ( -f Launcher.exe && -f LauncherC0.exe ) ]]; then
  printf '%s\n\n%s\n' "Files in \$(pwd):" "\$(ls)"
  exit 2
fi
[[ \$(readlink Launcher.exe) == LauncherC0.exe ]] && exit 1
mv Launcher.exe Launcher.exe_bkp
ln -s LauncherC0.exe Launcher.exe
EOF
)"
  $protontricks_cmd -c "$sg_shcmd" $appid
  cmdret=$?
  case $cmdret in
    0)
      log_info "launcher symlinked successfully."
      ;;
    1)
      log_warn "Launcher.exe was already symlinked to LauncherC0.exe."
      log_warn "have you already run this script?"
      ;;
    2)
      log_err "one or both of Launcher.exe or LauncherC0.exe did not exist."
      log_err "check output for contents of the game directory."
      log_err "was the patch not installed correctly?"
      ;;
    *)
      log_warn "symlink script exited with unexpected status code $cmdret."
      log_warn "consult the output for clues."
      ;;
  esac
fi
