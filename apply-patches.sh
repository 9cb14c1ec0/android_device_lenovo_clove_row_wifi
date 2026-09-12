#!/bin/sh
# Apply the TB305FU TWRP platform patches. Run from the TWRP 14.1 tree root
# after `repo sync`, with this device tree at device/lenovo/clove_row_wifi.
set -eu

if [ -n "${ANDROID_BUILD_TOP:-}" ]; then
    top=$ANDROID_BUILD_TOP
elif [ -d ./.repo ] && [ -d ./bootable/recovery ]; then
    top=$(pwd)
else
    top=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
fi
patchdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/patches

apply_one() {
    proj=$1
    patch=$2
    if [ ! -d "$top/$proj" ]; then
        echo "missing project: $proj" >&2
        exit 1
    fi
    if git -C "$top/$proj" apply --check "$patchdir/$patch" 2>/dev/null; then
        git -C "$top/$proj" apply "$patchdir/$patch"
        echo "applied $patch -> $proj"
    elif git -C "$top/$proj" apply --reverse --check "$patchdir/$patch" 2>/dev/null; then
        echo "already applied $patch"
    else
        echo "FAILED to apply $patch onto $proj" >&2
        echo "Expected base revision is in patches/BASE_REVS.txt" >&2
        exit 1
    fi
}

apply_one bootable/recovery bootable_recovery.patch
apply_one build/make build_make.patch
apply_one system/logging system_logging.patch
apply_one system/security system_security.patch
apply_one system/sepolicy system_sepolicy.patch
apply_one system/vold system_vold.patch
echo "all patches applied"
