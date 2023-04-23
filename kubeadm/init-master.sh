#!/bin/bash

echo ">>>>>>>>>>>> INIT MASTER <<<<<<<<<<<<<<<<"

echo "[TASK 1] >>> INIT MASTER NODE"

sudo systemctl enable kubelet

sudo sed ':a;N;$!ba;s/\n/,/g'  /vagrant/kubeadm/IPs.txt

# CLUSTER_IPS=$(sudo sed ':a;N;$!ba;s/\n/,/g'  /vagrant/kubeadm/IPs.txt)

kubeadm init \
  --control-plane-endpoint="172.16.16.100:6443" \
  --upload-certs \
  --apiserver-advertise-address=$MASTER_NODE_IP \
  --pod-network-cidr=$K8S_POD_NETWORK_CIDR \
  --ignore-preflight-errors=NumCPU \
  --node-name=$NODE_NAME \
  --v=5
  # --apiserver-cert-extra-sans=$CLUSTER_IPS \

echo "[TASK 2] >>> CONFIGURE KUBECTL"

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown 900:900 /home/vagrant/.kube/config

sudo cp -i /etc/kubernetes/admin.conf /vagrant/kubeadm/admin.conf

echo "[TASK 3] >>> FIX KUBELET NODE IP"

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_NODE_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

if [ "$MASTER_NODE_IP" == "172.16.16.101" ] 
  then
  if [ "$K8S_POD_NETWORK_TYPE" == "calico" ]
  then 
    echo ">>> DEPLOY POD NETWORK > CALICO"
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
    envsubst < /vagrant/cni/calico/operator/custom-resources.yaml | kubectl apply -f -
  else
    echo ">>> DEPLOY POD NETWORK > FLANNEL"
    envsubst < /vagrant/cni/flannel/flannel.yml | kubectl apply -f -
  fi
fi

sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo "[TASK 4] >>> GET MASTER JOIN COMMAND "

rm -f /vagrant/kubeadm/join-other-masters.sh

# Get certificate key from output of `kubeadm init phase upload-certs --upload-cert`
CERT_KEY=$(kubeadm init phase upload-certs --upload-certs | grep -A2 "Using certificate key:" | tail -n1)

# Create token and print join command
kubeadm token create --print-join-command --certificate-key "${CERT_KEY}" >> /vagrant/kubeadm/join-other-masters.sh
sed -i "s/$/ --ignore-preflight-errors=NumCPU --control-plane --apiserver-advertise-address=/" /vagrant/kubeadm/join-other-masters.sh
chmod +x /vagrant/kubeadm/join-other-masters.sh

echo "[TASK 5] >>> GET WORKER JOIN COMMAND "

rm -f /vagrant/kubeadm/init-worker.sh
kubeadm token create --print-join-command >> /vagrant/kubeadm/init-worker.sh
sed -i "s/$/ --node-name=/" /vagrant/kubeadm/init-worker.sh
