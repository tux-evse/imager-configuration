

# System bootloader configuration
bootloader --location=mbr --boot-drive=vda --append="security=smack console=ttyS0"

# Partitioning X86 images
autopart --nolvm
zerombr
# Partition clearing information
clearpart --none --initlabel