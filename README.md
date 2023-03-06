# Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux

This project is a fork of [CoZ's official Multiversal Linux patcher](https://github.com/CommitteeOfZero/multiversal-coz-linux-patcher). From the official repository:

> These instructions and the included Bash script are intended to streamline installation of CoZ patches for Steam Play, including on Steam Deck.
> 
> *This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## TL;DR

```sh
./polyversal.sh <GameShortName> <PatchDir>
```

- &lt;GameShortName&gt; is the [game's short name](#game-short-names)
- &lt;PatchDir&gt; is the path to the extracted patch setup directory, preferably absolute or homedir-relative
- Have [Protontricks](https://github.com/Matoking/protontricks) or [Flatpak](https://flatpak.org/setup/) installed
- Use Proton 7 or newer


## Backing up saved games and wiping a Proton prefix

If you have an existing installation of the game using a Proton version other than Valve Proton 7 (Proton 7.0-6 or later, to be specific), you will need to wipe the Proton prefix prior to beginning [preparation](#preparations). You should back up your saved games to another directory prior to wiping the prefix; this helps avoid any potential issues caused by a malfunction in the implementation of Steam Cloud saves for the title in question. You can move the saved games back into the Proton prefix after [running the patcher](#usage).

## Preparations

1. [Download the corresponding patch](https://sonome.dareno.me/projects) for your target game.
2. Extract the files from the archive and take note of the full path to the extracted directory.
    - There have been reports of Ark extracting files incorrectly; make sure the extracted directory includes a few files whose names start with "Qt5". If GUI extraction proves unsuccessful, consider using [`unzip`](https://linux.die.net/man/1/unzip).
3. This script utilizes [protontricks](https://github.com/Matoking/protontricks) to correctly apply the patch. If you already have a version of protontricks installed, you are good to go. If you do not, you can follow the link provided to install it yourself, or allow the script to install the Flatpak version.
    - To allow automatic installation of protontricks, ensure [Flatpak](https://flatpak.org/setup/) is installed on your machine and runnable by your user without root access (if you are not running SteamOS 3.x or another distro that provides Flatpak as part of the OS).
    - Steam Deck users should prefer the Flatpak version.
4. Download and install the related game from Steam.
5. Within the game's properties, set its compatibility tool to the latest official Valve Proton 7 (Proton 7.0-6 at time of writing).
6. Launch the game once in order to generate a Proton prefix, then quit the game.
7. Download a copy of this repository and extract its files.
8. Navigate to the folder containing these files using the terminal emulator of your choice.
    - Konsole is the default for Steam Deck.

## Usage

Run the following command entered into your terminal, replacing &lt;GameShortName&gt; with the short name from [the list below](#game-short-names) and &lt;PatchDirectory&gt; with the path to the folder containing the patch. 

```sh
./polyversal.sh <GameShortName> <PatchDirectory>

# Examples
./polyversal.sh chn ~/Downloads/CHNSteamPatch-v1.0.2-Setup
./polyversal.sh sg0 /home/myname/Games/SG0/SG0Patch-v2.1.3-Setup
```

Relative paths are accepted but not guaranteed to work, especially when using Flatpak. Absolute or homedir-relative paths should be preferred.

As part of the execution of this script, the GUI installer should launch. Follow the instructions in the interface to install the patch. If asked for an installation directory by the installer, use: `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing &lt;Username&gt; with your Linux username and &lt;Game&gt; with the name of the folder containing the game.

For example, on the Steam Deck: `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.

Then, go back to Steam and launch the game. It should now be patched. Confirm that it launches the patched CoZ launcher with a black background (with the exception of Steins;Gate, [see below](#known-issues)).

**Note**: Executing this script renders the terminal that ran the commands unable to run any further commands&mdash;on both Arch Linux and SteamOS 3.x on the Steam Deck. This is expected behavior. If you close the terminal after execution and open a new one, you will be able to access the terminal once more. Of course, after the successful installation of the patch, the terminal is unnecessary to run the patched game.

## Game Short Names

Here you can find a table of all the SciADV games which have received patches and their corresponding short name required by the patcher script. The app ID is also provided as a quick reference for compatdata folders.

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

*STEINS;GATE* in its patched form launches the game's default launcher upon clicking or pressing "Play" in Steam. The Committee of Zero's custom launcher that is installed as part of the patch will open as soon as the default launcher is closed. This means that launching the game through the default launcher first launches the game, then the custom launcher. This occurs because Steam still launches the game through `Launcher.exe` rather than the patched `LauncherC0.exe`.

This can be manually fixed by creating a symlink to the patched launcher:

```sh
# Assuming default install location
cd "$HOME/.local/share/Steam/steamapps/common/STEINS;GATE"
mv Launcher.exe Launcher.exe.bkp
ln -s LauncherC0.exe Launcher.exe
```

Before uninstalling the patch with `nguninstall.exe` in the Steam directory, be sure to undo these changes. **To avoid potential issues, make sure to run the below commands _before_ uninstalling the patch,** if you decide to do so :(

```sh
cd "$HOME/.local/share/Steam/steamapps/common/STEINS;GATE"
unlink Launcher.exe
mv Launcher.exe.bkp Launcher.exe
```

## Troubleshooting

If you run into any problems executing the Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux, please feel free to file an issue or pull request in relation. **Please do not complain to the Committee of Zero directly**: if you need someone to yell at, ping `Macitron3000#0766` on Discord.

The PLSPfCoZSASPoL has been tested on Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.
