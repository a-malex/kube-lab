#!/bin/bash
echo ">>>>>>> setup join-other-master.sh command <<<<<<<<<";
sed -i "s/--apiserver-advertise-address=.*/--apiserver-advertise-address=$MASTER_NODE_IP  --node-name=$NODE_NAME --v=5/" /vagrant/kubeadm/join-other-masters.sh;