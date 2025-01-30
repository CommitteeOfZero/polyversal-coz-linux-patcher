# Troubleshooting

*or: "How I Learned to Stop Worrying and Love the Skill Issue"*

There are several problems that can occur while using this script. This page serves as an FAQ so that you can hopefully quickly debug and fix any that might happen to you.

The [First Steps](#first-steps) are a good place to start, or if you see your specific issue in the Table of Contents below then you can jump straight there.

## Table of Contents

- [First Steps](#first-steps)
  - [Ensure proper extraction](#ensure-proper-extraction)
  - [Try from a clean prefix](#try-from-a-clean-prefix)
  - [Check the logs](#check-the-logs)
- [Videos won't play in Anonymous;Code](#videos-wont-play-in-anonymouscode)
- [Double-clicking on `Polyversal.desktop` opens a file with some weird text](#double-clicking-on-polyversaldesktop-opens-a-file-with-some-weird-text)
- [When I run the game the official launcher shows up. The patched CoZ launcher only shows once I quit or start the game](#when-i-run-the-game-the-official-launcher-shows-up-the-patched-coz-launcher-only-shows-once-i-quit-or-start-the-game)
- [How to run from the command line](#how-to-run-from-the-command-line)
- [Nothing worked and everything is broken! HELP!](#nothing-worked-and-everything-is-broken-help)

## First Steps

There are a few things you can check that can speed up the process of troubleshooting by quite a bit. It is suggested that you try each of these and see if any of them fix your problem, especially if the problem you have does not yet have a dedicated section on this page.

### Ensure proper extraction

You'll want to make sure both the Polyversal script and the CoZ patch installer were extracted correctly.

The extracted Polyversal folder should at least have the script itself, named `polyversal`, and the desktop entry `Polyversal.desktop.`

The extracted patch folder should have the installer EXE file, `[GameName]-Installer.exe`, several DLL files that start with `Qt5` (for example, `Qt5Core.dll`), and a few folders such as `DIST` and `iconengines`.

If either of the folders look like they are missing some or all of these files, then try extracting them again or consider using a CLI tool like [`unzip`](https://linux.die.net/man/1/unzip) or [`tar`](https://linux.die.net/man/1/tar).

### Try from a clean prefix

The next thing you should try is reinstalling the patch with a clean Proton prefix. Simply put, this is what Proton uses to mimic a Windows installation and can potentially be very sensitive to version-specific changes.

First, run Polyversal and choose 'Uninstall a Patch' followed by the game you want.

Then, run Polyversal again and choose 'Nuke a Proton Prefix' followed by the same game.

Lastly, make sure you have [the right Proton version set for your target game](/docs/GAMES.md). **Run the game once with the right Proton version** and then try reinstalling the patch.

### Check the logs

You can also generate some log files to inspect by [running Polyversal from the command line](#how-to-run-from-the-command-line), using `./polyversal --log` as the command to run.

You'll then want to check the most recent log files in the newly generated `logs` folder that was created. The file of interest is the one **without** `-wine` in its name; see if there are any lines with "`ERROR`" or "`FATAL`" at the start and whether they tell you anything about what went wrong.

## Videos won't play in Anonymous;Code

Read [the instructions](/README.md#setup) carefully! A;C currently requires [a custom Proton-GE build](/docs/AC.md) to fix video playback.

## Double-clicking on `Polyversal.desktop` opens a file with some weird text

If double-clicking the `.desktop` entry shows you a bunch of monospaced text that starts with `[Desktop Entry]`, then it's been treated as a text file rather than an application to launch.

Your best bet here is to invoke the script directly from the command line. [See the section on how to do so](#how-to-run-from-the-command-line).

## When I run the game the official launcher shows up. The patched CoZ launcher only shows once I quit or start the game

This is a known issue, though it is unknown why this happens. It was first observed in Steins;Gate and later manifested in Chaos;Child and other games. The script has fixes for affected games we currently know about, though it is very possible more games may be affected in the future.

If you find that another game has this issue, you can manually fix it by backing up the official launcher EXE and then symlinking it to the patched launcher, `LauncherC0.exe`. If you don't know what that means, please open a GitHub issue noting on which game this happened to you. (If you do know, open a PR! The functions are `apply_launcherfix` and `undo_launcherfix`.)

## How to run from the command line

Some issues can be solved by directly running the script from the command line, rather than using the `.desktop` entry. To do so, first open a terminal in the directory containing the script. On KDE and Steam Deck, you can do so by right-clicking on `polyversal` from within the file browser and selecting "Open Terminal Here".

![Image of the "Open Terminal Here" dialog.](/assets/open-term-here.png)

Once the terminal is open, simply invoke it by typing the below command and hitting Enter:

```bash
./polyversal
```

The launch window should then appear.

If that still doesn't work, there's one more thing you can try: running the script via the CLI mode. This is far less prone to issues, but it lacks a graphical interface.

Luckily, it's still very easy to do. In the terminal that you opened, paste or type the following but **don't** hit enter yet:

```bash
./polyversal install <GAME> 
```

Be sure to include the trailing space, and replace `<GAME>` with the [abbreviation of the game you want to patch](/docs/GAMES.md). For example, Robotics;Notes ELITE would be `./polyversal install rne `.

Then, click and drag the CoZ patch folder from the file browser onto the terminal and hit Enter. Hopefully the script runs successfully at this point and you are met with the patch launcher.

![A gif demonstrating how to run the script in CLI mode](/assets/gif/cli.gif "Fish is objectively the best shell, but I like zsh")

For other script actions besides installing a patch, e.g. nuking a prefix or installing the A;C Proton build, see [the full docs on the CLI mode](/docs/GENERAL-INFO.md#cli).

## Nothing worked and everything is broken! *HELP!*

First of all, calm down. Yelling isn't going to get us anywhere.

Now, if you're still having issues then there are a couple things you can try:

- [Check the logs](#check-the-logs) for any obvious errors that may have occurred in your last run.

- Open a GitHub issue describing the problem that occurred. This is a great choice since others that have the same issue can then find the thread in the future.

- Ask for help in the `#bug-reports` channel in the official CoZ Discord (and bring some logs!).

If you find a solution to your problem, please feel free to open a pull request to adjust the script logic or to add the problem and its solution to this page. This is a growing page and a community effort, so any and all contributions are very appreciated.
