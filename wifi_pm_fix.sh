#!/system/bin/sh
# wifi_pm_fix.sh - keep bcmdhd PCIe runtime PM off and wifi power_save off.
#
# Root cause (Round 50b / Round 60): BCM4375 PCIe runtime suspend (D3) resume
# skips RX ring buffers (dhdpci_bus_read_frames: "Bus is in power save state").
# RX throughput collapses to ~3-5 MB/s and the rate adaptation gets stuck at
# low MCS. One-shot exec at sys.boot_completed races with wlan0 readiness and
# is also undone by driver reload / reconnect (idletime resets to 11).
#
# This watcher waits for wlan0, then re-issues PCIE_RPM_DISABLE every 15s and
# keeps 802.11 power save off (PS adds 30-40ms RTT for interactive use and
# framework re-enables it on screen-off). Cost: minor battery, kernel log line
# every 15s. Measured: LAN downlink 3.1 -> 6.2 MB/s (2.4G HT20 AP limit),
# tx bitrate 51.5 -> 137.5 Mbps.
i=0
while [ $i -lt 90 ]; do
    [ -d /sys/class/net/wlan0 ] && break
    sleep 1
    i=$((i+1))
done
while true; do
    if [ -d /sys/class/net/wlan0 ]; then
        /vendor/bin/dhd_rpm wlan0 disable >/dev/null 2>&1
        /system/bin/iw dev wlan0 set power_save off 2>/dev/null
        # Round 62b: bcmdhd APF (Android Packet Filter, iovar filter id 200)
        # runs with REVERSED semantics when in_suspend is stuck: on every
        # (re)connect the framework installs its 244-byte program and the
        # driver enables it as FORWARD_ON_MATCH (match=forward, else drop),
        # which drops ALL downlink unicast data (AOSP program permits them
        # by not matching) while forwarding broadcast. Verified by A/B:
        # pkt_filter_enable id=200 -> UDP RX 0 bytes; disable -> instant
        # recovery. Re-issue disable every cycle like the RPM fix above;
        # payload = filter id 200 LE (c8000000) + enable byte 0.
        /vendor/bin/wl_cmd wlan0 set pkt_filter_enable c800000000000000 >/dev/null 2>&1
    fi
    sleep 15
done
