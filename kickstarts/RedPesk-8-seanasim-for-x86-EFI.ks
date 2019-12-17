#version=DEVEL
# Keyboard layouts
keyboard --vckeymap=fr --xlayouts='fr'
# Root password
rootpw --plaintext demo2020
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
part pv.01 --grow
volgroup redpesk-vg0 pv.01
logvol / --fstype="ext4" --grow --size=7000 --label="root" --name=root --vgname=redpesk-vg0
logvol swap --fstype="swap" --size=1000 --label="swap" --name=swap --vgname=redpesk-vg0

# demo user
#user --name demoCES2020 --password demo2020



%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' redpesk-release)
basearch=x86_64
#wget http://kojihub01.lorient.iot/iotbzh-repositories/m3ulcb-bsp/RPM-GPG-KEY-RedPesk-Bootstrap -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RedPesk-Bootstrap
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redPesk-8-primary
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
#tweak repo files (TO BE REMOVED !!!!)
cat << EOF > /etc/yum.repos.d/fedora.repo
[fedora]
name=Fedora 2\$releasever - \$basearch
#baseurl=http://download.fedoraproject.org/pub/fedora/linux/releases/2\$releasever/Everything/\$basearch/os/
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-2\$releasever&arch=\$basearch
enabled=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-\$releasever-\$basearch
skip_if_unavailable=False

[fedora-updates]
name=Fedora 2\$releasever - \$basearch - Updates
#baseurl=http://download.fedoraproject.org/pub/fedora/linux/updates/2\$releasever/Everything/\$basearch/
metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f2\$releasever&arch=\$basearch
enabled=1
repo_gpgcheck=0
type=rpm
gpgcheck=0
metadata_expire=6h
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-\$releasever-primary
skip_if_unavailable=False
EOF

cat << EOF > /etc/yum.repos.d/redpesk.repo
[redpesk]
name=RedPesk \$releasever - \$basearch
baseurl=http://kojihub.lorient.iot/kojifiles/repos-dist/0_RedPesk_HH-release/latest/\$basearch
#metalink=https://mirrors.redpesk.bzh/metalink?repo=redpesk-\$releasever&arch=\$basearch
enabled=1
#metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-\$releasever-\$basearch
skip_if_unavailable=False

[redpesk-debuginfo]
name=RedPesk \$releasever - \$basearch - Debug
baseurl=http://kojihub.lorient.iot/kojifiles/repos-dist/0_RedPesk_HH-release/latest/\$basearch/
#metalink=https://mirrors.redpesk.bzh/metalink?repo=redpesk-debug-\$releasever&arch=\$basearch
enabled=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-\$releasever-\$basearch
skip_if_unavailable=False

[redpesk-source]
name=RedPesk \$releasever - Source
baseurl=http://kojihub.lorient.iot/kojifiles/repos-dist/0_RedPesk_HH-release/\$basearch/
#metalink=https://mirrors.redpesk.bzh/metalink?repo=redpesk-source-\$releasever&arch=\$basearch
enabled=0
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redpesk-\$releasever-\$basearch/
skip_if_unavailable=False
EOF
%end


%post
# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# Add by default the ttyS0 as console device at boot time
sed -i -r 's:nomodeset( ?): :' /etc/default/grub
sed -i -r 's:quiet( ?):\1:' /etc/default/grub
grub2-mkconfig -o /etc/grub2-efi.cfg

%end

%packages
@core
redpesk-release-iot
redpesk-repos
initial-setup
#wget
sway
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
redpesk-seanasim
# agl
agl-app-framework-binder
agl-app-framework-main
agl-appli-homescreen-html
#agl-appli-mixer-html
%end
