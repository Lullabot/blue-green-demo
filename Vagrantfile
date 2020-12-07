# -*- mode: ruby -*-
# vi: set ft=ruby :

dir = File.dirname(File.expand_path(__FILE__))
zfs_dir = "#{dir}/.vagrant"

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/focal64"
  config.vm.network "private_network", type: "dhcp"

  config.vm.define "blue" do |blue|
    blue.vm.hostname = "blue"
    blue.vm.provision "shell", path: "provision.sh", args: ["blue"]

    # We need a static IP address as Docker doesn't easily support mDNS.
    #blue.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"

    # Create a disk for zfs / docker container images.
    blue.vm.provider "virtualbox" do |vb|
      zfs = File.join(zfs_dir, 'zfs-blue.vdi')
      unless File.exists?(zfs)
        vb.customize ["createhd", "--filename", zfs, "--size", 10 * 1024]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--medium", zfs]
    end

    blue.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 8
      vb.linked_clone = true
    end

    # Install PHP, Apache, MariaDB, and a pre-existing Drupal database.
    # drupal.vm.provision "shell", path: "install-drupal.sh"
    #
  end

  config.vm.define "green" do |green|
    green.vm.hostname = "green"
    green.vm.provision "shell", path: "provision.sh", args: ["green"]

    # We need a static IP address as Docker doesn't easily support mDNS.
    #green.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"

    # Create a disk for zfs / docker container images.
    green.vm.provider "virtualbox" do |vb|
      zfs = File.join(zfs_dir, 'zfs-green.vdi')
      unless File.exists?(zfs)
        vb.customize ["createhd", "--filename", zfs, "--size", 10 * 1024]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--medium", zfs]
    end

    green.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 8
      vb.linked_clone = true
    end

    # Install PHP, Apache, MariaDB, and a pre-existing Drupal database.
    # green.vm.provision "shell", path: "install-green.sh"
    #
  end

end
