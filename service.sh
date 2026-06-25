#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"
LOG=/data/local/tmp/btfix.log
LOCK=/data/local/tmp/btfix.lock

log() { echo "$(date '+%H:%M:%S') uptime=$(cut -d. -f1 /proc/uptime)s $*" >> "$LOG"; }

# Single-instance guard — bail out if another copy is already running.
if ! mkdir "$LOCK" 2>/dev/null; then exit 0; fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

: > "$LOG" 2>/dev/null
log "start"

while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done

RP=$(find_resetprop)
log "resetprop: $RP"

# Retry loop: re-assert offload props, stop sysbta, bounce audioserver,
# then cycle the BT adapter to force A2DP re-negotiation.
i=0
while [ "$i" -lt 6 ]; do
    i=$((i + 1))

    "$RP" -n ro.bluetooth.a2dp_offload.supported true
    "$RP" -n bluetooth.a2dp.offload.enabled true
    "$RP" persist.bluetooth.a2dp_offload.disabled false

    sysbta_running && { setprop ctl.stop "$SYSBTA_SVC"; sleep 1; }

    setprop ctl.restart audioserver
    sleep 6

    # Re-assert before toggling the adapter — audioserver restarts can clear ro.* overrides.
    "$RP" -n ro.bluetooth.a2dp_offload.supported true
    "$RP" -n bluetooth.a2dp.offload.enabled true

    cmd bluetooth_manager disable > /dev/null 2>&1
    sleep 4

    "$RP" -n ro.bluetooth.a2dp_offload.supported true
    cmd bluetooth_manager enable > /dev/null 2>&1
    sleep 16

    if fix_applied; then
        log "fixed on pass $i (offload=y reg=$(bt_a2dp_registered && echo y || echo n))"
        exit 0
    fi
    log "pass $i not yet (offload=$(a2dp_offload_on && echo y || echo n) reg=$(bt_a2dp_registered && echo y || echo n) buds=$(a2dp_device_connected && echo y || echo n))"
    sleep 8
done
log "gave up after $i passes"
