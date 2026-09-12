Platform diffs applied on top of TWRP 14.1 (`twrp-14.1` manifest,
AOSP `android-14.0.0_r67` plus TeamWin overlays).

`BASE_REVS.txt` is `git rev-parse HEAD` of each project in the tree
this was built from. `../apply-patches.sh` applies every `*.patch`
here. Re-run is safe if the patch is already applied.
