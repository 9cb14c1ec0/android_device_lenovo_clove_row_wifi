#!/system/bin/sh
# Init setenv is not enough: the recovery linker config does not
# reliably apply LD_LIBRARY_PATH to this vendor binary. exec so the
# HAL is pid 1's direct child after the shell replaces itself.
#
# Beanpod Configure is honored only once per TEE session. Stock FBE
# keys are tagged OS 15 / 2026-05; TWRP's build.prop is 14 / 2024-09.
# /vendor/default.prop should already have overwritten those, but
# resetprop here is a second chance if that file is missing.
/system/bin/resetprop -n ro.build.version.release 15
/system/bin/resetprop -n ro.build.version.release_or_codename 15
/system/bin/resetprop -n ro.build.version.security_patch 2026-05-05
/system/bin/resetprop -n ro.vendor.build.security_patch 2026-05-05
/system/bin/resetprop -n ro.system.build.version.security_patch 2026-05-05
/system/bin/resetprop -n ro.bootimage.build.version.security_patch 2026-05-05
export LD_LIBRARY_PATH=/vendor/lib64:/system/lib64
exec /system/bin/android.hardware.keymaster@4.1-service.beanpod
