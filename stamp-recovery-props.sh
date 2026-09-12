#!/bin/sh
# Called from BOARD_RECOVERY_IMAGE_PREPARE after ramdisk files are
# assembled and before mkbootfs. vendor/*.prop cannot set ro.build.*
# (partition property restriction), so stamp stock OS / patch into
# /prop.default, which recovery init loads as a system source.
set -eu
root=${1:?}
prop=$root/prop.default
test -f "$prop"
sed -i \
    -e 's/^ro.build.version.release=.*/ro.build.version.release=15/' \
    -e 's/^ro.build.version.release_or_codename=.*/ro.build.version.release_or_codename=15/' \
    -e 's/^ro.build.version.release_or_preview_display=.*/ro.build.version.release_or_preview_display=15/' \
    -e 's/^ro.build.version.security_patch=.*/ro.build.version.security_patch=2026-05-05/' \
    "$prop"
grep -q '^ro.build.version.release=15$' "$prop"
grep -q '^ro.build.version.security_patch=2026-05-05$' "$prop"
