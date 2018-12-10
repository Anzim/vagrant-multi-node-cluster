Vagrant Multi Node Cluster

#Technology
Windows 10 + HyperV, Docker / Kubernetes or Swarm

#Summary
This repository will cover how to create a multi-node Swarm or Kubernetes Cluster on local Windows 10 machine using Vagrant Linux VMs (possibly under a corporate proxy).

#Usefulness
The process would allow creating multi-node Swarm or Kubernetes Cluster on multiple VMs to be deployed quickly for testing in a local cluster. There are many ways that we can go about creating VMs, which can be used to create multi-node Docker Swarm or Kubernetes cluster on a single machine for debugging and testing purposes. But if we have the machine running Windows 10 with docker for windows installed we are stuck with HyperV enabled and other virtualization tools like VirtualBox and VMware won't work in this case.
The only working approach I found to quickly spin up VMs that have the Docker engine running on them is to use Vagrant. 
It allows quicky adding and bringing down nodes to test and monitor different cluster behaviours with one command like "vagrant up manager2 worker3 worker4", run a shell script on all or several nodes simultaneously and even automate the process.

#Installation
Clone git repository by running with command if you have git installed:
git clone https://github.com/Anzim/vagrant-multi-node-cluster

If you have choco installed use this command to install vagrant
choco install vagrant
If not, download it using this link https://www.vagrantup.com/downloads.html and install it manually

If you need to set up proxy, replace your.proxy.corp with you proxy, put propper ignore list to NO_PROXY environment variable and install vagrant-proxyconf plugin using these commands:
set HTTP_PROXY=your.proxy.corp:8080
set HTTPS_PROXY=your.proxy.corp:8080
set NO_PROXY=*.yourcorp.com,127.0.0.1,*.local,*.dev
vagrant plugin install vagrant-proxyconf
Also update proxy values in Vagrantfile

Install vagrant box:
vagrant box add bento/ubuntu-16.04 --provider hyperv

In provision/node.sh file update _k8s_master environment variable if you want to create k8s cluster, but if you want to create Swarm cluster remove / comment it and update _swarm_master and _swarm_managers like this
#_k8s_master="m1"
#_swarm_master="m1"
#_swarm_managers="m1,m2,m3"

Run this command to create your seven node cluster (Update Vagrantfile if you need different number of nodes)
vagrant up m1 m2 m3 w1 w2 w3 w4 --provider hyperv

See status of your VMs by this command
vagrant status
