# Beyond1q device makefile
$(call inherit-product, device/samsung/sm8150-common/device.mk)

# bcmdhd PCIe runtime PM fix (Round 60): BCM4375 D3 resume skips RX ring
# buffers -> RX throughput collapses (~3-5 MB/s LAN, rate stuck at low MCS).
# dhd_rpm issues the PCIE_RPM_DISABLE private ioctl; wifi_pm_fix.sh is a
# watcher service (started from beyond1q_product_bind.rc at boot_completed)
# that re-issues it every 15s since reconnects/driver reload reset idletime.
# A/B measured on same connection: RPM on 9.2 -> off 13.1 MB/s.
PRODUCT_COPY_FILES += \
    device/samsung/beyond1q/beyond1q_product_bind.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/beyond1q_product_bind.rc \
    device/samsung/beyond1q/wifi_pm_fix.sh:$(TARGET_COPY_OUT_VENDOR)/bin/wifi_pm_fix.sh

# dhd_rpm / wl_cmd are ELF prebuilts -> declared as cc_prebuilt_binary in
# device/samsung/beyond1q/Android.bp (PRODUCT_COPY_FILES rejects ELF files).
PRODUCT_PACKAGES += \
    dhd_rpm \
    wl_cmd

# WiFi SAE disable overlay (bcmdhd FullMAC SAE broken on stock fw)
PRODUCT_PACKAGES += Beyond1qWifiOverlay

# Static framework-res overlay: punch-hole cutout declaration.
# Stock One UI leaves config_mainBuiltInDisplayCutout empty and handles the
# Infinity-O hole in its own SystemUI, so declare it ourselves. Path matches
# the LineageOS official beyond1lte tree (same panel): 203x149 px top-right.
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# lineage light HAL (AIDL v2): scales brightness dynamically against
# max_brightness read from sysfs (50000 for the S6E3FA7 panel), so the full
# range is usable (stock samsung light-service hardcoded a x100 scale, i.e.
# max 25500/50000 = 51%, and HBM via >25500 levels was unreachable).
# Panel driver auto-selects HBM command path for levels >= HBM min_lv
# (verified: level 50000 -> candela 800, hbm: 1).
# VINTF note: ONLY ONE light fragment may exist in /vendor/etc/vintf/manifest/
# - stock lights-default-sec.xml must NOT be installed alongside this (@1 vs
# @2 conflict would reject every AIDL HAL again, see Round 51). Same for init
# rc files: init parses every file in /vendor/etc/init/ regardless of
# extension (a .rc.disabled was still parsed!), so stock rc must be dropped
# from the tree entirely (done: removed from proprietary-files.txt).
PRODUCT_PACKAGES += \
    android.hardware.light-service.lineage \
