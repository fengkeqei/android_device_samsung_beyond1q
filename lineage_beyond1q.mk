#
# Copyright (C) 2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

## SoC / codename strings for the AviumUI About-phone card.
## vendor/avium/config/avium.mk defaults both to "Unknown" with ?=, and
## vendor/avium/config/prop.mk bakes them into PRODUCT_BUILD_PROP_OVERRIDES as
## AviumSocName / AviumDeviceName at the moment it is parsed. Both happen inside
## the common_full_phone.mk inherit below, so these must be set BEFORE it --
## assigning them afterwards leaves ro.avium.soc.model / ro.avium.device.codename
## at "Unknown" (Kati expands PRODUCT_BUILD_PROP_OVERRIDES eagerly).
AVIUM_SETTINGS_SOC_MODEL_NAME := Snapdragon 855
AVIUM_SETTINGS_DEVICE_CODENAME := beyond1q

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

## SoC identification. ro.board.platform is set by BoardConfig (msmnile);
## ro.soc.* is what Settings > About phone reads (Build.SOC_MODEL /
## Build.SOC_MANUFACTURER). SM8150 = Snapdragon 855 (Exynos-less SM-G9730).
##
## Do NOT add ro.soc.model.name here: PRODUCT_PRODUCT_PROPERTIES is word-split
## by Kati, so a value with a space ("Snapdragon 855") lands as
##   ro.soc.model.name=Snapdragon
##   855
## i.e. a truncated prop plus a bogus key-less line. The marketing name goes
## through ro.avium.soc.model instead (see AViUM_SETTINGS_SOC_MODEL_NAME below),
## which gen_build_prop.py writes verbatim.
PRODUCT_PRODUCT_PROPERTIES += \
    ro.soc.manufacturer=Qualcomm \
    ro.soc.model=SM8150

## Maintainer shown on the AviumUI About-phone card.
## vendor/avium/config/version.mk already emits
##   ro.avium.maintainer=$(AVIUM_MAINTAINER)
## so setting the variable is the supported way to fill it in; adding a second
## ro.avium.maintainer line here makes gen_build_prop abort with
##   error: found duplicate sysprop assignments
AVIUM_MAINTAINER := Fengkewei

## OTA/recovery assert list. Stock firmware (and OrangeFox, which reads the
## device tree) identifies this model as beyond1qlte / beyond1qltezc, while the
## Lineage-style tree uses beyond1q; accept all so recovery-side flashes pass.
TARGET_OTA_ASSERT_DEVICE := beyond1q,beyond1qlte,beyond1qltezc,beyond1qltechn

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
