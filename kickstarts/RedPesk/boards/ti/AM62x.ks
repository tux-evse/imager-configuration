%include ../../arch/arm-base.ks
%include ../../arch/arm-boot-msdos-vfat.ks


%post --erroronfail --log /tmp/post-AM62x.log
# Set your board specific post actions here

cp /var/lib/uboot_firmware/tiboot3.bin /firmware
cp /var/lib/uboot_firmware/tispl.bin /firmware
cp /var/lib/uboot_firmware/u-boot.img /firmware

%end


%packages

%end