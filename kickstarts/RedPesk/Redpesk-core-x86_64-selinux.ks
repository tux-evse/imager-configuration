%include features/selinux.ks
%include images/core-x86_64.ks

# System bootloader configuration
bootloader --location=mbr --boot-drive=vda --append="security=selinux console=ttyS0"