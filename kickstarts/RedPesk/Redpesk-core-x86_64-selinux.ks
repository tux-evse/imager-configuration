%include features/selinux.ks
%include images/core-x86_64.ks

# System bootloader configuration
bootloader --location=mbr --boot-drive="/dev/mapper/Redpesk-OS" --append="security=selinux console=ttyS0,115200"