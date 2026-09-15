#!/system/bin/sh

# Use recovery's Binder runtime. Loading a second libbinder copy makes the
# service and servicemanager disagree on the Parcel header format.
# Vendor provides the Android 15 C++ runtime required by this blob, but no
# libbinder; Binder therefore falls through to recovery's compatible copy.
export LD_LIBRARY_PATH=/vendor/lib64:/system/lib64
exec /system/bin/android.hardware.gatekeeper-service.beanpod
