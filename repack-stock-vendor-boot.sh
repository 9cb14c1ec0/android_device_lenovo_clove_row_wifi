#!/bin/sh
set -eu

if [ -n "${ANDROID_BUILD_TOP:-}" ]; then
    top=$ANDROID_BUILD_TOP
else
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    top=$(CDPATH= cd -- "$script_dir/../../.." && pwd)
fi
device="$top/device/lenovo/clove_row_wifi"
product="$top/out/target/product/clove_row_wifi"
recovery="$product/obj/PACKAGING/vendor_ramdisk_fragments_intermediates/recovery.cpio.lz4"
unsigned="$product/vendor_boot-stock-layout-unsigned.img"
output="$product/vendor_boot-twrp-experimental.img"

test -f "$recovery"

"$top/out/host/linux-x86/bin/mkbootimg" \
    --header_version 4 \
    --pagesize 4096 \
    --base 0x40000000 \
    --kernel_offset 0x00080000 \
    --ramdisk_offset 0x07c80000 \
    --tags_offset 0x0bc80000 \
    --dtb_offset 0x0bc80000 \
    --vendor_cmdline 'bootopt=64S3,32N2,64N2' \
    --dtb "$device/prebuilt/stock.dtb" \
    --vendor_ramdisk "$device/prebuilt/vendor_ramdisk_platform.lz4" \
    --ramdisk_type recovery \
    --ramdisk_name recovery \
    --vendor_ramdisk_fragment "$recovery" \
    --ramdisk_type platform \
    --ramdisk_name init_boot \
    --vendor_ramdisk_fragment "$device/prebuilt/vendor_ramdisk_init_boot.lz4" \
    --vendor_boot "$unsigned"

cp "$unsigned" "$output"
"$top/out/host/linux-x86/bin/avbtool" add_hash_footer \
    --image "$output" \
    --partition_name vendor_boot \
    --partition_size 67108864 \
    --salt 9fb45fbcb7461e2122911082ae6a9ddc2e1a1fcafacad9ff3009c299677f20a5 \
    --prop 'com.android.build.vendor_boot.fingerprint:Lenovo/TB305FU/TB305FU:15/AP3A.240905.015.A2/__ROW:user/release-keys'

echo "$output"
