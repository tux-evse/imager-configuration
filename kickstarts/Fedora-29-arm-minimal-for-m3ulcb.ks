# Use the text interface not the graphical one
text
#version=DEVEL
eula --agreed
# Use automatic partioning on vda
ignoredisk --only-use=vda
# System language
lang en_US.UTF-8
# Keyboard layouts
keyboard --vckeymap=fr --xlayouts='fr'
# Use network installation
url --mirrorlist "https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-29&arch=aarch64"
# Additionnal repositories
repo --name="m3ulcb-bsp" --baseurl="http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/" --cost=1 --install
# System authorization information
auth --useshadow --passalgo=sha512
# Firewall configuration
firewall --enabled --service=mdns,ssh
# Run the Setup Agent on first boot
firstboot --reconfig
# SELinux configuration
selinux --disabled
# Timezone setup
timezone --isUtc Europe/Paris
# Root password setup
rootpw Image_is_securized!
# Do not configure the X Window System
skipx
# Poweroff the image once installed
poweroff
# Do the install
install

# System services
services --enabled="sshd,NetworkManager,chronyd,initial-setup"
# System bootloader configuration
zerombr
bootloader --location=mbr --boot-drive=vda
# Partition clearing information
clearpart --none --initlabel
autopart --nolvm

%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' fedora-release)
basearch=aarch64
wget http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/RPM-GPG-KEY-rfor -o /etc/pki/rpm-gpg/RPM-GPG-KEY-rfor
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rfor
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
echo "Packages within this ARM disk image"
rpm -qa
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# Because memory is scarce resource in most arm systems we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount

dnf -y remove dracut-config-generic

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end

%post

# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

%end

%packages
@arm-tools
@core
@hardware-support
NetworkManager-wifi
bcm283x-firmware
chkconfig
wget
chrony
dracut-config-generic
extlinux-bootloader
glibc-langpack-en
initial-setup
iw
kernel
kernel-dev
kernel-modules
rng-tools
zram
-@standard
-dracut-config-rescue
-generic-release*
-glibc-all-langpacks
-initial-setup-gui
-iproute-tc
-ipw*
-iwl*
-trousers
-uboot-images-armv8
-usb_modeswitch
-xkeyboard-config

%end
