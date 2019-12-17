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
#url --mirrorlist "https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-28&arch=aarch64"
# Additionnal repositories
repo --name="RedPesk" --baseurl="http://kojihub.lorient.iot/kojifiles/repos-dist/0_RedPesk_HH-release/latest/aarch64/" --cost=1 --install
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
rootpw demo2020
# set hostname
network --hostname CES2020-m3ulcb
# Do not configure the X Window System
skipx
# Reboot the image once installed. ImageFactory look for that!
reboot
# Do the install
install

# System services
services --enabled="sshd,NetworkManager,chronyd,initial-setup"
# System bootloader configuration
zerombr
bootloader --location=mbr --boot-drive=vda --append=" security=none"
# Partition clearing information
clearpart --none --initlabel
autopart --nolvm

%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' fedora-release)
basearch=aarch64
wget http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/RPM-GPG-KEY-RedPesk-Bootstrap -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
wget http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/RPM-GPG-KEY-rfor -O /etc/pki/rpm-gpg/RPM-GPG-KEY-rfor
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rfor
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-8-primary
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
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

# Generating missing initramfs for Yocto kernel that could not be generated by
# anaconda because of Yocto packaging method.
dracut --kver $(find /boot -name Image*yocto* | sed 's:^.*Image-::')
%end

%post
# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

cat << EOF >> /etc/yum.repos.d/redpesk-rcar-m3ulcb.repo
[m3ulcb-bsp]
name=Redpesk m3ulcb BSP $releasever - $basearch
failovermethod=priority
#baseurl=http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/
#metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
baseurl=http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/
enabled=1
#metadata_expire=7d
#repo_gpgcheck=0
type=rpm
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
skip_if_unavailable=False
EOF
%end

%packages
@arm-tools
@core
@hardware-support
#NetworkManager-wifi
bcm283x-firmware
chkconfig
wget
tar
chrony
dracut-config-generic
extlinux-bootloader
glibc-langpack-en
initial-setup
#iw
rng-tools
redpesk-repos
redpesk-release-iot
# Yocto BSP kernel
kernel-4.14.75+git0+1d76a004d3-r1
kernel-dev
kernel-devicetree
kernel-modules-4.14.75+git0+1d76a004d3-r1
-@standard
-dracut-config-rescue
-generic-release*
-initial-setup-gui
-iproute-tc
-ipw*
-iwl*
-trousers
-uboot-images-armv8
-usb_modeswitch
-xkeyboard-config

# specific for seanasim
agl-service-can-low-level
agl-service-signal-composer
murmur

# ...Wanted packages, Waiting for functionnal SPEC files...
# autopilot
# modbus
# can-eth

#agl-service-can-low-level
#agl-service-gps
#agl-service-helloworld
#agl-service-modbus
#agl-service-signal-composer

%end
