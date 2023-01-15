# Multiversal CoZ Linux Patcher

*This script is possible in no small part due to the work of [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this in a post on Reddit](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## Prerequisites:

1. [Download the patch](http://sonome.dareno.me/projects) and ensure it remains in your Downloads folder (as that is the folder this script expects to find the patch in).
2. Extract the files from the archive into the Downloads folder with the command `unzip ~/Downloads/<PatchName.zip> -d ~/Downloads`, replacing <PatchName.zip> with the name of the archive containing the patch.
2. Ensure Flatpak is installed on your PC and runnable by your user without root access (if you are not running SteamOS 3.x or another distro that provides Flatpak as part of the OS).
3. Download and install the related game from Steam.
4. Set the game's compatibility tool to the latest official Valve Proton (Proton 7.0-5 at time of writing).
5. Launch the game once in order to generate a Proton prefix; then quit the game.
6. Either clone this Git repository or download an archive of its contents and extract the files. Either way, ensure the script ends up either in your Linux home directory or a subfolder of it.
7. Navigate to the folder containing the file `patch-sciadv.sh`.

## Running the multiversal patcher:

*Examples provided use v1.0.4 of the CoZ **Robotics;Notes DaSH** patch.*

On a traditional Linux OS, run this script with the following command entered into your terminal, replacing <AppID> with the Steam AppID from [SteamDB](https://steamdb.info/), <PatchDirectory> with the name of the folder  containing the patch, and <PatchInstaller.exe> with the name of the Windows executable installer included in that folder.

```sh
./patch-sciadv.sh <AppID> <PatchDirectory> <PatchInstaller.exe>
```

For example: `./patch-sciadv.sh 1111390 RNDPatch-v1.0.4-Setup RNDPatch-Installer.exe`.

If running the above command on SteamOS 3.x, the default distro of the Steam Deck, instead use:

```sh
./patch-sciadv.sh <AppID> <PatchDirectory> <PatchInstaller.exe> deck
```

For example: `./patch-sciadv.sh 1111390 RNDPatch-v1.0.4-Setup RNDPatch-Installer.exe deck`.

As part of the execution of this script, the GUI installer should launch. Follow the instructions in the interface to install the patch. If asked for an installation directory by the installer, use: `Z:/home/<Username>/.local/share/Steam/steamapps/common/<Game>`, replacing <Username> with your Linux username and <Game> with the name of the folder containing the game.

For example, on the Steam Deck: `Z:/home/deck/.local/share/Steam/steamapps/common/Robotics;Notes DaSH`.

Then, go back to Steam and launch the game. It should now be patched.

**Note**: Executing this script renders the terminal that ran the commands unable to run any further commands&mdash;on both Arch Linux and SteamOS 3.x on the Steam Deck. This is expected behavior. If you close the terminal after execution and open a new one, you will be able to access the terminal once more. Of course, after the successful installation of the patch, the terminal is unnecessary to run the patched game.

## Known Limitations

*Steins;Gate* launches the default launcher of the game upon clicking or pressing "Play" in Steam. The CoZ's custom launcher that is installed as part of the patch will open as soon as the default launcher is closed. Unfortunately, this means that launching the game through the default launcher first launches the game, then the custom launcher.

## Troubleshooting

If your run into any problems executing the multiversal patcher, please feel free to file an issue or PR in relation. However, know that if the issue is distro-specific, the development team does not have access to every conceivable Linux distro. PRs are welcomed to address these issues so that as many players can experience the patched SciADV games as seamlessly as possible.

*whose eyes are those eyes*
