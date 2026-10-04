#
# Copyright (C) 2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

## Inherit from generic products, most specific first
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)

## Product API level
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_p.mk)

## Disable UFFD GC: kernel 4.14 has no CONFIG_USERFAULTFD, and building the
## platform boot image with --runtime-arg -Xgc:CMC records concurrent-copying
## =false while the (apex) runtime defaults to CC -> zygote aborts on
## "read barrier state mismatch". Let dex2oat use the runtime default (CC).
PRODUCT_ENABLE_UFFD_GC := false

## Inherit from beyond1q device
$(call inherit-product, device/samsung/beyond1q/device.mk)

## Inherit from sm8150-common
$(call inherit-product, device/samsung/sm8150-common/common.mk)

## Inherit some common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

## Device identifier, this must come after all inclusions
PRODUCT_NAME := lineage_beyond1q
PRODUCT_DEVICE := beyond1q
PRODUCT_BRAND := samsung
PRODUCT_MODEL := Galaxy S10
PRODUCT_MANUFACTURER := samsung

## Boot animation
TARGET_BOOTANIMATION_HALF_RES := true
TARGET_SCREEN_HEIGHT := 3040
TARGET_SCREEN_WIDTH := 1440

## Prefer Samsung vendor binaries over AOSP sources for these
PRODUCT_PACKAGES := $(filter-out rild,$(PRODUCT_PACKAGES))

## beyond1q port (Round 50): Broadcom BCM4375 (not BOARD_HAVE_BLUETOOTH_QCOM), so the
## qcom bt-system-opensource-product.mk profile property block does not apply. Without
## these, BluetoothProperties.isProfile*Enabled().orElse(false) disables every classic
## profile (A2DP/AVRCP/HFP/...) -> paired headsets unusable.
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.profile.a2dp.source.enabled=true \
    bluetooth.profile.avrcp.target.enabled=true \
    bluetooth.profile.avrcp.controller.enabled=true \
    bluetooth.profile.hfp.ag.enabled=true \
    bluetooth.profile.hfp.client.enabled=true \
    bluetooth.profile.gatt.enabled=true \
    bluetooth.profile.hid.host.enabled=true \
    bluetooth.profile.hid.device.enabled=false \
    bluetooth.profile.map.server.enabled=true \
    bluetooth.profile.opp.enabled=true \
    bluetooth.profile.pan.nap.enabled=true \
    bluetooth.profile.pan.panu.enabled=true \
    bluetooth.profile.pbap.server.enabled=true \
    bluetooth.profile.bas.client.enabled=true \
    bluetooth.device_id.vendor_id=0x001D

## The allow-list is set (read-only) by vendor/lineage/config/common.mk via
## enforce-product-packages-exist-internal, so extend it there instead.
