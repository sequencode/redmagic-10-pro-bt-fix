#!/system/bin/sh
ui_print "*********************************************"
ui_print "  RedMagic 10 Pro GSI Bluetooth A2DP Fix"
ui_print "*********************************************"
set_perm "$MODPATH/service.sh"       root root 0755
set_perm "$MODPATH/post-fs-data.sh"  root root 0755
set_perm "$MODPATH/common.sh"        root root 0755
ui_print "- Done. Please reboot to apply."
ui_print "*********************************************"
