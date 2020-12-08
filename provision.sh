#!/usr/bin/env -S bash
set -euo pipefail

SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
COLOUR=$(hostname)

if [ $COLOUR == "blue" ]
then
  OTHER="green"
else
  OTHER="blue"
fi

if [ ! -f ~/zfs-provisioned ]
then
  apt-get update
  apt-get -qq install -y \
    zfsutils-linux

  # If the disk port is changed in the Vagrantfile, this path will change too.
  zpool create -O compression=lz4 -f $COLOUR /dev/disk/by-path/pci-0000:00:14.0-scsi-0:0:2:0

  # On both colours, create datasets.
  # We don't bother to replicate the code dataset as we assume it comes from
  # version control.
  zfs create $COLOUR/code
  zfs set mountpoint=/var/www $COLOUR/code

  # Install the basic Drupal dependencies. It wouldn't be much more to do this
  # with Docker, but that's beyond the scope of proving out blue / green deployments.
  apt-get -qq install -y php libapache2-mod-php php-mysql php-gd php-bcmath php-xml

  # Copy over the site code.
  cp -a /vagrant/site /var/www/site

  # Set up the Drupal files directory. We change permissions after Drupal is
  # installed.
  ln -sv /var/www/files/public /var/www/site/web/sites/default/files

  # Update the document root for the site we just copied over.
cat << EOF > /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/site/web
        <Directory "/var/www/site/web">
                AllowOverride All
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

  a2enmod rewrite
  systemctl restart apache2
  touch ~/zfs-provisioned
fi

if [ ! -f ~/provisioned ]
then
  apt-get -qq install -y \
    avahi-daemon \

  ! ping -c 1 $OTHER.local &> /dev/null && echo "$OTHER is not ready yet. Run vagrant provision again." && exit

  # Share the unique private keys between each machine.
  echo 'eval $(ssh-agent)' >> ~/.bashrc
  echo "ssh-add /vagrant/.vagrant/machines/$COLOUR/virtualbox/private_key" >> ~/.bashrc
  echo "ssh-add /vagrant/.vagrant/machines/$OTHER/virtualbox/private_key" >> ~/.bashrc

  eval $(ssh-agent)
  ssh-add /vagrant/.vagrant/machines/$OTHER/virtualbox/private_key

  if [ $COLOUR == "blue" ]
  then
    zfs create $COLOUR/db
    zfs create $COLOUR/files
    zfs snapshot $COLOUR/db@base
    zfs snapshot $COLOUR/files@base
    # Set up code/files/db to store in the ZFS volume.
    zfs set mountpoint=/var/www/files $COLOUR/files
    zfs set mountpoint=/var/lib/mysql $COLOUR/db

    mkdir -p /var/www/files/public

    apt-get -qq install -y mariadb-server mariadb-client

    pushd /var/www/site
    echo "CREATE USER drupal@localhost IDENTIFIED BY 'drupal'" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO 'drupal'@localhost" | mysql -u root
    vendor/bin/drush site:install -y demo_umami
    vendor/bin/drush en -y environment_indicator
    vendor/bin/drush role:perm:add anonymous 'access environment indicator'
    vendor/bin/drush role:perm:add anonymous 'access toolbar'
    chown -Rv www-data:www-data /var/www/files
    popd

    zfs send $COLOUR/db@base | $SSH vagrant@$OTHER.local sudo zfs receive -o mountpoint=/var/lib/mysql $OTHER/db@base
    zfs send $COLOUR/files@base | $SSH vagrant@$OTHER.local sudo zfs receive -o mountpoint=/var/www/files $OTHER/files@base

    # Now that we've replicated we can install mariadb on green
    $SSH vagrant@$OTHER.local sudo /vagrant/provision-green.sh
  fi

  touch ~/provisioned
fi
