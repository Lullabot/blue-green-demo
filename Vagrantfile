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
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 8
    vb.linked_clone = true
  end

  config.vm.provision "shell", path: "provision.sh", run: "always"

  config.vm.define "blue" do |blue|
    blue.vm.hostname = "blue"

    # Create a disk for zfs.
    blue.vm.provider "virtualbox" do |vb|
      zfs = File.join(zfs_dir, 'zfs-blue.vdi')
      unless File.exists?(zfs)
        vb.customize ["createhd", "--filename", zfs, "--size", 10 * 1024]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--medium", zfs]
    end
  end

  config.vm.define "green" do |green|
    green.vm.hostname = "green"

    # Create a disk for zfs.
    green.vm.provider "virtualbox" do |vb|
      zfs = File.join(zfs_dir, 'zfs-green.vdi')
      unless File.exists?(zfs)
        vb.customize ["createhd", "--filename", zfs, "--size", 10 * 1024]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--medium", zfs]
    end
  end

end
