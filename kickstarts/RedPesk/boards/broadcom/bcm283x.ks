%include ../../arch/arm-base.ks
%include ../../arch/arm-boot-vfat.ks


%post --erroronfail --log /tmp/post-bcm283x.log
# Set your board specific post actions here
%end


%packages
bcm283x-firmware
%end