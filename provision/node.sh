#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get -q update
apt-get install -y -q apt-transport-https curl ipvsadm tree # last two items are optional, install it for learning
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -q update
#apt-cache policy docker-ce
apt-get install -y -q docker-ce=18.06.1~ce~3-0~ubuntu kubelet kubeadm kubectl
apt-mark hold docker-ce kubelet kubeadm kubectl
apt-get -y -q upgrade

# Add the vagrant user to the docker group
usermod -aG docker vagrant

swapoff -a

#set up docker server proxy
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://10.88.20.11:8080"
Environment="HTTPS_PROXY=http://10.88.20.11:8080"
Environment="NO_PROXY=corp.isddesign.com,dev2.isddesign.com,127.0.0.1,.local,.mshome.net,.site,.dev,172.26.187.0/8,10.96.0.0/12,10.88.0.0/16,172.0.0.0/24"
EOF

#open docker server for remote api
cat > /etc/systemd/system/docker.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
EOF

systemctl daemon-reload
systemctl restart docker

_k8s_master=m1
#_swarm_master="m1"
#_swarm_managers="m1,m2,m3"

cd /vagrant
if [[ $(hostname -s) = $_k8s_master ]]; then
  echo "Let's init k8s cluster"
  kubeadm -v 4 init | tee kubeadm-init.log
  cat kubeadm-init.log | grep "kubeadm join" >k8s-join.sh
  if test -e k8s-join.sh && test -s k8s-join.sh; then  
    chmod a+x k8s-join.sh
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown vagrant:vagrant $HOME/.kube/config
    kubectl apply --filename https://git.io/weave-kube-1.6
  fi
else
  echo "It is not k8s master"
  if [[ ! -z "$_k8s_master" ]] && test -e k8s-join.sh && test -s k8s-join.sh; then
    echo "Let's join k8s cluster"
    ./k8s-join.sh
  else
    if [[ $(hostname -s) = $_swarm_master ]]; then
      echo "Let's init Swarm cluster"
      docker swarm init | tee swarm-init.log
      cat swarm-init.log | grep "join --token" >swarm-join.sh
      chmod a+x swarm-join.sh
      docker swarm join-token manager | grep "join --token" > swarm-manager-join.sh
      chmod a+x swarm-manager-join.sh
    else
      if [[ ! -z "$_swarm_master" ]]; then
        if [[ ",$_swarm_managers," = *,"$(hostname -s)",* ]] && test -e swarm-manager-join.sh && test -s swarm-manager-join.sh; then
          echo "Let's join Swarm cluster as a manager"
          ./swarm-manager-join.sh
        else
          if test -e swarm-join.sh && test -s swarm-join.sh; then
            echo "Let's join Swarm cluster as a worker"
            ./swarm-join.sh
          fi
        fi
      fi
    fi
  fi
fi