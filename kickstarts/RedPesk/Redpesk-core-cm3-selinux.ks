%include features/selinux.ks
%include images/core-cm3.ks
%include features/extract_logs.ks

# Disabling bootloader for ARM images
bootloader --location=none --disabled
