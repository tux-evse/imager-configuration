%include AM62x.ks


%post --erroronfail --log /tmp/post-rpi.log

%end


%packages
-uboot-images-armv7
-uboot-images-armv8
#uboot
kernel-modules-extra
kernel-modules

#Add cockpit
cockpit
cockpit-storaged
cockpit-tests
cockpit-pcp

#Add evse demo
evse-display-manager-binder

#Add demo configuration package
tux-evse-board-configuration

%end