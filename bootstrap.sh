#!/bin/bash -xe
cd /tmp

echo "127.0.0.1 $(hostname)" >>/etc/hosts

# Install Docker
wget -qO- https://get.docker.com/ | sh
gpasswd -a vagrant docker
service docker stop
rm -rf /var/lib/docker
echo "DOCKER_OPTS=\"-s overlay -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\"" >>/etc/default/docker

# Install kernel that supports overlay storage driver
wget -q http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-headers-3.18.0-031800-generic_3.18.0-031800.201412071935_amd64.deb
wget -q http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-headers-3.18.0-031800_3.18.0-031800.201412071935_all.deb
wget -q http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-image-3.18.0-031800-generic_3.18.0-031800.201412071935_amd64.deb
dpkg -i linux-headers-3.18.0-*.deb linux-image-3.18.0-*.deb
rm linux-headers-3.18.0-*.deb linux-image-3.18.0-*.deb
update-grub

# Setup swap
mkswap -f /dev/sdb
echo "/dev/sdb none swap sw 0 0" >>/etc/fstab

# Setup /var/lib/docker filesystem
# quadruple the usual number of inodes, since overlay creates a lot of files
mkfs -F -t ext4 -N 52428800 /dev/sdc
echo "/dev/sdc /var/lib/docker ext4 defaults,nofail 0 2" >>/etc/fstab

# Adjust UID/GID of 'vagrant' user.  Need to do this way since NFS synced folders don't support owner/group attributes.
#CHANGEME: Adjust the VAGRANT_UID and VAGRANT_GID to match your user's values on your host OS (find those using `id -u` and `id -g`).
VAGRANT_UID=501
VAGRANT_GID=20
#TODO: This might not be necessary if we disable fpbuild's UID/GID mapping for remote DOCKER_HOST.
perl -i.bak -pe "s/^(vagrant:[^:]*):[^:]*:[^:]*:/\1:${VAGRANT_UID}:${VAGRANT_GID}:/" /etc/passwd
find /home/vagrant -print0|xargs -0 chown ${VAGRANT_UID}:${VAGRANT_GID}
set +x
echo '================================================'
echo '        NOW YOU MUST RUN: vagrant reload        '
echo '================================================'
