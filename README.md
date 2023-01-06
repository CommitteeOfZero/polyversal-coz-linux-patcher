# Multiversal CoZ Linux Patcher

*This script is possible largely thanks to [/u/PartTimeBento](https://www.reddit.com/u/PartTimeBento), who [provided many of the necessary instructions to automate this](https://www.reddit.com/r/SteamDeck/comments/uitpca/patching_steinsgate_and_steinsgate0_on_the).*

## Prerequisites:

1. [Download the patch](http://sonome.dareno.me/projects) and ensure it remains in your Downloads folder (as that is the folder this script expects to find the patch in).
2. Extract the files from the archive into the Downloads folder with the command `unzip ~/Downloads/<PatchName.zip> -d ~/Downloads`, replacing <PatchName.zip> with the name of the archive containing the patch.
2. Ensure Flatpak is installed on your PC (if you are not running SteamOS 3.x or another distro that provides Flatpak as part of the OS).
3. Download and install the related game from Steam.
4. Set the game's compatibility tool to the latest official Valve Proton (Proton 7.0-5 at time of writing).
5. Launch the game once in order to generate a Proton prefix; then quit the game.

## Running this script:

If you haven't done much with Protontricks before, run this script with the following command entered into your terminal (Konsole on SteamOS 3.x by default), replacing <AppID> with the Steam AppID from [SteamDB](https://steamdb.info/), <PatchDirectory> with the name of the folder  containing the patch and <PatchInstaller.exe> with the name of the Windows executable installer included in that folder:

```sh
./patch-sciadv.sh <AppID> <PatchDirectory> <PatchInstaller.exe>
```

As part of the execution of this script, the GUI installer should launch. Follow the instruction in the interface to install the patch; then go back to Steam and launch the game. It should now be patched. *sips tea*

If you're a GNU/Linux expert who knows what they are doing (or if you've installed a prior CoZ patch this same way), you can pass an additional argument on the command line to skip configuration of Protontricks.

```sh
./patch-sciadv.sh <AppID> <PatchDirectory> <PatchInstaller.exe> 1337
```

## SciADV AppID List

## Troubleshooting

If you run into any problems with this script (or if it simply doesn't work for you at all), feel free to file an issue on this repository or ask about it in the CoZ Discord server.

Also: It's quite possible that there are edge cases that this script does not account for games that require an additional override for a Windows DLL in Protontricks. If you know of any of these, we'll add them to the script as we are made aware. Since the script is dependent on Steam AppIDs anyway, it shouldn't be too challenging to add support for specific games through conditional statements.

*whose eyes are those eyes*
