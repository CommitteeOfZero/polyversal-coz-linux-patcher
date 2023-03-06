# Multiversal CoZ Linux Patcher v2

These instructions and the included Bash script are intended to streamline installation of CoZ patches for Steam Play, including on Steam Deck.

*This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## Backing up saved games and wiping a Proton prefix

If you have an existing installation of the game using a Proton version other than Valve Proton 7 (Proton 7.0-6 or later, to be specific), you will need to wipe the Proton prefix prior to beginning [preparation](#preparations). You should back up your saved games to another directory prior to wiping the prefix; this helps avoid any potential issues caused by a malfunction in the implementation of Steam Cloud saves for the title in question. You can move the saved games back into the Proton prefix after [running the multiversal patcher](#running-the-multiversal-patcher).

## Preparations

1. [Download the corresponding patch](http://sonome.dareno.me/projects) for your target game.
2. Extract the files from the archive and take note of the full path to the extracted directory.
3. This script utilizes [protontricks](https://github.com/Matoking/protontricks) to correctly apply the patch. If you already have a version of protontricks installed, you are good to go. If you do not, you can follow the link provided to install it yourself, or allow `patcher2.sh` to install the Flatpak version. To let the script automatically install protontricks, ensure Flatpak is installed on your PC and runnable by your user without root access (if you are not running SteamOS 3.x or another distro that provides Flatpak as part of the OS).
4. Download and install the related game from Steam.
5. Set the game's compatibility tool to the latest official Valve Proton 7 (Proton 7.0-6 at time of writing).
6. Launch the game once in order to generate a Proton prefix, then quit the game.
7. Download a copy of this repository and extract its files. Ensure the script ends up either in your Linux home directory or a subfolder of it.
8. Navigate to the folder containing the files from this repository using a Terminal console.

## Running the multiversal patcher

*Examples provided use v1.0.2 of the [**CHAOS;HEAD NOAH** Overhaul Patch](http://sonome.dareno.me/projects/chn-patch.html).*

Run the following command entered into your terminal replacing &lt;GameShortName&gt; with the short name from [the list below](#game-short-names), and &lt;PatchDirectory&gt; with the absolute path to the folder containing the patch.  
```sh
./patcher2.sh <GameShortName> <PatchDirectory>
```

For example: `./patcher2.sh chn $HOME/Downloads/CHNSteamPatch-v1.0.2-Setup`.

As part of the execution of this script, the GUI installer should launch. Follow the instructions in the interface to install the patch. If asked for an installation directory by the installer, use: `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing <Username> with your Linux username and <Game> with the name of the folder containing the game.

For example, on the Steam Deck: `Z:/home/deck/.local/share/Steam/steamapps/common/CHAOS;HEAD NOAH`.

Then, go back to Steam and launch the game. It should now be patched.

**Note**: Executing this script renders the terminal that ran the commands unable to run any further commands&mdash;on both Arch Linux and SteamOS 3.x on the Steam Deck. This is expected behavior. If you close the terminal after execution and open a new one, you will be able to access the terminal once more. Of course, after the successful installation of the patch, the terminal is unnecessary to run the patched game.

## Game Short Names

Here you can find a table of all the SciADV games which have received patches, and their corresponding short name required by the patcher script:

| **Game**              | **Short Name** |
| ----------------      |:--------------:|
| CHAOS;HEAD NOAH       |      chn       |
| STEINS;GATE           |       sg       |
| ROBOTICS;NOTES ELITE  |      rne       |
| CHAOS;CHILD           |       cc       |
| STEINS;GATE 0         |      sg0       |
| ROBOTICS;NOTES DaSH   |      rnd       |


## Troubleshooting

If you run into any problems executing the multiversal patcher, please feel free to file an issue or pull request in relation. The multiversal patcher has been tested on both Arch Linux, Fedora 37, and SteamOS 3.x, so pull requests to address issues specific to other Linux distributions are especially appreciated.
