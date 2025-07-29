# Adding New Games

Every so often, a new game gets patched - and by then, enough time has passed that I've forgotten what exactly in this repo needs to be updated for a new release.

This page acts as a quick index/checklist to run through when these momentous occasions occur.

## The Checklist

- [ ] `polyversal`
  - [ ] `long_usage()` - Update game abbreviations
  - [ ] `set_game()`
    - [ ] Add game to Zenity list when setting `arg_game`
    - [ ] Add to switch case setting game vars
  - [ ] `apply/undo_launcherfix`
    - Might not be needed, only necessary if the game has the launcher issue
    - [ ] Add gamecode to guard switch statement on entry
    - [ ] Set default launcher name
- [ ] `docs/GAMES.md`
  - [ ] Add new table row for the game with the latest working Proton version
- [ ] `docs/VERIFY.md`
  - [ ] Add section or update existing section with how to check that the game's patch is applied
