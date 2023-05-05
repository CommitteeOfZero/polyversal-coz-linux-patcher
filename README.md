# The Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux

This project is a fork of [the Committee of Zero's official Multiversal Linux patcher](https://github.com/CommitteeOfZero/multiversal-coz-linux-patcher) and aims to provide extended functionality with error checking, a simple GUI, and automation of game-specific fixes, among other things.

From the official repository:

> These instructions and the included Bash script are intended to streamline installation of CoZ patches for Steam Play, including on Steam Deck.
>
> *This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## TL;DR

Double-click on the provided desktop entry, or invoke the script in one of the following ways:

```sh
# GUI mode
./polyversal.sh

# CLI mode
./polyversal.sh <GameAbbrev> <PatchDir>
```

- Have [Protontricks](https://github.com/Matoking/protontricks) >= 1.10.1 or [Flatpak](https://flatpak.org/setup/) installed
- Use Proton 7
- &lt;GameAbbrev&gt; is the game's [short name](#game-short-names)
- &lt;PatchDir&gt; is the path to the extracted patch setup directory, preferably absolute or homedir-relative

## Contents

- [Backing up saved games and wiping a Proton prefix](#backing-up-saved-games-and-wiping-a-proton-prefix)
- [Preparations](#preparations)
- [Usage](#usage)
  - [GUI](#gui)
  - [CLI](#cli)
  - [General](#general)
  - [Command Line Options](#command-line-options)
- [Notes](#notes)
- [Game Short Names](#game-short-names)
- [Known Issues](#known-issues)
- [Troubleshooting](#troubleshooting)

## Backing up saved games and wiping a Proton prefix

If you have an existing installation of the game using a Proton version other than Valve Proton 7 (Proton 7.0-6 or later, to be specific), you will need to wipe the Proton prefix prior to beginning [preparation](#preparations). You should back up your saved games to another directory prior to wiping the prefix; this helps avoid any potential issues caused by a malfunction in the implementation of Steam Cloud saves for the title in question. You can move the saved games back into the Proton prefix after [running the patcher](#usage).

## Preparations

1. Download and extract [the CoZ patch for your target game](https://sonome.dareno.me/projects).
    - Choose the Steam version if given options (i.e. between GOG/Switch).
    - There have been reports of Ark extracting files incorrectly; make sure the extracted directory includes a few files whose names start with "Qt5". If GUI extraction proves unsuccessful, consider using [`unzip`](https://linux.die.net/man/1/unzip).
1. This script requires [Protontricks](https://github.com/Matoking/protontricks) version 1.10.1 or newer to correctly apply the patch. If you do not already have this installed, you can either allow the script to install it via [Flatpak](https://flatpak.org/setup/) or [install it yourself](https://github.com/Matoking/protontricks#installation).
    - Steam Deck users should prefer the Flatpak version, as SteamOS is liable to delete user-installed system software without notice. The Deck comes with Flatpak pre-installed.
    - If you are not using SteamOS 3.x (Deck) or another distro that provides Flatpak as part of the OS, ensure Flatpak is installed on your machine and runnable by your user without root access.
1. Download and install your target game from Steam.
1. Within the game's Properties menu, set its compatibility tool to Proton 7[^proton8].
1. Launch the game once in order to generate a Proton prefix, then quit the game.
1. Download and extract [the latest release of this script](https://github.com/Macitron/Polyversal-Linux-CoZ-Patcher/releases).
    - You can also clone this repo or download a copy under the Code button at the top of the page if you want to use the latest (unstable) development version. [Here be dragons](https://en.wikipedia.org/wiki/Here_be_dragons).
1. Navigate to the folder containing these files in your file browser.

## Usage

This script features both a GUI mode and a CLI mode. The easiest option for most people will likely be the GUI.

If you're running it from the command line (i.e. not clicking the `.desktop` file), you must first navigate to the script's folder with the terminal. On KDE and Steam Deck this can be done by right-clicking on the folder in the file browser and selecting "Open Terminal Here".

### GUI

There are two ways to launch the GUI: double-clicking on the provided `Polyversal.desktop` entry, and running from the command line.

The easier option is to simply click on the desktop file, but this is not guaranteed to work on all systems. It will likely function on KDE and Steam Deck but has been known to instead open a text editor on at least one GNOME installation.

To run from the command line, simply invoke it with no arguments like so:

```sh
./polyversal.sh
```

Once launched (via either method), two initial pop-ups will appear for you to specify the target game and the location of the directory containing the patch. More windows will appear throughout the script's execution to signal errors or successes.

You'll know the script has started successfully when you see the following window:

![Image of a Zenity list selection.](/assets/gui1-deck.png "The first window")

### CLI

To run the script in CLI mode, invoke it with two arguments as shown below, replacing &lt;GameShortName&gt; with the short name from [the list below](#game-short-names) and &lt;PatchDirectory&gt; with the path to the folder containing the patch.

```sh
./polyversal.sh <GameShortName> <PatchDirectory>

# Examples:
./polyversal.sh chn ~/Downloads/CHNSteamPatch-v1.0.2-Setup
./polyversal.sh sg0 /home/myname/Games/SG0/SG0Patch-v2.1.3-Setup
```

Relative paths are accepted but not guaranteed to work, especially when using Flatpak.[^relpaths] Absolute or homedir-relative paths should be preferred.

### General

The following info is pertinent regardless of how you launched the script.

- During execution, a GUI for the actual patch installer should launch. Follow the instructions in the interface to install the patch.

    ![Image of the actual CoZ patcher GUI.](/assets/coz-gui.png "Still gotta finish this game")

  - If asked for an installation directory by the installer, use `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing &lt;Username&gt; with your Linux username and &lt;Game&gt; with the name of the folder containing the game. For example, Chaos;Head NoAH on the Steam Deck would be `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.

- Reaching the 'Success!' message at the end of the script does not necessarily mean the patch was applied successfully. Due to the nature of the Wine layer, it can unfortunately be difficult to automatically determine a program's success.

  - Be sure to verify that the patch is actually active upon booting up the game.
  <!-- TODO: Specifics go here, link to Chris' tweet about the noids and mention the mouse and whatnot -->

### Command Line Options

The following options are available when invoking the script from the terminal.

- `-h | --help`
  - Print a usage message and exit.
- `-v | --verbose`
  - Log `DEBUG`-level messages to output.
- `-d | --desktop`
  - Disable all output to the terminal and redirect to a log file in `./logs/`. Creates the directory if it does not exist.
  - This is the default when launching via the `.desktop` entry, hence the name.
  - If `--desktop` and `--log` are both passed, the one that appears last will take precedence.
- `--log`
  - Copy terminal output to a log file in `./logs/`. Unlike `--desktop`, it does not disable all terminal output, but it does disable terminal colors.
  - If `--desktop` and `--log` are both passed, the one that appears last will take precedence.

## Notes

- The script will prefer to use a system install of Protontricks over Flatpak, if present, since there are fewer points of failure.

- If you're using Flatpak and have the game in a non-default Steam library folder, Flatpak might complain about not having access permissions. It will spit out a command as part of its output: copy and paste this command in the terminal to grant it the required access and run the script again to resolve this issue.

- Flatpak Protontricks will be updated automatically if it's outdated. So, if for some arcane reason you need a specific older version installed, be aware that you will have to downgrade after this script completes.

- If you *really* know what you're doing, you could turn this into a proper desktop application by modifying `Polyversal.desktop`'s "Exec" line to run the script from a static location and install it to `~/.local/share/applications`, or whever your `$XDG_DATA_HOME` points to.

## Game Short Names

Here you can find a table of all the SciADV games which have received patches and their corresponding short name required by the script's CLI mode. The app ID is also provided as a quick reference for compatdata folders.

| **Game**              | **Short Name** | **App ID** |
| ----------------      |:--------------:|:----------:|
| Chaos;Head NoAH       |      chn       | 1961950    |
| Steins;Gate           |       sg       | 412830     |
| Robotics;Notes Elite  |      rne       | 1111380    |
| Chaos;Child           |       cc       | 970570     |
| Steins;Gate 0         |      sg0       | 825630     |
| Robotics;Notes DaSH   |      rnd       | 1111390    |

Some variations like 'dash' are supported. Consult the script itself for a full list.

## Known Issues

### Steins;Gate Symlinks

The installation of the *Steins;Gate* patch involves some additional symlinking to fix an issue related to the game's launcher. These changes are **not** automatically undone during uninstallation via `nguninstall.exe`, so they must be done manually. Fortunately, this is as simple as copying and pasting the command below. **To avoid potential issues, make sure to run this *before* uninstalling the patch,** if you decide to do so :(

```sh
# If using flatpak, replace `protontricks` with
# `flatpak run com.github.Matoking.protontricks`
protontricks -c 'unlink Launcher.exe && mv Launcher.exe_bkp Launcher.exe' 412830
```

### Hanging Wine Processes

A wine process is spawned in the course of running the script for the purpose of running the actual patch installer. On completion, this process sometimes appears to be left orphaned; this can be observed using `top` or similar.[^winehang] It is unknown why this happens, and its impact on the system is negligible at most, but it warrants notice nonetheless in case you want to manually terminate it.

## Troubleshooting

If you run into any problems executing the Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux, please feel free to file an issue or pull request in relation. **Please do not complain to the Committee of Zero directly**: if you need someone to yell at, ping `Macitron3000#0766` on Discord.

The PLSPfCoZSASPoL has been tested on Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.

[^relpaths]: Specifically, relative paths fail on Flatpak Protontricks when they contain a double-dot (`..`) and the `realpath` utility is not available as a command. In practice, though, `realpath` is incredibly common and is installed by default on SteamOS, so this should hardly ever be an issue.

[^winehang]: Phenomenon observed on Arch Linux, kernel 6.2.6-arch1-1. I noticed this one day after doing multiple test runs and finding ~25 orphaned wine processes on btop, seems like it might just affect Proton Experimental versions.

[^proton8]: Proton 8 and Experimental are currently broken for all relases of Protontricks. This has been fixed if you build your Protontricks from the latest commit (e.g. AUR git version), but it's safer to just use Proton 7.
