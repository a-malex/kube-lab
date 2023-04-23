#!/bin/bash

echo ">>> CONFIGURE KUBECTL"

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown 900:900 /home/vagrant/.kube/config

sudo cp -i /etc/kubernetes/admin.conf /vagrant/kubeadm/admin.conf

echo ">>> FIX KUBELET NODE IP"

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_NODE_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl restart kubelet
