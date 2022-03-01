%include features/selinux.ks
%include images/minimal-armv7hl.ks
%include features/extract_logs.ks

bootloader --location=mbr --timeout=1 --boot-drive="/dev/mapper/Redpesk-OS" --append="security=selinux console=tty1"