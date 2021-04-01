%include arch/boot-EFI.ks
%include distro/RedPesk-core.ks
%include boards/generic/arm.ks
%include features/smack.ks
%include features/recovery.ks
%include features/reduce_size.ks

services --enabled=sshd,NetworkManager,chronyd

