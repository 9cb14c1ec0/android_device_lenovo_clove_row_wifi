$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/lenovo/clove_row_wifi/device.mk)

PRODUCT_DEVICE := clove_row_wifi
PRODUCT_NAME := twrp_clove_row_wifi
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := TB305FU
PRODUCT_MANUFACTURER := LENOVO

# Keep the initial Android 14.1 recovery baseline compatible with the device
# tree's established API level. Stock firmware itself is API 35.
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_USE_DYNAMIC_PARTITIONS := true
