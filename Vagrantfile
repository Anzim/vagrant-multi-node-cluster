# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    if Vagrant.has_plugin?("vagrant-proxyconf")
#      config.proxy.http     = "your.proxy.corp:8080"
#      config.proxy.https    = "your.proxy.corp:8080"
#      config.proxy.no_proxy = "*.yourcorp.com,127.0.0.1,*.local,*.dev"
    end

    config.vm.box = "bento/ubuntu-16.04"
    config.vm.provision "shell", path: "provision/node.sh", privileged: true
    config.vm.network "public_network", bridge: "Default Switch"

    # Managers
    (1..3).each do |number|
        config.vm.define "m#{number}" do |node|
            node.vm.network "private_network", ip: "192.168.99.20#{number}"
            node.vm.hostname = "m#{number}"
        end  
    end

    # Workers
    (1..4).each do |number|
        config.vm.define "w#{number}" do |node|
            node.vm.network "private_network"
            node.vm.hostname = "w#{number}"
        end  
    end

    config.vm.provider "hyperv" do |v|
        v.memory = 2048 
        v.cpus = 2
    end

end
 