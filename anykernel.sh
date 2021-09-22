# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ViPER4Android FX Rootless Installer
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=auto;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
#set_perm_recursive 0 0 755 644 $ramdisk/*;
#set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
install_viper4android() {
  backup_file /system/etc/selinux/plat_sepolicy.cil
  backup_file /system/etc/selinux/plat_and_mapping_sepolicy.cil.sha256
  echo "" > /system/etc/selinux/plat_and_mapping_sepolicy.cil.sha256
  echo "(allow hal_audio_default hal_audio_default (process (execmem)))" >> /system/etc/selinux/plat_sepolicy.cil

  mkdir -p /system/priv-app/ViPER4AndroidFX
  cp -f $patch/ViPER4AndroidFX.apk /system/priv-app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  cp -f $patch/libv4a_fx.so /vendor/lib/soundfx/libv4a_fx.so
  cp -f $patch/init.v4afx.rc /system/etc/init/init.v4afx.rc
  cp -f $patch/v4afx.sh /system/bin/v4afx.sh
  chmod 0644 /system/priv-app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  chmod 0644 /vendor/lib/soundfx/libv4a_fx.so
  chmod 0644 /system/etc/init/init.v4afx.rc
  chmod 0755 /system/priv-app/ViPER4AndroidFX
  chmod 0755 /system/bin/v4afx.sh
  chown root:shell /system/bin/v4afx.sh

  [ -f /system/lib/libstdc++.so ] && [ ! -f /vendor/lib/libstdc++.so ] && cp -f /system/lib/libstdc++.so /vendor/lib/libstdc++.so

  find -L /system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" | while read FILE
  do
    sed -i "/v4a_standard_fx {/,/}/d" $FILE
    sed -i "/v4a_fx {/,/}/d" $FILE
    sed -i "/v4a_standard_fx/d" $FILE
    sed -i "/v4a_fx/d" $FILE
    sed -i "s/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g" $FILE
    sed -i "s/^libraries {/libraries {\n  v4a_fx {\n    path \/vendor\/lib\/soundfx\/libv4a_fx.so\n  }/g" $FILE
    sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx.so\"\/>" $FILE
    sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/>" $FILE
  done
}

uninstall_viper4android() {
  restore_file /system/etc/selinux/plat_sepolicy.cil
  restore_file /system/etc/selinux/plat_and_mapping_sepolicy.cil.sha256

  rm -rf /system/priv-app/ViPER4AndroidFX
  rm -rf /vendor/lib/soundfx/libv4a_fx.so
  rm -rf /system/etc/init/init.v4afx.rc
  rm -rf /system/bin/v4afx.sh

  [ -f /system/lib/libstdc++.so ] && [ -f /vendor/lib/libstdc++.so ] && rm -rf /vendor/lib/libstdc++.so

  find -L /system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" | while read FILE
  do
    sed -i "/v4a_standard_fx {/,/}/d" $FILE
    sed -i "/v4a_fx {/,/}/d" $FILE
    sed -i "/v4a_standard_fx/d" $FILE
    sed -i "/v4a_fx/d" $FILE
  done
}

if [ ! -d /system/priv-app/ViPER4AndroidFX ]
then
  install_viper4android
else
  uninstall_viper4android
fi
