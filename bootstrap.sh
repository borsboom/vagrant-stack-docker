#!/usr/bin/env bash

set -xe

cd /tmp

apt-get update
apt-get upgrade -y

update-rc.d puppet disable
service puppet stop || true
update-rc.d chef-client disable
service chef-client stop || true
kill `cat /var/run/chef/client.pid` || true

if ! grep "127.0.0.1 $(hostname)" /etc/hosts; then
    echo "127.0.0.1 $(hostname)" >>/etc/hosts
fi

# Setup swap
if ! grep '^/dev/sdb\b' /etc/fstab; then
    mkswap -f /dev/sdb
    echo "/dev/sdb none swap sw 0 0" >>/etc/fstab
    swapon /dev/sdb
fi

# Setup /var/lib/docker filesystem
# quadruple the usual number of inodes, since overlay creates a lot of files
if ! grep '^/dev/sdc\b' /etc/fstab; then
    mkfs -F -t ext4 -i 4096 /dev/sdc
    echo "/dev/sdc /var/lib/docker ext4 defaults,nofail 0 2" >>/etc/fstab
    (which docker && service docker stop) || true
    rm -rf /var/lib/docker
    mkdir -p /var/lib/docker
    mount /var/lib/docker
    (which docker && service docker start) || true
fi

# Install Docker
if ! which docker; then
    wget -qO- https://get.docker.com/ | sh
    gpasswd -a vagrant docker
    service docker stop
    rm -rf /var/lib/docker/*
    echo 'DOCKER_OPTS="-s overlay -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"' >>/etc/default/docker
    # This is a workaround for docker not using /etc/default/docker on vivid
    # (from http://nknu.net/how-to-configure-docker-on-ubuntu-15-04/)
    mkdir -p /etc/systemd/system/docker.service.d
    cat >/etc/systemd/system/docker.service.d/ubuntu.conf <<'EOF'
[Service]
EnvironmentFile=/etc/default/docker
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
EOF
    systemctl daemon-reload
    service docker start
fi

# Install stack
if ! which stack; then
    wget -qO- https://s3.amazonaws.com/download.fpcomplete.com/ubuntu/fpco.key | sudo apt-key add -
    echo 'deb http://download.fpcomplete.com/ubuntu wily main'|sudo tee /etc/apt/sources.list.d/fpco.list
    apt-get update
    apt-get install -y stack
fi
