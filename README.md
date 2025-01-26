# The Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux

This Bash script is intended to automate the process of installing CoZ Steam patches on GNU/Linux systems including the Steam Deck and desktop distros.

**The instructions below are written specifically for the Steam Deck** as this has proven to be the most common use case. They should be largely adaptable to any desktop Linux installation, but for more general instructions, system requirements, and other information about the script including the CLI mode, see [GENERAL-INFO.md](/docs/GENERAL-INFO.md).

See [TROUBLESHOOTING.md](/docs/TROUBLESHOOTING.md) if anything goes wrong during usage.

## Setup

1. Switch to [Desktop Mode](https://youtu.be/FAf2s99-iik).

1. Download both [the patch for your target game](http://sonome.dareno.me/projects/) and [the latest release of this script](https://github.com/CommitteeOfZero/polyversal-coz-linux-patcher/releases), if you haven't already.

1. Extract both of these files.

   ![A gif of extracting the script and CoZ patch](/assets/gif/unzip.gif "Unzipping the archives")

   - **Note**: opening and extracting the CoZ patch might take some time. This GIF has been edited for brevity.

1. **If you're patching Anonymous;Code,** [read here](/docs/AC.md) for some brief (but required) additional setup. Then return here and continue onto the next step.

1. Download and install your target game from Steam, and within the game's Properties menu under Compatibility select its [required Proton version](/docs/GAMES.md).

   ![A gif of choosing Proton versions from a game's Properties menu](/assets/gif/props-proton.gif "Choosing a Proton version from R;NE's properties")

1. Run the game at least once. Reaching the launcher and then pressing `Quit Game` is sufficient for this; if the game lacks a dedicated launcher, then wait for the game window to appear before quitting.

## Usage

1. Run this script by right-clicking (L2) on `polyversal` and selecting *Run In Konsole*.

   ![A gif of how to run the script](/assets/gif/run-konsole.gif "Running the script")

1. Enter which game you're patching and the extracted folder containing the CoZ patch. The actual patcher should launch; this might take some time.

   ![A gif of choosing the patch directory](/assets/gif/choose.gif "Choosing the game + patch directory")

1. Follow the instructions in the CoZ patch installer.

   - If the installation directory isn't automatically populated, put `Z:/home/<USERNAME>/.steam/root/steamapps/common/<GAME>` if the game is installed on your internal drive. For example, Chaos;Head NoAH would be `Z:/home/deck/.steam/root/steamapps/common/CHAOS;HEAD NOAH`.

   - If the game is installed on an SD card, the path will instead be `Z:/run/media/<USERNAME>/<random-numbers>/steamapps/common/<GAME>`. You'll have to browse for the folder yourself to see what the `random-numbers` are.

   - If you have your Steam library installed to a different non-standard location, then hopefully you can remember where you set it up well enough to know the path.

1. **For Robotics;Notes Elite and DaSH,** you'll probably want to install a Community Layout for the controls as the official one is borderline non-functional.

And that's it! You can close the terminal window that was opened once you're done. Do be sure to [verify that the patch is actually active upon booting the game](/docs/VERIFY.md) - the script might have failed even if you reached the success screen, since Wine makes it difficult to know for sure whether something went wrong.

## Something Went Wrong

Worry not! See [TROUBLESHOOTING.md](/docs/TROUBLESHOOTING.md) for a list of common issues and how to proceed.

------------

The Polyversal Linux Steam Patcher for the Committee of Zero's Science Adventure Steam Patches on Linux has been tested on Arch Linux, Fedora 37, and SteamOS 3.x. Any pull requests or feedback related to other distributions are especially appreciated.
