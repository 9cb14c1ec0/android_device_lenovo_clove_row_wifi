#!/system/bin/sh
# Start Microtrust TEE then Beanpod Keymaster 4.1 before TWRP decrypts.
# Do not kill teei_daemon; that wedges TEEI until a hard reset.

export LD_LIBRARY_PATH=/system/lib64

mkdir -p /persist /mnt/vendor/persist /data/vendor/thh/system /data/vendor/thh/ta \
    /data/vendor/thh/tee_log /data/vendor/key_provisioning
if [ -e /dev/block/by-name/persist ]; then
    mount -t ext4 /dev/block/by-name/persist /persist 2>/dev/null || true
    mkdir -p /persist/rpmb
    mount --bind /persist /mnt/vendor/persist 2>/dev/null || true
fi

chmod 0660 /dev/teei_client /dev/teei_config /dev/tz_vfs /dev/ut_keymaster \
    /dev/rpmb0 /dev/mmcblk0rpmb 2>/dev/null || true
chmod 0666 /dev/isee_tee0 2>/dev/null || true

/system/bin/teei_daemon \
    -r 020b0000000000000000000000000000 \
    -r 020f0000000000000000000000000000 \
    -r 06090000000000000000000000000000 \
    -r 05120000000000000000000000000000 \
    -r 40188311faf343488db888ad39496f9a \
    -r 07060000000000000000000000007169 \
    -r 4be4f7dc1f2c11e5b5f7727283247c7f \
    -r 9073f03a9618383bb1856eb3f990babd \
    -r 08050000000000000000000000003419 \
    -r 5020170115e016302017012521300000 \
    -r 0f5eed3c3b5a47afacca69a84bf0efad \
    -r 07407000000000000000000000000000 \
    -r 05160000000000000000000000000000 \
    -r 91dba524a6e24909acc48abd7163121a \
    -r 08070000000000000000000000008270 \
    -r 09080000000000000000000000009381 \
    -t 08030000000000000000000000000000 \
    -t 85f630e0f0964c5fa2cc268ce04e3da3 \
    -t 98fb95bcb4bf42d26473eae48690d7ea \
    -t 7b66512021214487ba710a51d7ea78fe \
    -t 09010000000000000000000000000000 &

i=0
while [ "$i" -lt 50 ]; do
    if dmesg | grep -q "Keymaster Unlocked"; then
        break
    fi
    sleep 0.2
    i=$((i + 1))
done

/system/bin/android.hardware.keymaster@4.1-service.beanpod &
sleep 0.5
exit 0
