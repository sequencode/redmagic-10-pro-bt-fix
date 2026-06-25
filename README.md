# RedMagic 10 Pro GSI — Bluetooth A2DP Fix

APatch / KernelSU / Magisk module for the **RedMagic 10 Pro (NX789J)**.

Fixes Bluetooth A2DP audio on phh-treble GSIs where media refuses to route to a
wireless headset — either staying on the speaker or cutting out after a second.

## What it does

On GSIs the system BT-audio HAL (`sysbta`) occupies the A2DP provider slot and
blocks hardware offload. This module stops `sysbta`, forces the A2DP offload
properties, and bounces `audioserver` + the BT adapter until media routes
correctly. It retries up to six times and exits cleanly once the headset is
confirmed in the audio policy.

## Requirements

| | |
|---|---|
| Device | RedMagic 10 Pro (NX789J) |
| Root | APatch · KernelSU · Magisk |
| Tested on | Android 16 GSI (phh-treble) |

Flash via APatch / KernelSU / Magisk and reboot.

**[Download latest release](https://github.com/sequencode/redmagic-10-pro-bt-fix/releases/latest)**

> Aborts silently on unsupported devices.
