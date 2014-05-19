# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"

  config.vm.synced_folder "../scripts", "/usr/local/scripts"

  config.vm.define "master" do |master|
    master.vm.hostname = 'master'
    master.vm.network :private_network, ip: "192.168.33.10"
  end

  config.vm.define "agent" do |agent|
    agent.vm.hostname = 'agent'
    agent.vm.network :private_network, ip: "192.168.33.11"
  end

  # Fix DNS issue on Ubuntu
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

end
