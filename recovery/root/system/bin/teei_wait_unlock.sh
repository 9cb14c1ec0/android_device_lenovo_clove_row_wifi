#!/system/bin/sh
i=0
while [ "$i" -lt 50 ]; do
    if dmesg | grep -q "Keymaster Unlocked"; then
        exit 0
    fi
    sleep 0.2
    i=$((i + 1))
done
exit 0
