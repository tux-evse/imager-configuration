#version=DEVEL
ignoredisk --only-use=vda
# Network install
url --url=http://fmirrors.lorient.iot/fmirrors/fedora/linux/releases/30/Everything/x86_64/os/
# Use graphical install
graphical
# Keyboard layouts
keyboard --vckeymap=fr-azerty --xlayouts='fr (azerty)'
# System language
lang en_US.UTF-8
# Partition clearing information
clearpart --none --initlabel
reqpart --add-boot
part pv.01 --grow
volgroup redpesk-vg0 pv.01
logvol / --label root --name root --fstype ext4 --vgname redpesk-vg0 --size 7000 --grow
logvol swap --label swap --name swap --fstype swap --vgname redpesk-vg0 --size 1000
# Root password setup
rootpw packer
reboot
install

# Network information
network  --bootproto=dhcp --device=ens3 --ipv6=auto --activate
network  --hostname=redpesk-buildhub
# Run the Setup Agent on first boot
firstboot --disable
# Do not configure the X Window System
skipx
# System services
services --enabled="chronyd,sshd,NetworkManager,qemu-guest-agent"
# System timezone
timezone Europe/Paris --isUtc --ntpservers=issp.lorient.iot
user --groups=wheel --name=koji --password=$6$6CY2Jpf7epYpnE1e$PqHzZzNTjXlnu1048HtouSSqfGqO0h0KxzEyCaCxCl52bBi0qHbSAg24wMPAKnedGUXYFzOTXX/Z92eSB8p4S0 --iscrypted --gecos="koji"

%packages
@server-product-environment
qemu-guest-agent

%end

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
