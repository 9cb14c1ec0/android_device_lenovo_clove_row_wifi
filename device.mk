LOCAL_PATH := device/lenovo/clove_row_wifi
CRYPTO_PREBUILT := $(LOCAL_PATH)/prebuilt/crypto

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/first_stage_ramdisk/fstab.mt8786:$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/fstab.mt8786 \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt8786.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt8786.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/lenovo-modules.safe:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/lenovo-modules.safe \
    $(LOCAL_PATH)/recovery/root/system/etc/lenovo-modules.power:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/lenovo-modules.power \
    $(LOCAL_PATH)/recovery/root/system/etc/lenovo-modules.touch-probe:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/lenovo-modules.touch-probe \
    $(LOCAL_PATH)/recovery/root/system/etc/lenovo-modules.touch-ilitek:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/lenovo-modules.touch-ilitek \
    $(LOCAL_PATH)/recovery/root/system/etc/lenovo-modules.touch-shim:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/lenovo-modules.touch-shim \
    $(LOCAL_PATH)/recovery/root/system/bin/teei_wait_unlock.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/teei_wait_unlock.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/beanpod_keymaster.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/beanpod_keymaster.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/beanpod_gatekeeper.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/beanpod_gatekeeper.sh \
    $(LOCAL_PATH)/recovery/root/vendor/etc/vintf/manifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest.xml \
    $(LOCAL_PATH)/recovery/root/vendor/default.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/default.prop \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/vintf/manifest.xml \
    system/core/libprocessgroup/profiles/task_profiles.json:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/task_profiles.json \
    $(LOCAL_PATH)/prebuilt/firmware/ili9882U.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/ili9882U.bin \
    $(CRYPTO_PREBUILT)/vendor/bin/teei_daemon:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/teei_daemon \
    $(CRYPTO_PREBUILT)/vendor/bin/hw/android.hardware.keymaster@4.1-service.beanpod:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/android.hardware.keymaster@4.1-service.beanpod \
    $(CRYPTO_PREBUILT)/vendor/bin/hw/android.hardware.gatekeeper-service.beanpod:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/android.hardware.gatekeeper-service.beanpod \
    $(CRYPTO_PREBUILT)/vendor/lib64/libTEECommon.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libTEECommon.so \
    $(CRYPTO_PREBUILT)/vendor/lib64/libteei_daemon_vfs.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libteei_daemon_vfs.so \
    $(CRYPTO_PREBUILT)/vendor/lib64/libkeymaster4.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkeymaster4.so \
    $(CRYPTO_PREBUILT)/vendor/lib64/libkeymaster41.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkeymaster41.so \
    $(CRYPTO_PREBUILT)/vendor/lib64/libc++.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libc++.so \
    $(CRYPTO_PREBUILT)/vendor/lib64/hw/kmsetkey.beanpod.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/kmsetkey.beanpod.so

PRODUCT_COPY_FILES += \
    $(foreach f,$(wildcard $(CRYPTO_PREBUILT)/vendor/thh/ta/*),$(f):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/$(notdir $(f)))

PRODUCT_PACKAGES += \
    lenovo_module_loader.recovery \
    lenovo_touch_compat.ko.recovery \
    touch_common.ko.recovery \
    ilitek_spi.ko.recovery
