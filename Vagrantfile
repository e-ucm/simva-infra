# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 443, host: 8443, host_ip: "127.0.0.1"

  config.vm.network "private_network", ip: "192.168.253.2"

  config.vm.provider "virtualbox" do |vb|
     # Customize the amount of memory on the VM:
     vb.memory = "4096"
     vb.cpus = 2
  end

  config.vm.provision "shell" do |s|
      s.path= "vagrant/bootstrap-docker.sh"
  end
  config.vm.provision "shell" do |s|
      s.path= "vagrant/installation.sh"
  end
end
