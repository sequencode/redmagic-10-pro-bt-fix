#!/system/bin/sh
# Shared helpers for service.sh. Sourced at runtime, not executed directly.

# Locate resetprop — Magisk puts it on PATH; APatch and KernelSU ship it
# under their own data directory.
find_resetprop() {
    for c in /data/adb/ap/bin/resetprop /data/adb/ksu/bin/resetprop; do
        [ -x "$c" ] && echo "$c" && return 0
    done
    command -v resetprop > /dev/null 2>&1 && echo resetprop && return 0
    mp=$(magisk --path 2>/dev/null) && [ -x "$mp/.magisk/busybox/resetprop" ] && {
        echo "$mp/.magisk/busybox/resetprop"
        return 0
    }
    # Last resort — setprop can't write ro.* but better than nothing.
    echo setprop
}

SYSBTA_PROC=android.hardware.bluetooth.audio-service-system
SYSBTA_SVC=system.bt-audio-hal

sysbta_running() {
    pgrep -f "$SYSBTA_PROC" > /dev/null 2>&1
}

# True once the Bluetooth stack reports A2DP offload as enabled.
a2dp_offload_on() {
    dumpsys bluetooth_manager 2>/dev/null | grep -q 'mA2dpOffloadEnabled: true'
}

# True if an A2DP headset is currently connected at the BT stack level.
a2dp_device_connected() {
    dumpsys bluetooth_manager 2>/dev/null \
        | sed -n '/BluetoothActiveDeviceManager/,/HFP:/p' \
        | grep -A1 'A2DP:' | grep -q 'Connected: [1-9]'
}

# True once the headset appears as an output in the audio policy.
# This is what actually decides whether media routes to the buds.
bt_a2dp_registered() {
    dumpsys audio 2>/dev/null | grep -A8 'Connected devices:' | grep -q '(bt_a2dp)'
}

# The fix is in effect when offload is on, sysbta is gone, and — if a headset
# is connected — it shows up in the audio policy.
fix_applied() {
    a2dp_offload_on && ! sysbta_running || return 1
    if a2dp_device_connected; then
        bt_a2dp_registered
    else
        return 0
    fi
}
