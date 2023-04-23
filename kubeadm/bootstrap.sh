#!/bin/bash

echo ">>>>>>>>>>>> BOOTSTRAP <<<<<<<<<<<<<<<<"

# Enable ssh password authentication
echo "[TASK 1] >>> Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] >>> Set root password"
echo -e "kubelab\nkubelab" | passwd root >/dev/null 2>&1

echo "[TASK 3] >>> SYSTEM UPDATE & UPGRADE"

sudo apt update
sudo apt -y upgrade

echo "[TASK 4] >>> ADD KUBERNETES REPOS"

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d

sudo apt update

echo "[TASK 5] >>> INSTALL KUBE-* TOOLS"

sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

echo "[TASK 6] >>> KERNEL MODULES"

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo "[TASK 7] >>> INSTALL CRI"
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt remove containerd 
sudo apt update
sudo apt install containerd.io -y
sudo rm /etc/containerd/config.toml

systemctl restart containerd


echo "[TASK 8] >>> DISABLE SWAP"

sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo swapoff -a