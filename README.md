# Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux

This project is a fork of [CoZ's official Multiversal Linux patcher](https://github.com/CommitteeOfZero/multiversal-coz-linux-patcher). From the official repository:

> These instructions and the included Bash script are intended to streamline installation of CoZ patches for Steam Play, including on Steam Deck.
>
> *This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## TL;DR

```sh
# GUI mode
./polyversal.sh

# CLI mode
./polyversal.sh <GameShortName> <PatchDir>
```

- Have [Protontricks](https://github.com/Matoking/protontricks) >= 1.10.1 or [Flatpak](https://flatpak.org/setup/) installed
- Use Proton 7 or newer
- &lt;[GameShortName](#game-short-names)&gt; is the game's abbreviation
- &lt;PatchDir&gt; is the path to the extracted patch setup directory, preferably absolute or homedir-relative
- If `./polyversal.sh` gives `Permission denied`, try `bash polyversal.sh`

## Contents

- [Backing up saved games and wiping a Proton prefix](#backing-up-saved-games-and-wiping-a-proton-prefix)
- [Preparations](#preparations)
- [Usage](#usage)
  - [GUI](#gui)
  - [CLI](#cli)
  - [Notes](#notes)
- [Game Short Names](#game-short-names)
- [Known Issues](#known-issues)
- [Troubleshooting](#troubleshooting)

## Backing up saved games and wiping a Proton prefix

If you have an existing installation of the game using a Proton version other than Valve Proton 7 (Proton 7.0-6 or later, to be specific), you will need to wipe the Proton prefix prior to beginning [preparation](#preparations). You should back up your saved games to another directory prior to wiping the prefix; this helps avoid any potential issues caused by a malfunction in the implementation of Steam Cloud saves for the title in question. You can move the saved games back into the Proton prefix after [running the patcher](#usage).

## Preparations

1. [Download the corresponding patch](https://sonome.dareno.me/projects) for your target game.
2. Extract the files from the archive and take note of the full path to the extracted directory.
    - There have been reports of Ark extracting files incorrectly; make sure the extracted directory includes a few files whose names start with "Qt5". If GUI extraction proves unsuccessful, consider using [`unzip`](https://linux.die.net/man/1/unzip).
3. This script requires [Protontricks](https://github.com/Matoking/protontricks) version 1.10.1 or newer to correctly apply the patch. If you already have this installed, you are good to go. If you do not, you can follow the link provided to install it yourself, or allow the script to install the Flatpak version.
    - To allow automatic installation of protontricks, ensure [Flatpak](https://flatpak.org/setup/) is installed on your machine and runnable by your user without root access (if you are not running SteamOS 3.x or another distro that provides Flatpak as part of the OS).
    - Steam Deck users should prefer the Flatpak version, as SteamOS is liable to delete user-installed system software without notice.
4. Download and install the related game from Steam.
5. Within the game's Properties menu, set its compatibility tool to the latest official Valve Proton 7 (Proton 7.0-6 at time of writing).
6. Launch the game once in order to generate a Proton prefix, then quit the game.
7. Download and extract [the latest release of the script](https://github.com/Macitron/Polyversal-Linux-CoZ-Patcher/releases).
    - You can also clone this repo or download a copy under the Code button at the top of the page if you want to use the latest (unstable) development version. [Here be dragons](https://en.wikipedia.org/wiki/Here_be_dragons).
8. Navigate to the folder containing these files using the terminal emulator of your choice.
    - [Konsole](https://youtu.be/t4w0A6ICs0E) is the default for Steam Deck.

## Usage

This script features both a GUI and a CLI mode; the easiest option for most people will likely be the GUI mode.

### GUI

To run the script in GUI mode, simply invoke it with no arguments.

```sh
./polyversal.sh
```

During execution, two pop-ups will appear for you to specify the target game and the location of the directory containing the patch.

### CLI

To run the script in CLI mode, invoke it with two arguments as shown below, replacing &lt;GameShortName&gt; with the short name from [the list below](#game-short-names) and &lt;PatchDirectory&gt; with the path to the folder containing the patch.

```sh
./polyversal.sh <GameShortName> <PatchDirectory>

# Examples:
./polyversal.sh chn ~/Downloads/CHNSteamPatch-v1.0.2-Setup
./polyversal.sh sg0 /home/myname/Games/SG0/SG0Patch-v2.1.3-Setup
```

Relative paths are accepted but not guaranteed to work, especially when using Flatpak.[^relpaths] Absolute or homedir-relative paths should be preferred.

### Notes

All instances of `./polyversal.sh` can be replaced with `bash polyversal.sh`. If the first form does nothing and says "`Permission denied`", try the second form.

The script will prefer to use a system install of Protontricks, if present, over Flatpak since there are less points of failure.

If you're using Flatpak and have the game in a non-default Steam library folder, Flatpak might complain about not having access permissions. It will spit out a command as part of its output; copy and paste this command in the terminal to grant it the required access and run the script again to resolve this issue.

If you have an outdated version of Protontricks installed via Flatpak, it will be updated automatically. If for some arcane reason you need a specific, old version installed, be aware that you will have to downgrade after this script completes.

As part of the execution of this script, a GUI for the actual patch installer should launch. Follow the instructions in the interface to install the patch. If asked for an installation directory by the installer, use: `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing &lt;Username&gt; with your Linux username and &lt;Game&gt; with the name of the folder containing the game.

For example, on the Steam Deck: `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.

Then, go back to Steam and launch the game. It should now be patched. Confirm that it launches the patched CoZ launcher with a black background.

The official repository offers the following warning:
> Executing this script renders the terminal that ran the commands unable to run any further commands&mdash;on both Arch Linux and SteamOS 3.x on the Steam Deck. This is expected behavior. If you close the terminal after execution and open a new one, you will be able to access the terminal once more. Of course, after the successful installation of the patch, the terminal is unnecessary to run the patched game.

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

Some variations like 'dash' are supported; consult the script itself for a full list.

## Known Issues

### Steins;Gate Symlinks

The installation of the *Steins;Gate* patch involves some additional symlinking to fix an issue related to the game's launcher. These changes are **not** automatically undone during uninstallation via `nguninstall.exe`, so they must be done manually. Fortunately, this is as simple as copying and pasting the command below. **To avoid potential issues, make sure to run this *before* uninstalling the patch,** if you decide to do so :(

```sh
# If using flatpak, replace `protontricks` with
# `flatpak run com.github.Matoking.protontricks`
protontricks -c 'unlink Launcher.exe && mv Launcher.exe_bkp Launcher.exe' 412830
```

### Hanging Wine Processes

A wine process is spawned in the course of running the script for the purpose of running the actual patch installer. On completion, this process appears to be left orphaned; this can be observed using `top` or similar.[^winehang] It is unknown why this happens, and its impact on the system is negligible at most, but it warrants notice nonetheless in case you want to manually terminate it.

## Troubleshooting

If you run into any problems executing the Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux, please feel free to file an issue or pull request in relation. **Please do not complain to the Committee of Zero directly**: if you need someone to yell at, ping `Macitron3000#0766` on Discord.

The PLSPfCoZSASPoL has been tested on Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.

[^relpaths]: Specifically, relative paths fail to work in the case when Flatpak Protontricks is being used and `realpath` is not available as a command. Steam Deck does have `realpath` available, so in most use cases it should be fine.

[^winehang]: Phenomenon observed on Arch Linux, kernel 6.2.6-arch1-1. I noticed this one day after doing multiple test runs and finding ~25 orphaned wine processes on btop.
