#!/usr/bin/env bash
set -euo pipefail

COLOUR=$1

apt-get update
apt-get -qq install -y zfsutils-linux avahi-daemon

# If the disk port is changed in the Vagrantfile, this path will change too.
zpool create -O compression=lz4 -f $COLOUR /dev/disk/by-path/pci-0000:00:14.0-scsi-0:0:2:0

# Share the unique private keys between each machine.
echo 'eval $(ssh-agent)' >> ~/.bashrc
echo 'ssh-add /vagrant/.vagrant/machines/green/virtualbox/private_key' >> ~/.bashrc
echo 'ssh-add /vagrant/.vagrant/machines/blue/virtualbox/private_key' >> ~/.bashrc

eval $(ssh-agent)
ssh-add /vagrant/.vagrant/machines/blue/virtualbox/private_key

# On both colours, create datasets.
# We don't bother to replicate the code dataset as we assume it comes from
# version control.
zfs create $COLOUR/code

zfs create $COLOUR/db
zfs create $COLOUR/files
zfs snapshot $COLOUR/db@base
zfs snapshot $COLOUR/files@base

#if [ $COLOUR == "green" ]
#then
  #zfs send $COLOUR/db@base | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@blue.local sudo zfs receive blue/db@base
  #zfs send $COLOUR/files@base | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@blue.local sudo zfs receive blue/files@base
#fi

# Set up mariadb to store in the ZFS volume. Another method would be to set the
# zfs mountpoint option with `zfs set ...`.
ln -s $COLOUR/db /var/lib/mysql

# Install the basic Drupal dependencies. It wouldn't be much more to do this
# with Docker, but that's beyond the scope of proving out blue / green deployments.
apt-get -qq install -y php libapache2-mod-php php-mysql php-gd php-bcmath mariadb-server mariadb-client
