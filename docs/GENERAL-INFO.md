# General Information

This is a more detailed page on what the PLSPftCoZSASPoL does and exactly how to get it working on Linux systems in general, not just the Steam Deck. It is written with the assumption that the reader has a general understanding of how to work with Linux and the command line.

The foundations of this script are largely built upon [u/PartTimeBento's seminal Reddit post](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).

## TL;DR

Double-click the included `.desktop` entry, or directly invoke the script like so:

```bash
## GUI mode ##
./polyversal

## CLI mode ##
./polyversal install <game name> <patch dir>  # install patch
./polyversal uninstall <game name>            # remove installed patch
./polyversal nuke <game name>                 # delete a game's Proton prefix
./polyversal ac-proton                        # install custom A;C Proton build
```

- `<game name>` is the game's [shortname identifier](/docs/GAMES.md)
- `<patch dir>` is the path to the extracted CoZ patch directory
- Either [Flatpak](https://flatpak.org/setup/) or a system install of [Protontricks](https://github.com/Matoking/protontricks#installation) >= 1.10.1 is required
- Be sure to set [the right Proton version](/docs/GAMES.md)
- [See here](#command-line-options) for CLI options

## Table of Contents

- [System Requirements](#system-requirements)
- [Preparations](#preparations)
- [Usage](#usage)
  - [GUI](#gui)
  - [CLI](#cli)
  - [General](#general)
- [Command Line Options](#command-line-options)
- [Notes](#notes)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## System Requirements

- Bash, plus the standard GNU coreutils
- Either of the following:
  - [Protontricks](https://github.com/Matoking/protontricks#installation) version 1.12.0 or above
  - [Flatpak](https://flatpak.org/setup/)
- [GUI only] [Zenity](https://help.gnome.org/users/zenity/stable/)
  - Should be already installed with Steam. Verify with `zenity --version` if unsure

## Preparations

1. Download and install your target game from Steam.

1. Within the game's Properties menu, set its compatibility tool to [its required Proton version](/docs/GAMES.md).

1. **Run the game at least once** to generate a Proton prefix.

1. Download and extract the [CoZ patch for your target game](https://sonome.dareno.me/projects) and the [latest release of this script](https://github.com/CommitteeOfZero/multiversal-coz-linux-patcher/releases).

    - You can also clone this repo or download a copy under the Code button at the top of the page if you really want to use the latest (unstable) commit. [Here be dragons.](https://en.wikipedia.org/wiki/Here_be_dragons)

**A quick note on terminology**: Any time we mention "the script", we are referring to *this* script, the Polyversal Patcher, the one you're reading instructions for right now. When we mention "the patch" or "the patcher", we are referring to the actual Committee of Zero patch that you downloaded from the official website.

## Usage

This script features both a GUI (Graphical User Interface) mode and a CLI (Command Line Interface) mode.

### GUI

There are two ways to launch the GUI: using the provided `Polyversal.desktop` entry, and running it from the command line. The easier option is to simply double-click the desktop file to launch it.

To run the script in GUI mode, simply invoke it with no arguments:

```sh
./polyversal
```

[See here](#command-line-options) for command options.

Once launched (via either method), some selection pop-ups will appear with more windows showing up throughout the script's execution to signal errors or successes.

You'll know the script has started successfully when you see a window similar to the following:

![Image of a Zenity list selection.](/assets/first-screen.png "The first window")

### CLI

To run the script in CLI mode, invoke it in one of the forms below, replacing `GAME` with a shortname identifier from [this table](/docs/GAMES.md) and `PATCH_DIR` with the path to the extracted folder containing the CoZ patch.

It must not be run as root, else it will fail with an error message.

```sh
# Install a patch
$ ./polyversal install GAME PATCH_DIR

# Uninstall a patch
$ ./polyversal uninstall GAME

# Delete a game's existing Proton prefix
$ ./polyversal nuke GAME

# Install custom Proton-GE build for A;C video
$ ./polyversal ac-proton

# Examples:
$ ./polyversal install chn ~/Downloads/CHNSteamPatch-v1.0.2-Setup
$ bash polyversal i sg0 /home/myname/Games/SG0/SG0Patch-v2.1.3-Setup
$ ./polyversal uninstall dash
```

[See here](#command-line-options) for CLI options.

### General

The following info is pertinent regardless of how you launched the script.

- During execution, a GUI for the actual patch installer should launch. Follow the instructions in the interface to install the patch.

    ![Image of the actual CoZ patcher GUI.](/assets/coz-gui.png "Still gotta finish this game")

  - If asked for an installation directory by the installer, use `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing &lt;Username&gt; with your Linux username and &lt;Game&gt; with the name of the folder containing the game. For example, Chaos;Head NoAH on the Steam Deck would be `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.

- Reaching the 'Success!' message at the end of the script does not necessarily mean the patch was applied successfully. Due to the nature of the Wine layer, it can unfortunately be difficult to automatically determine a program's success. Be sure to [verify that the patch is actually active](/docs/VERIFY.md) upon booting up the game.

## Command Line Options

The following options are available when invoking the script from the terminal.

- `-h | --help`
  - Print a usage message and exit.
- `-v | --verbose`
  - Log `DEBUG`-level messages to output.
- `--log`
  - Copy terminal output to a log file in `./logs/`. Disables terminal colors.
- `-r | --steamroot NEW_ROOT`
  - Use `NEW_ROOT` as the root of your steam install instead of `~/.steam/root`.
  - This likely has limited use cases, though it may help if you have Flatpak Steam installed and the root is in `/var/app/...`. Do note that Flatpak Steam has not been tested at the time of writing.
- `-F | --force-flatpak`
  - Use Flatpak Protontricks even if there exists a system install.
  - Very useful for development, but also nice if your package manager doesn't yet have the latest version in its repos. Or if you just feel like it.

## Notes

- The script will prefer to use a system install of Protontricks over Flatpak, if present, since there are fewer points of failure.

- If you're using Flatpak and have the game installed in a non-default Steam library folder, Flatpak might complain about not having access permissions. If the script fails, check the output/logs for a message from Flatpak telling you exactly what command to copy+paste in order to do so.

- Flatpak Protontricks will be updated automatically if it's outdated. So, if for some arcane reason you need a specific older version installed, be aware that you will have to downgrade after this script completes.

- If you *really* know what you're doing, you could turn this into a proper desktop application by modifying `Polyversal.desktop`'s "Exec" line to run the script from a static location and install it to `~/.local/share/applications`, or whever your `$XDG_DATA_HOME` points to.

## Troubleshooting

See [TROUBLESHOOTING.md](/docs/TROUBLESHOOTING.md).

## Contributing

If you have any ideas for how to improve the script or any features you'd like to see implemented, please feel free to file an issue or pull request in relation!

The Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux has been tested on Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.
