%include ulcb.ks

# Additional repositories
repo --name="m3ulcb-bsp" --baseurl="http://kojihub.lorient.iot/kojifiles/repos/M3-bsp--RedPesk-8-build/latest/aarch64/" --cost=1 --install


%post --erroronfail --log /tmp/post-board.log
cat << EOF >> /etc/yum.repos.d/redpesk-rcar-m3ulcb.repo
[m3ulcb-bsp]
name=Redpesk m3ulcb BSP $releasever - $basearch
failovermethod=priority
#baseurl=http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/
#metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
baseurl=http://kojihub.lorient.iot/kojifiles/repos/M3-bsp--RedPesk-8-build/latest/aarch64/
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
# Yocto BSP kernel
kernel-4.14.75+git0+59ccbcefae-r1+m3ulcb
kernel-modules-4.14.75+git0+59ccbcefae-r1+m3ulcb
%end
