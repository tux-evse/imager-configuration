%include features/selinux.ks
%include images/minimal-aarch64.ks

bootloader --location=mbr --timeout=1 --boot-drive="/dev/mapper/Redpesk-OS"  --append="security=selinux console=tty1"