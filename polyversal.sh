#!/usr/bin/env bash

## Constants ##

progname="$(basename "$0")"
readonly progname

# Protontricks 1.10.1 or later is needed because anything earlier gives a
# cryptic message about magic numbers.
ptx_flatpak='com.github.Matoking.protontricks'
ptx_minversion='1.10.1'
readonly ptx_flatpak
readonly ptx_minversion

# For log files and the like, all hail ISO 8601.
# People likely won't be running this more than once in a second.
exectime=$(date +%Y%m%dT%H%M%S)
readonly exectime


## Functions ##

function print_usage() {
  cat << EOF >&2
usage: polyversal.sh [ -v | --verbose ] [ -h | --help ] [ -d | --desktop ]
                     [ --log ] ...

Use a GUI for selecting the game and patch folder.
$ $progname

Patch game with abbreviation GAME_ABBREV and CoZ patch in PATCH_FOLDER.
$ $progname GAME_ABBREV PATCH_FOLDER

Game abbreviations:
  chn
  sg
  rne
  cc
  sg0
  rnd

options:
  -h, --help                Display this help message and exit
  -v, --verbose             Enable debug logging
  -d, --desktop             Disable terminal output and redirect stdin/stderr to
                            a new log file in 'logs'. This is the default when
                            running from the desktop file

  --log                     Copy terminal output to a new file log in
                            'logs'. Disables terminal colors

EOF
}

# I like colors. Only use them if stderr outputs to a terminal which supports 8
# or more colors.
# Pulled into a function that we can call later since --desktop or similar
# options might change stderr.
txt_normal=''
txt_green=''
txt_yellow=''
txt_red=''
txt_purple=''
txt_blue=''
function set_logcolors() {
  if ! test -t 2 || [[ ! $(tput colors) -ge 8 ]]; then return; fi
  txt_normal="$(tput sgr0)"
  txt_green="$(tput setaf 2)"
  txt_yellow="$(tput setaf 3)"
  txt_red="$(tput setaf 1)"
  txt_purple="$(tput setaf 5)"
  txt_blue="$(tput setaf 4)"
}

function log_msg() {
  local sevpfx
  case $(tolower "$1") in
    'info' | 'i')
      sevpfx="${txt_green}INFO"  ;;
    'warn' | 'w')
      sevpfx="${txt_yellow}WARN" ;;
    'error' | 'err' | 'e')
      sevpfx="${txt_red}ERR" ;;
    'fatal' | 'fat' | 'f')
      sevpfx="${txt_purple}FATAL"  ;;
    'debug' | 'd')
      sevpfx="${txt_blue}DEBUG" ;;
    *)
      # Better than dying for no reason
      sevpfx="$1"  ;;
  esac

  printf '%s: %s: %s\n' "$progname" "$sevpfx" "${*:2}${txt_normal}" >&2
}
function log_info() { log_msg info "$*"; }
function log_warn() { log_msg warn "$*"; }
function log_err() { log_msg err "$*"; }
function log_fatal() { log_msg fatal "$*"; }
function log_debug() {
  ! $mode_debug && return 0
  log_msg debug "$*"
}

# Want `./polyversal.sh chn` and `./polyversal.sh CHN` to work the same
function tolower() {
  printf '%s' "$*" | tr '[:upper:]' '[:lower:]'
}

# `command -v COMMAND` prints information about COMMAND, but importantly has
# exit status 0 if the command exists and 1 if it does not. This true/false
# value is what we use in this script to determine whether a command is
# installed and available on the system.
function is_cmd() {
  command -v "$1" > /dev/null
}

# Shadows any call to zenity so we don't accidentally forget an $is_gui
function zenity() {
  ! $is_gui && return 0
  command zenity "$@"
}

# Happens often enough to warrant a function
function zenity_error() {
  zenity --error --title "Polyversal Error" --text "$*"
}

# Handle non-zero exit statuses from Zenity.
# **Must be called immediately after zenity command.**
# Single optional argument is the message to be displayed in the case that the
# user closes the window.
function handle_zenity() {
  local zen_ret=$?
  local closedmsg="$*"
  [[ ! $closedmsg ]] && closedmsg="You must select an option."
  case $zen_ret in
    1)
      log_fatal "Zenity window was closed while prompting for selection."
      zenity_error "$closedmsg"
      exit 1 ;;
    5)
      log_fatal "Zenity dialogue timed out while prompting for selection."
      zenity_error "The input dialogue timed out."
      exit 1 ;;
    -1)
      log_fatal "Zenity returned an unexpected error"
      zenity_error "An unexpected error occurred using Zenity."
      exit 1 ;;
  esac
}

# Determines if Protontricks is up to date, i.e. $ptx_minversion or later.
# Single argument is which Protontricks to check:
# 'fp' = Flatpak, 'sys' = system install
# Other arguments don't do anything. Don't use them!
# is_ptxvalid <fp|sys>
function is_ptxvalid() {
  local ptx_cmd
  case $1 in
    fp)
      ptx_cmd="flatpak run $ptx_flatpak"  ;;
    sys)
      ptx_cmd="protontricks"  ;;
  esac

  # Decent way to check it's actually functional.
  local cur_ver
  ! cur_ver=$($ptx_cmd --version) && return 1

  local older_ver
  older_ver=$(printf '%s\n%s\n' "protontricks ($ptx_minversion)" "$cur_ver" | sort -V | head -n 1)

  [[ $older_ver == "protontricks ($ptx_minversion)" ]]
}


log_info "Starting Polyversal Patcher on $(date) ..."


## Option Parsing ##

if ! parsed_args=$(getopt -n "$progname" -o 'hvd' --long 'help,verbose,desktop,log' -- "$@"); then
  log_fatal "error parsing command line arguments"
  print_usage
  exit 1
fi
eval set -- "$parsed_args"

mode_debug=false
mode_desktop=false
mode_filelog=false
while true; do
  case "$1" in
    -v | --verbose)
      mode_debug=true
      shift ;;
    -h | --help)
      print_usage
      exit 0  ;;
    # Actual mode will be determined by the last one to be called in the command.
    -d | --desktop)
      mode_desktop=true
      mode_filelog=false
      shift ;;
    --log)
      mode_filelog=true
      mode_desktop=false
      shift ;;
    --)
      shift
      break ;;
    *)
      log_fatal "Unexpected option '$1', this should never happen"
      print_usage
      exit 1  ;;
  esac
done

# mode_desktop and mode_filelog both log to a file, but desktop disables
# terminal output while filelog does not. Logging is output to a new .log file
# within 'logs/' under the same directory as this script.
logdir="$(dirname "$0")"/logs
logname="${logdir}/polyversal-${exectime}"  # minus the .log so we can add -wine
if $mode_desktop; then
  mkdir -p "$logdir"
  exec > "${logname}.log" 2>&1
fi
if $mode_filelog; then
  # https://stackoverflow.com/questions/3173131/redirect-copy-of-stdout-to-log-file-from-within-bash-script-itself
  mkdir -p "$logdir"
  exec >  >(tee -ia "${logname}.log")
  exec 2> >(tee -ia "${logname}.log" >&2)
fi

set_logcolors


## Argument Processing ##

# GUI mode: 0 args
# CLI mode: 2 args (game, dir)
is_gui=false
if [[ $# -eq 0 ]]; then
  if ! is_cmd zenity; then
    log_fatal "Zenity is required to run this script in GUI mode. Please make sure you have it installed, or use the CLI."
    print_usage
    exit 1
  fi
  is_gui=true
elif [[ $# -ne 2 ]]; then
  log_fatal "Invalid syntax"
  print_usage
  exit 1
fi

arg_game=
arg_patchdir=
if $is_gui; then
  arg_game=$(zenity --list --radiolist --title "Choose Which Game to Patch" \
      --height 400 --width 600            \
      --column "Select" --column "Title"  \
      TRUE  'Chaos;Head NoAH'             \
      FALSE 'Steins;Gate'                 \
      FALSE 'Robotics;Notes Elite'        \
      FALSE 'Chaos;Child'                 \
      FALSE 'Steins;Gate 0'               \
      FALSE 'Robotics;Notes DaSH')
  handle_zenity "You must select which game to patch for the script to work."

  arg_patchdir=$(zenity --file-selection --title "Choose Patch Directory for $arg_game" \
      --directory --filename "$HOME/Downloads")
  handle_zenity "You must select the directory containing the patch for the script to work."
else
  arg_game="$1"
  arg_patchdir="$2"
fi

# Get the app ID and what the installer exe should be, based on the shortname.
# IDs are available in the README.
# CoZ's naming conventions are beautifully consistent, pls never change them
appid=
patch_exe=
gamename=
has_steamgrid=false
needs_sgfix=false
case $(tolower "$arg_game") in
  'chn' | 'ch' | 'chaos'[\;\ ]'head noah')
    appid=1961950
    patch_exe='CHNSteamPatch-Installer.exe'
    gamename="Chaos;Head NoAH"
    has_steamgrid=true
    ;;
  'sg' | 'steins'[\;\ ]'gate')
    appid=412830
    patch_exe='SGPatch-Installer.exe'
    gamename="Steins;Gate"
    needs_sgfix=true
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
$has_steamgrid && log_info "using custom SteamGrid images ..."

# Make sure the patch directory ($arg_patchdir) is valid.
# "Valid" here means:
# (1) it exists, and
# (2) it contains the expected patch EXE file to execute
if [[ ! -d $arg_patchdir ]]; then
  log_fatal "directory '$arg_patchdir' does not exist"
  zenity_error "Specified directory '$arg_patchdir' does not exist. Please try again."
  exit 1
fi

if [[ ! -f "$arg_patchdir/$patch_exe" ]]; then
  log_fatal "expected patch EXE '$patch_exe' does not exist within directory '$arg_patchdir'"
  zenity_error "Directory '$arg_patchdir' does not contain expected EXE '$patch_exe', please try again. Make sure to select the extracted CoZ patch folder containing this file."
  exit 1
fi

# Since we're running `cd` from within protontricks, we need to get the absolute
# path to the patch directory. Relative paths won't work for this since the
# shell invoked by `protontricks -c` sets its CWD to the game's directory.
# Prefer `realpath` to do the job, but if it's not available then get it by
# concatenating the user's CWD and the relative path. Simple testing shows that
# this hack does not work with the double-dot (..) on Flatpak Protontricks.
patch_dir="$arg_patchdir"

# only relative if it doesn't start with '/'
if [[ ! $arg_patchdir =~ ^/ ]]; then
  log_warn "got relative path for patch directory"

  # the '!' catches if realpath doesn't exist or some other permission error
  if ! patch_dir=$(realpath "$arg_patchdir"); then
    log_error "error using 'realpath' to set absolute path patch directory"
    log_warn "attempting to set absolute path manually, this might cause issues ..."
    patch_dir="$(pwd)/$arg_patchdir"
  fi
fi


## Protontricks Setup ##

# Detect whether the machine is a Steam Deck.
is_deck=false
if grep -qE '^VERSION_CODENAME=holo' /etc/os-release; then
  is_deck=true
  log_info "detected Steam Deck environment ..."
fi

# We need Protontricks either through a system install or through Flatpak to
# work the magic. Prefer system install since it plays nice with relative dirs
# and doesn't need permissions to be setup, but if it's unavailable or outdated
# then use Flatpak.
ptx_cmd='protontricks'
is_flatpak=false
if is_cmd protontricks && is_ptxvalid sys; then
  log_info "detected valid system install of protontricks ..."
else
  if is_cmd protontricks; then
    log_warn "system install of protontricks has insufficient version: $(protontricks --version) < $ptx_minversion"
  else
    log_info "system install of protontricks not found"
  fi

  log_info "proceeding with flatpak ..."

  # Nothing doing if no flatpak :(
  if ! is_cmd flatpak; then
    log_fatal "either flatpak nor valid system install of protontricks was detected"
    zenity_error "Neither Flatpak nor system Protontricks >= $ptx_minversion was found. Please install one of the two and then try again."
    exit 1
  fi

  # Install protontricks if it's not already
  if ! flatpak list | grep -q "$ptx_flatpak" -; then
    log_warn "protontricks is not installed on flatpak. attempting installation ..."
    if ! flatpak install -y "$ptx_flatpak"; then
      log_fatal "error occurred while installing flatpak protontricks"
      zenity_error "An error occurred while installing Protontricks via Flatpak."
      exit 1
    fi
    log_info "flatpak protontricks installed successfully"
  fi

  # Has to have version >= $ptx_minversion
  if ! is_ptxvalid fp; then
    log_warn "flatpak protontricks out-of-date: $(flatpak run $ptx_flatpak --version) < $ptx_minversion. attempting to update ..."
    if ! flatpak update -y "$ptx_flatpak"; then
      log_fatal "error occurred while updating flatpak protontricks"
      zenity_error "An error occurred while updating Flatpak Protontricks."
      exit 1
    fi
    log_info "flatpak protontricks updated successfully"
  fi

  is_flatpak=true
  ptx_cmd="flatpak run $ptx_flatpak"
fi

# Flatpak Protontricks has to be given access to the game's Steam folder to
# make changes. On Deck this is (hopefully) as easy as giving it access to all
# of its mounts and partitions; on PC, this could involve some tricky parsing
# of VDF files to give it access to different library folders.
# TODO: parse VDF files to give it access to different library folders. For
# now, FP Protontricks gives the user a prompt telling it which folder to give
# access to anyway, so it's not too big of an issue as long as the user can
# (a) read, and (b) copy and paste a single command.
compat_mts=
if $is_deck; then
  flatpak override --user --filesystem=/run/media/ "$ptx_flatpak"
  compat_mts="STEAM_COMPAT_MOUNTS=/run/media/"
fi
$is_flatpak && flatpak override --user --filesystem="$patch_dir" "$ptx_flatpak"


## Game Patching ##

log_info "patching $gamename ..."
zenity --timeout 10 --info --title 'Info' \
    --text "$(printf 'Running patcher ...\n(This will disappear in 10 seconds)')" &

ptx_winecmd='$ptx_cmd -c "cd \"$patch_dir\" && $compat_mts wine $patch_exe" $appid'
if $mode_desktop || $mode_filelog; then
  ptx_winecmd+=' > ${logname}-wine.log 2>&1'
fi
if ! eval "$ptx_winecmd"
then
  log_err "patch installation exited with nonzero status"
  zenity_error "Patch installation exited with a nonzero status. Script execution will continue; be wary of errors and check the output for information."
else
  log_info "patch installation finished, no errors signaled."
fi
test -t 0 && stty sane  # band-aid for newline wonkiness that wine sometimes creates

# CHN CoZ patch includes custom SteamGrid images, but since the patch is built for
# Windows, the placement of those files ends up happening within the Wine prefix 
# instead of the system-level Steam install. The following code will detect the 
# STEAMGRID folder within the patch directory, and if it exists, copy any *.png 
# files at its root to Steam userdata/<user_id>/config/grid within a default Steam 
# path install ($HOME/.local/share/Steam)
#
# TODO: Add support for flatpak Steam installs.
if $has_steamgrid; then
  has_users=false
  copies_fine=true
  log_info "copying custom SteamGrid images ..."

  # Don't iterate over userdata/*/config/grid because it might not exist.
  for userdir in "$HOME"/.local/share/Steam/userdata/*; do
    has_users=true
    griddir="$userdir/config/grid"
    log_debug "installing SteamGrid in $griddir ..."

    if ! { mkdir -p "$griddir" && cp "$patch_dir"/STEAMGRID/* "$griddir"; }
    then
      copies_fine=false
      log_err "error occured while installing SteamGrid files to $griddir"
    fi
  done

  if ! $has_users; then
    log_error "no users were found in $HOME/.local/share/Steam/userdata"
    zenity_error "No users were found in $HOME/.local/share/Steam/userdata, unable to install custom SteamGrid images."
  elif $copies_fine; then
    log_info "SteamGrid images installed successfully"
  fi
fi

# S;G launches the default launcher via `Launcher.exe` for some reason instead
# of the patched `LauncherC0.exe`.
# Fix by symlinking Launcher to LauncherC0.
if $needs_sgfix && sg_gamedir=$($ptx_cmd -c 'pwd' 412830); then
  log_info "fixing S;G launcher issue ..."

  if [[ ! ( -f "$sg_gamedir"/Launcher.exe && -f "$sg_gamedir"/LauncherC0.exe ) ]]; then
    log_error "one or both of Launcher/C0.exe not found in S;G game directory, unable to fix launcher"
    zenity_error "Steins;Gate's game directory did not contain one or both of 'Launcher.exe' or 'LauncherC0.exe', unable to apply launcher fix. Was the patch installed correctly?"
  elif [[ $(readlink "$sg_gamedir"/Launcher.exe) == LauncherC0.exe ]]; then
    log_warn "Launcher.exe was already symlinked to C0, has this script already been run?"
  else
    mv "$sg_gamedir"/Launcher.exe "$sg_gamedir"/Launcher.exe_bkp
    ln -s LauncherC0.exe "$sg_gamedir"/Launcher.exe
    log_info "S;G launcher symlinked"
  fi
elif $needs_sgfix; then
  log_error "protontricks error while getting S;G game directory"
  zenity_error "Protontricks gave an error before the launcher issue could be fixed. Check the output for more information."
fi

log_info 'Success! Completed without any script-breaking issues. Enjoy the game.'
zenity --info --title 'Polyversal Success!' \
    --text 'Patch installation for '"$gamename"' finished. Please verify that the patch is working in case anything went wrong under the hood. Enjoy the game!'
