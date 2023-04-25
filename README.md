# Kube-lab (multi-master/worker kubernetes (v1.27) cluster with vagrant and kubeadm)
*version 1.0.0*

This project provides a profesional multi-master kubernetes cluster by kubeadm that stabled with 2 HAproxys and keepalived in your local machine using vagrant and bash script.
I have got some inspiration from these two repos ([akyriako](https://github.com/akyriako/kubernetes-vagrant-ubuntu) and [justmeandopensource](https://github.com/justmeandopensource/kubernetes/tree/master/kubeadm-ha-keepalived-haproxy/external-keepalived-haproxy)) and learned a lot from them.

![Github license](https://img.shields.io/badge/License-Apache_V_2.0-green)
![LinkedIn](https://shields.io/badge/style-ahmadmalekiha-black?logo=linkedin&label=LinkedIn&link=https://www.linkedin.com/in/ahmad-malekiha/)

---

## Intro
This documentation describes what will be setting up on your machine and how to modify the number of VMs and etc...


## Vagrant Environment
|Role|NAME|IP|OS|RAM|CPU|
|----|----|----|----|----|----|
|Load Balancer|kube.lab.loadbalancer1|172.16.16.51|Ubuntu 20.04|1G|1|
|Load Balancer|kube.lab.loadbalancer2|172.16.16.52|Ubuntu 20.04|1G|1|
|Master|kube.lab.master1|172.16.16.101|Ubuntu 20.04|3G|1|
|Master|kube.lab.master2|172.16.16.102|Ubuntu 20.04|3G|1|
|Master|kube.lab.master3|172.16.16.103|Ubuntu 20.04|3G|1|
|Worker|kube.lab.worker1|172.16.16.201|Ubuntu 20.04|3G|1|
|Worker|kube.lab.worker2|172.16.16.201|Ubuntu 20.04|3G|1|


*If these configs are not suitable, you can reduce the value of ram and the number of VMs in vagrant file*

### Virtual IP managed by Keepalived on the load balancer nodes
|Virtual IP|
|----|
|172.16.16.100|

 ---
 ## Requirements:
 You need [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/) installed on your machine.
 
 *I had VirtualBox 7.0.8 and Vagrant 2.3.4 on my Ubuntu 22.04 LTS*
 
 ## How to use:
 If above setup is OK , to setup the cluster you just need to follow these steps:
 - Clone this repository:
    ```
    git clone https://github.com/a-malex/kube-lab.git
    ```
 - Go to the project directory
    ```
    cd kube-lab
    ```
 - Run vagrant command
    ```
    vagrant up
    ```
   If you run this command for the first time, it sets up the cluster from zero (download ubuntu image and setup os and install kubernetes components and ...), Therefore, it may take up to half an hour or more.

 - Set kubeconfig for your local machine to connect to the cluster:
    ```
    cp kubeadm/admin.conf ~/.kube/conf
    ```
 - Check your cluster
    ```
    kubectl get nodes
    ```
    
## How to set your own values for the kube-lab cluster:
You can use below environ variables to set up your kube-lab cluster:
|ENVIRONEMT_VARIABLE|DEFAULT_VALUE|DESCRIPTION|
|----|----|----|
|KUBE_LAB_LBCOUNT| 2 |Number of LoadBalancer VM|
|KUBE_LAB_MCOUNT| 3 |Number of Master Nodes|
|KUBE_LAB_WCOUNT| 2 |Number of Worker Nodes|
|KUBE_LAB_LB_RAM| 512 |Loadbalancers RAM|
|KUBE_LAB_M_RAM| 2048 |Master Nodes RAM|
|KUBE_LAB_W_RAM| 2048 |Worker Nodes RAM|
|KUBE_LAB_LB_CPU| 1 |Loadbalancers CPU|
|KUBE_LAB_M_CPU| 2 |Master Nodes CPU|
|KUBE_LAB_W_CPU| 1 |Worker Nodes CPU|

You can set yout own values by exporting them at first for example ``` export KUBE_LAB_WCOUNT=1 ``` and then run ``` vagrant up ``` command.


# How to contribute?
You can fork and develop your idea.

*Copyright 2023 a-malex <ahmadmalekiha@gmail.com>*
