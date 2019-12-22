#version=DEVEL
# Keyboard layouts
keyboard --vckeymap=fr --xlayouts='fr'
# Root password
rootpw --plaintext demo
# set hostname
network --hostname CES2020-nuc
# System language
lang en_US.UTF-8
# License agreement
eula --agreed
# Reboot after installation
reboot
# System timezone
timezone Europe/Paris --isUtc
# System authorization information
auth --useshadow --passalgo=sha512
# Firewall configuration
firewall --enabled --service=mdns,ssh
ignoredisk --only-use=vda
repo --name="koji-override-0" --baseurl=http://kojihub.lorient.iot/kojifiles/repos/0_RedPesk_HH-build/latest/x86_64/
repo --name="koji-override-1" --baseurl=http://fmirrors.lorient.iot/fmirrors/fedora/linux/releases/28/Everything/x86_64/os
# Use network installation
#url --url="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/28/Everything/x86_64/os/"
url --url="http://fmirrors.lorient.iot/fmirrors/fedora/linux/releases/28/Everything/x86_64/os"
# Run the Setup Agent on first boot
firstboot --reconfig
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
text

# System services
services --enabled="sshd,NetworkManager,chronyd,initial-setup"
# System bootloader configuration
#bootloader --location=mbr --boot-drive=vda
bootloader --location=mbr --boot-drive=vda --append=" security=none"
reqpart --add-boot
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part / --fstype="ext4" --grow --size=7000 --label="root
part swap --fstype="swap" --size=1000 --label="swap"


%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' redpesk-release)
basearch=x86_64
#wget http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/RPM-GPG-KEY-RedPesk-Bootstrap -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-8-primary
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
echo "Packages within this disk image"
rpm -qa
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id
%end

%post
# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

sed -i -r 's:(nomodeset|quiet|rhgb) ?: :g' /etc/default/grub
grub2-mkconfig -o /etc/grub2-efi.cfg

%end

%packages
@core
redpesk-release-iot
redpesk-repos
redpesk-seanasim-x64
initial-setup
iotop
htop
i3
i3status
rofi
opencpn
#for Johann :)
nano
#for Romain :p
vim
alsa-lib
alsa-tools
alsa-utils
alsa-firmware
# TODO : get rid of PA if we get 4A working
pulseaudio
pulseaudio-utils
sox
#anbox
electron
# agl
agl-app-framework-binder
agl-app-framework-main
agl-appli-homescreen-html
agl-appli-mixer-html
4a-mixer
web-mumble
%end
