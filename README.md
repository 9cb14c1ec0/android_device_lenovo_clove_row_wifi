# TWRP 14.1 for Lenovo Tab Plus (TB305FU / clove_row_wifi)

Experimental TWRP 14.1 recovery for the Lenovo Tab Plus Wi-Fi
(`TB305FU`, device `clove_row_wifi`).

The tablet is an MT6768/MT8786-family device on Lenovo Android 15
(ZUI 17) with a 6.6 GKI kernel. Matching kernel source has not been
released. This port keeps the stock kernel, DTB, first-stage vendor
ramdisk, and `init_boot` vendor-ramdisk fragment, and replaces only
the recovery ramdisk fragment inside `vendor_boot`.

## What works today

- TWRP UI, DRM graphics, ILITEK touch, persistent ADB
- SELinux **enforcing**
- Beanpod Keymaster 4.1 + Microtrust TEEI + `keystore2`
- Metadata encryption unwrap (`dm-default-key` `/dev/block/mapper/userdata`)
- TWRP mounts `/data` as f2fs from that mapper
- User-0 DE key installation and `fscrypt_init_user0` complete under enforcing
- TWRP enumerates user 0 and enters the real CE credential flow

## What does not work yet

- Credential-encrypted storage still needs a live test with the tablet's real
  PIN/password/pattern. The default credential correctly fails, so filenames
  remain encoded until that test succeeds. Do not treat this as a finished
  decrypting recovery yet.
- Do not format `/data` or `/metadata`. Slot B is the stock fallback;
  flash experimental images to **slot A only**.

Known-good touch-only fallback SHA-256 (no crypto):

`89eff5f623180c02be142ba8b4ac3253af173379c8eaaa767bb1598066dbed1b`

Current experimental crypto image SHA-256:

`c34feb3189cd84dcb6d6c65f42dcc39ea934f54d0a9e496dd1060888ec66c4eb`

Size of a packed `vendor_boot` image is exactly 67,108,864 bytes.

## Reproduce the tree

You need ~150 GB free, `repo`, and the usual Android build packages.

```bash
mkdir twrp-14.1 && cd twrp-14.1
repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-14.1
mkdir -p .repo/local_manifests
curl -fsSL \
  https://raw.githubusercontent.com/9cb14c1ec0/android_device_lenovo_clove_row_wifi/main/local_manifests/clove.xml \
  -o .repo/local_manifests/clove.xml
repo sync -c -j$(nproc)
```

This device tree ships the stock kernel, DTB, vendor ramdisk fragments,
Beanpod/TEEI binaries, and TAs extracted from Lenovo firmware. After
sync:

```bash
device/lenovo/clove_row_wifi/apply-patches.sh
```

The patches are against the TWRP 14.1 / AOSP 14.0.0_r67 revisions listed
in `patches/BASE_REVS.txt`. They cover:

| Project | Why |
| --- | --- |
| `bootable/recovery` | DRM/touch, metadata mapper fallback, logd/keystore2 packaging |
| `build/make` | Do not rsync a host `vendor/` over the recovery ramdisk vendor tree |
| `system/logging` | logd must not FATAL on missing task profiles / already-true props |
| `system/security` | `libkm_compat` talks to HIDL Keymaster 4.1 via `defaultServiceManager1_2()` |
| `system/sepolicy` | recovery owns Binder + Keymaster/keystore2 + metadata/FBE ioctls |
| `system/vold` | non-secret user-0 FBE phase diagnostics for enforcing recovery bring-up |

## Build

Lunch combo is `twrp_clove_row_wifi-ap2a-eng` (Android 14.1 `ap2a`
release config). The stock OS is Android 15; do not change
`PLATFORM_VERSION` for the TWRP tree. Stock OS 15 / security patch
`2026-05-05` is stamped into recovery `/prop.default` at pack time
because Beanpod Configure is first-write per TEE session.

```bash
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_clove_row_wifi-ap2a-eng
m vendorbootimage -j$(nproc)
device/lenovo/clove_row_wifi/repack-stock-vendor-boot.sh
```

`m vendorbootimage` alone is **not** the flashable image. The repack
script builds a vendor_boot v4 with:

1. stock platform ramdisk
2. the TWRP recovery fragment just built (`lz4 -l` legacy, which is
   what this bootloader decompresses)
3. stock `init_boot` ramdisk fragment
4. stock DTB and an AVB hash footer

Output:

`out/target/product/clove_row_wifi/vendor_boot-twrp-experimental.img`

Never recompress the recovery `.cpio.lz4` with frame LZ4 (`lz4` without
`-l`). That bootloops.

## Flash (slot A only)

Unlocked bootloader. Verify product and slot first:

```bash
fastboot getvar product          # clove_row_wifi
fastboot getvar current-slot     # a
fastboot flash vendor_boot_a out/target/product/clove_row_wifi/vendor_boot-twrp-experimental.img
fastboot reboot recovery
```

Do not flash `vendor_boot_b`. Do not `fastboot -w`, format `/data`, or
format `/metadata`.

The stock `vbmeta` hashes `vendor_boot`. A TWRP `vendor_boot` therefore makes
stock LK show a yellow-state "dm-verity corruption" warning and wait for the
power button (or power-cycle). Pressing power once per recovery boot is the
safest option.

### Optional patched LK (slot A only)

The beta release also includes
`lk_a-dmverity-patched-TB305FU-c4fe7ca1.bin`. It patches the verification
function prologue at file offset `0x69db8` from `30 b5 83 b0` to
`00 20 70 47` (`movs r0, #0; bx lr`). This skips the yellow dm-verity gate;
the normal orange unlocked-bootloader delay may still appear.

Flashing LK is riskier than flashing recovery. This 2 MiB image is only for
the **TB305FU / clove_row_wifi** firmware used by this port. Keep a matching
stock `lk_a` image available before proceeding. Verify both downloads with
the release `SHA256SUMS`, confirm the device and slot, and flash only slot A:

```bash
sha256sum -c SHA256SUMS
fastboot getvar product          # must be clove_row_wifi
fastboot getvar current-slot     # must be a
fastboot flash lk_a lk_a-dmverity-patched-TB305FU-c4fe7ca1.bin
fastboot flash vendor_boot_a vendor_boot-twrp-TB305FU-beta2-c34feb31.img
fastboot reboot recovery
```

If the LK flash command fails, do not reboot: restore the matching stock image
while fastboot is still available. To restore later:

```bash
fastboot flash lk_a lk_a-stock.bin
fastboot reboot
```

Do not flash `lk_b` or `vbmeta_b`; they are the stock fallback. This bootloader
still treats unsigned or test-key `vbmeta` as `ERROR_VERIFICATION`, so AVB flag
changes do not replace the LK patch.

## Layout notes that will bite you

- Stock `/data` is FBE v2 with metadata encryption:
  `fileencryption=aes-256-xts:aes-256-cts:v2,keydirectory=/metadata/vold/metadata_encryption`
- Beanpod Keymaster is HIDL 4.1 on hwbinder, not VendorBinder. Do not
  start `vndservicemanager`.
- The HAL must be exec'd with `LD_LIBRARY_PATH=/vendor/lib64:/system/lib64`
  so vendor `libc++` is loaded.
- `vendor/*.prop` cannot override `ro.build.*` (partition property
  rules). `/prop.default` is the system source that Configure reads.
- `ro.crypto.type=file` must be present in initial `/prop.default`; setting it
  after `/data` is mounted is too late because it is read-only.
- Recovery runs vold's `vold_prepare_subdirs` helper in its normal confined
  SELinux domain even though the ramdisk executable is labeled `rootfs`.
- TWRP cannot set `ro.crypto.fs_crypto_blkdev` after boot; the recovery
  binary falls back to `/dev/block/mapper/userdata`.

## License

Makefiles, sepolicy, scripts, and the touch shim are Apache-2.0 unless
a file says otherwise. Prebuilt kernel, DTB, vendor ramdisks, firmware,
Beanpod/TEEI binaries, and Trusted Applications are proprietary Lenovo /
MediaTek / Microtrust blobs extracted from stock firmware and are
redistributed only so this recovery can be reproduced.
