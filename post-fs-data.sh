#!/system/bin/sh
# Set Bluetooth A2DP offload props before the BT stack starts.
MODDIR=${0%/*}

# Find resetprop — APatch and KernelSU ship it under their own data dir,
# Magisk puts it on PATH.
for _rp in /data/adb/ap/bin/resetprop /data/adb/ksu/bin/resetprop; do
    [ -x "$_rp" ] && RESETPROP="$_rp" && break
done
[ -z "$RESETPROP" ] && command -v resetprop > /dev/null 2>&1 && RESETPROP=resetprop

if [ -n "$RESETPROP" ]; then
    "$RESETPROP" -n ro.bluetooth.a2dp_offload.supported true
    "$RESETPROP" -n bluetooth.a2dp.offload.enabled true
    "$RESETPROP" persist.bluetooth.a2dp_offload.disabled false
    "$RESETPROP" persist.bluetooth.system_audio_hal.enabled false
fi
