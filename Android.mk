# Depth-2 shim: AOSP only auto-includes device/*/*/Android.mk,
# so pull in the common tree's nested makefiles here.
include device/samsung/sm8150-common/rootdir/Android.mk

# v136: native Make prebuilts for the vendor blobs that used to be injected by
# fix_vendor_mountpoints.sh (stock libs, firmware, gatekeeper, rild, display
# allocator, mount-point placeholders).
include device/samsung/sm8150-common/vendor_native_prebuilts.mk

# Stock HIDL interface libraries the prebuilt vendor HALs DT_NEEDED. Generated
# by gen_vendor_hidl_prebuilts.py from the same list the old debugfs injector
# used, so vendor.img is self-contained and no longer needs post-processing.
include device/samsung/sm8150-common/vendor_hidl_prebuilts.mk
