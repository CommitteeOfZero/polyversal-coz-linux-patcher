# The Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux

These instructions and the included Bash script are intended to streamline installation of CoZ patches for Steam Play, including on Steam Deck.

This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).

## TL;DR

For those who already know what they're doing. If you don't, welcome! The [table of contents](#contents) is a good place to start.

```bash
## GUI mode ##
./polyversal  # or `bash polyversal`

## CLI mode ##
./polyversal install <game name> <patch dir>  # install patch
./polyversal uninstall <game name>            # undo installed patch
```

You can also directly launch the GUI by double-clicking the included .desktop entry, if it works. ([It might not.](#inconsistency-using-the-desktop-file))

- `<game name>` is the game's [shortname identifier](#game-short-names)
- `<patch dir>` is the path to the extracted CoZ patch directory
- Either [Flatpak](https://flatpak.org/setup/) or a system install of [Protontricks](https://github.com/Matoking/protontricks#installation) >= 1.10.1 is required
- Use Proton 7; 8+ is unsupported for now

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

If you have an existing installation of the game using a Proton version other than Valve Proton 7 (Proton 7.0-6 or later, to be specific), you will need to wipe the Proton prefix prior to beginning [preparation](#preparations). You should back up your saved games to another directory prior to wiping the prefix; this helps avoid any potential issues caused by a malfunction in the implementation of Steam Cloud saves for the title in question. You can move the saved games back into the Proton prefix after [running the script](#usage).

## Preparations

1. Download and extract[^extraction] the [CoZ patch for your target game](https://sonome.dareno.me/projects).
    - Choose the Steam version if given options (i.e. between GOG/Switch).
1. This script requires either [Flatpak](https://flatpak.org/setup/) or a system install of [Protontricks](https://github.com/Matoking/protontricks#installation) 1.10.1 or newer to apply the patches.
    - The Steam Deck comes with Flatpak pre-installed and is good to go out of the box.
1. Download and install your target game from Steam.
1. Within the game's Properties menu, set its compatibility tool to Proton 7[^proton8].
1. Launch the game once in order to generate a Proton prefix, then quit the game.
1. Download and extract [the latest release of this script](https://github.com/CommitteeOfZero/multiversal-coz-linux-patcher/releases).
    - You can also clone this repo or download a copy under the Code button at the top of the page if you really want to use the latest (unstable) commit. [Here be dragons.](https://en.wikipedia.org/wiki/Here_be_dragons)
1. Navigate to the folder containing these files in your distro's file manager.

**A quick note on terminology**: Any time we mention "the script", we are referring to *this* script, the Polyversal Patcher, the one you're reading instructions for right now. When we mention "the patch" or "the patcher", we are referring to the actual Committee of Zero patch, the one that you downloaded from the official website with all the `.dll`'s and `.exe`'s inside.

## Usage

This script features both a GUI (Graphical User Interface) mode and a CLI (Command Line Interface) mode. The GUI will likely be the easier option for most.

### GUI

There are two ways to launch the GUI: using the provided `Polyversal.desktop` entry, and running it from the command line.

The easier option is to simply double-click the desktop file to launch it, but this is not guaranteed to work on all systems; see the section on [known issues](#inconsistency-using-the-desktop-file). If it doesn't work, you'll have to launch it from the command line. (It's not as scary as it sounds!)

To run from the command line, first open a terminal in the directory containing the script. On KDE and Steam Deck, you can do so by right-clicking on `polyversal` from within Dolphin and selecting "Open Terminal Here".

![Image of the "Open Terminal Here" dialog.](/assets/open-term-here.png)

Once the terminal is open, simply invoke it with no arguments by typing the below command and hitting Enter:

```sh
./polyversal
```

Once launched (via either method), some selection pop-ups will appear with more windows showing up throughout the script's execution to signal errors or successes.

You'll know the script has started successfully when you see the following window:

![Image of a Zenity list selection.](/assets/first-screen.png "The first window")

### CLI

To run the script in CLI mode, invoke it in one of the two forms below, replacing `<game name>` with a shortname identifier from [the list below](#game-short-names) and `<patch dir>` with the path to the folder containing the CoZ patch.

```sh
# Install a patch
./polyversal install <game name> <patch dir>

# Uninstall a patch
./polyversal uninstall <game name>

# Examples:
./polyversal install chn ~/Downloads/CHNSteamPatch-v1.0.2-Setup
bash polyversal inst sg0 /home/myname/Games/SG0/SG0Patch-v2.1.3-Setup
./polyversal uninstall dash
```

Relative paths are accepted but not guaranteed to work, especially when using Flatpak.[^relpaths] Absolute or homedir-relative paths should be preferred.

### General

The following info is pertinent regardless of how you launched the script.

- During execution, a GUI for the actual patch installer should launch. Follow the instructions in the interface to install the patch.

    ![Image of the actual CoZ patcher GUI.](/assets/coz-gui.png "Still gotta finish this game")

  - If asked for an installation directory by the installer, use `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing &lt;Username&gt; with your Linux username and &lt;Game&gt; with the name of the folder containing the game. For example, Chaos;Head NoAH on the Steam Deck would be `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.
  - If you have your game installed in a non-standard library location, hopefully you can remember where you set it up well enough to know the path.

- Reaching the 'Success!' message at the end of the script does not necessarily mean the patch was applied successfully. Due to the nature of the Wine layer, it can unfortunately be difficult to automatically determine a program's success.

  - Be sure to verify that the patch is actually active upon booting up the game.
  <!-- TODO: Specifics go here, link to Chris' tweet about the noids and mention the mouse and whatnot -->

### Command Line Options

The following options are available when invoking the script from the terminal.

- `-h | --help`
  - Print a usage message and exit.
- `-v | --verbose`
  - Log `DEBUG`-level messages to output.
- `--desktop`
  - Disable all output to the terminal and redirect to a log file in `./logs/`. Creates the directory if it does not exist.
  - This is the default when launching via the `.desktop` entry, hence the name.
  - If `--desktop` and `--log` are both passed, the one that appears last will take precedence.
- `--log`
  - Copy terminal output to a log file in `./logs/`. Unlike `--desktop`, it does not disable all terminal output, but it does disable terminal colors.
  - If `--desktop` and `--log` are both passed, the one that appears last will take precedence.

## Notes

- The script will prefer to use a system install of Protontricks over Flatpak, if present, since there are fewer points of failure.

- If you're using Flatpak and have the game installed in a non-default Steam library folder, Flatpak might complain about not having access permissions. If the script fails, check the output/logs for a message from Flatpak telling you exactly what command to copy+paste in order to do so.

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

### Inconsistency Using the `.desktop` File

It seems to be a coin toss whether the included .desktop entry will actually launch the script or open it in the default text editor. If it opens a bunch of monospaced text that starts with `[Desktop Entry]`, you will have to launch from the command line.

There have also been at least two documented cases of the script launching and appearing to complete successfully, but then the game is not patched on startup. It is unknown why this happens, and if it happens to you then launching from the command line will likely fix it.

### Hanging Wine Processes

A wine process is spawned in the course of running the script for the purpose of running the actual patch installer. On completion, this process sometimes appears to be left orphaned; this can be observed using `top` or similar.[^winehang] It is unknown why this happens, and its impact on the system is negligible at most, but it warrants notice nonetheless in case you want to manually terminate it.

## Troubleshooting

If you run into any problems running the Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux, please feel free to file an issue or pull request in relation.

The PLSPfCoZSASPoL has been tested on Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.

[^relpaths]: Specifically, relative paths fail on Flatpak Protontricks when they contain a double-dot (`..`) and the `realpath` utility is not available as a command. In practice, though, `realpath` is incredibly common and is installed by default on SteamOS, so this should hardly ever be an issue.

[^winehang]: Phenomenon observed on Arch Linux, kernel 6.2.6-arch1-1. I noticed this one day after doing multiple test runs and finding ~25 orphaned wine processes on btop, seems like it might just affect Proton Experimental versions.

[^proton8]: Proton 8 supposedly works by now but has not been tested for support. If you run into issues, please try with 7.0-6 before troubleshooting further.

[^extraction]: There have been reports of Ark extracting files incorrectly; make sure the extracted directory includes a few files whose names start with "Qt5". If GUI extraction proves unsuccessful, consider using [`unzip`](https://linux.die.net/man/1/unzip).
