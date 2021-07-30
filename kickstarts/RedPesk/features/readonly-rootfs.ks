%post --erroronfail --log /tmp/post-readonly.log

# Create statetab.d folder to declare rw persistent folders and files
mkdir -p /etc/statetab.d

echo "dirs /var/lib" > /etc/statetab.d/varlib
echo "dirs /etc/ssh" > /etc/statetab.d/ssh-config
echo "dirs /home/0/app-data" > /etc/statetab.d/bindings-data
echo "dirs /var/scope-platform" >> /etc/statetab.d/bindings-data

echo "files /etc/localtime" >> /etc/statetab.d/others
echo "files /etc/hostname" >> /etc/statetab.d/others

# Add rw files and/or folder in memory
echo "files /etc/machine-id" >> /etc/rwtab

# Use config partition for stateless partition
sed -i 's/STATE_LABEL=stateless-state/STATE_LABEL=config/g' /etc/sysconfig/readonly-root

# Fix NetworkManager DNS resolving
rm -f /etc/resolv.conf
ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf

# Enable fedora service for readonly rootfs by default
systemctl enable readonly-root
systemctl enable systemd-firstboot
%end

%packages
readonly-root
%end
