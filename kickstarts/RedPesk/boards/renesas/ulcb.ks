%include ../../arch/arm-base.ks
%include ../../arch/arm-boot-ext4.ks


%post
# Generating missing initramfs for Yocto kernel that could not be generated by
# anaconda because of Yocto packaging method.
dracut --kver $(find /boot -name Image*yocto* | sed 's:^.*Image-::')
%end


%packages
kernel-dev
kernel-devicetree
# Yocto BSP kernel is included from the bsp repo
kernel-modules
-uboot-images-armv7
-uboot-tools
%end