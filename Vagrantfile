# The main variables config to setup the cluster are defined here. you can change them to whatever you want to have in your cluster
domain = "kube.lab"  # main domain name
control_plane_endpoint = "172.16.16.100:6443" # This IP is defined as a virtual IP in Keepalived 
pod_network_cidr = "10.244.0.0/16"
pod_network_type = "calico" # choose between calico and flannel
version = "1.27.0-00"   # choose your kubernete version here. 1.26 or 1.27 or ...
LoadBalancerCount = 2  # choose number of VMs for LoadBalancer (HAProxy-Keepalived)
MasterCount = 3   # choose number of VMs for control-plains of your cluster
WorkerCount = 2   # choose number of VMs for workers of your cluster

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    (1..LoadBalancerCount).each do |i|
      config.vm.define "#{domain}.loadbalancer#{i}" do |loadbalancer|
        loadbalancer.vm.provision :shell, path: "kubeadm/bootstrap_ha.sh"
        loadbalancer.vm.box  = "ubuntu/focal64"
        loadbalancer.vm.provider "virtualbox" do |v|
          v.name   = "#{domain}.loadbalancer#{i}"
          v.memory = "1024"
          v.cpus   = "1"
          v.customize ["modifyvm", :id, "--nic1", "nat"]
######### To use ubuntu-22.04LTS as your vm os you can use below configs instead of above configs in all sections but be aware that this alocate more resources  
        # loadbalancer.vm.box               = "generic/ubuntu2204"
        # loadbalancer.vm.box_check_update  = false
        # loadbalancer.vm.box_version       = "4.2.8"
        # loadbalancer.vm.provider :virtualbox do |v|
        #   v.name   = "#{domain}.loadbalancer#{i}"
        #   v.memory = "1024"
        #   v.cpus   = "1"
        loadbalancer.vm.hostname = "#{domain}.loadbalancer#{i}"
        loadbalancer.vm.network "private_network", ip: "172.16.16.5#{i}"
        end
        # setup cluster ip and addresses in hosts
        loadbalancer.vm.provision "shell", env: {"DOMAIN" => "#{domain}.loadbalancer#{i}", "LOAD_BALANCER_IP" => "172.16.16.5#{i}"} ,inline: <<-SHELL 
        echo "$LOAD_BALANCER_IP $DOMAIN" >> /etc/hosts 
        SHELL
        (1..3).each do |masterNodeIndex|
          loadbalancer.vm.provision "shell", env: {"DOMAIN" => "#{domain}.master#{i}", "MASTER_IP" => "172.16.16.10#{i}"} ,inline: <<-SHELL 
          echo "$MASTER_IP $DOMAIN" >> /etc/hosts 
          SHELL
        end
        
      end
    end


    domain_master = "#{domain}.master1"
    main_master_node_ip = "172.16.16.101"
    config.vm.define "#{domain}.master1" do |m_master|
      m_master.vm.provision :shell, path: "kubeadm/bootstrap.sh", env: { "VERSION" => version }
      m_master.vm.box = "ubuntu/focal64" 
      m_master.vm.hostname = "#{domain_master}"
      m_master.vm.network "private_network", ip: "172.16.16.101"
      # setup cluster ip and addresses in hosts
      (1..MasterCount).each do |j|
        m_master.vm.provision "shell", env: {"DOMAIN" => "#{domain}.master#{j}", "MASTER_NODE_IP" => "172.16.16.10#{j}"} ,inline: <<-SHELL 
        echo "$MASTER_NODE_IP  $DOMAIN" >> /etc/hosts 
        SHELL
      end
      (1..2).each do |nodeIndex|
        m_master.vm.provision "shell", env: {"DOMAIN" => "#{domain}.worker#{nodeIndex}", "NODE_INDEX" => nodeIndex}, inline: <<-SHELL 
        echo "172.16.16.20$NODE_INDEX $DOMAIN" >> /etc/hosts 
        SHELL
      end
      m_master.vm.provision "shell", path:"kubeadm/init-master.sh", env: {"K8S_CONTROL_PLANE_ENDPOINT" => control_plane_endpoint, "K8S_POD_NETWORK_CIDR" => pod_network_cidr, "K8S_POD_NETWORK_TYPE" => pod_network_type, "MASTER_NODE_IP" => main_master_node_ip, "NODE_NAME" => "#{domain}.master1"}
      m_master.vm.provider "virtualbox" do |vb|
        vb.name   = "#{domain}.master1"
        vb.memory = "3072"
        vb.cpus = "1"
        vb.customize ["modifyvm", :id, "--nic1", "nat"]
      end
    end


    (2..MasterCount).each do |i|
      domain_master = "#{domain}.master#{i}"
      master_node_ip = "172.16.16.10#{i}"
      config.vm.define "#{domain}.master#{i}" do |master|
        master.vm.provision :shell, path: "kubeadm/bootstrap.sh", env: { "VERSION" => version }
        master.vm.box = "ubuntu/focal64"
        master.vm.hostname = "#{domain_master}"
        master.vm.network "private_network", ip: "172.16.16.10#{i}"
        # setup cluster ip and addresses in hosts
        (1..MasterCount).each do |j|
          master.vm.provision "shell", env: {"DOMAIN" => "#{domain}.master#{j}", "MASTER_NODE_IP" => "172.16.16.10#{j}"} ,inline: <<-SHELL 
          echo "$MASTER_NODE_IP $DOMAIN" >> /etc/hosts 
          SHELL
        end
        (1..2).each do |nodeIndex|
          master.vm.provision "shell", env: {"DOMAIN" => "#{domain}.worker#{nodeIndex}", "NODE_INDEX" => nodeIndex}, inline: <<-SHELL 
          echo "172.16.16.20$NODE_INDEX $DOMAIN" >> /etc/hosts 
          SHELL
        end
        master.vm.provision "shell", path: "kubeadm/join-other-master-command.sh", env: {"MASTER_NODE_IP" => master_node_ip, "NODE_NAME" => "#{domain}.master#{i}"}
        master.vm.provision "shell", path: "kubeadm/join-other-masters.sh"
        master.vm.provision "shell", path:"kubeadm/init-other-masters.sh", env: {"K8S_POD_NETWORK_TYPE" => pod_network_type, "MASTER_NODE_IP" => master_node_ip}
        master.vm.provider "virtualbox" do |vb|
          vb.name   = "#{domain}.master#{i}"
          vb.memory = "3072"
          vb.cpus = "1"
          vb.customize ["modifyvm", :id, "--nic1", "nat"]
        end
      end
    end


    (1..WorkerCount).each do |i|
      domain_worker = "#{domain}.worker#{i}"
      config.vm.define "#{domain}.worker#{i}" do |worker|
        worker.vm.provision :shell, path: "kubeadm/bootstrap.sh", env: { "VERSION" => version }
        worker.vm.box  = "ubuntu/focal64"
        worker.vm.hostname = "#{domain_worker}"
        worker.vm.network "private_network", ip: "172.16.16.20#{i}"
        # setup cluster ip and addresses in hosts
        (1..3).each do |nodeIndex|
          master_node_ip = "172.16.16.10#{i}"
          worker.vm.provision "shell", env: {"DOMAIN" => "#{domain}.master#{nodeIndex}", "MASTER_NODE_IP" => master_node_ip} ,inline: <<-SHELL 
          echo "$MASTER_NODE_IP $DOMAIN" >> /etc/hosts 
          SHELL
        end
        (1..2).each do |hostIndex|
            worker.vm.provision "shell", env: {"DOMAIN" => domain_worker, "NODE_INDEX" => hostIndex}, inline: <<-SHELL 
            echo "172.16.16.20$NODE_INDEX $DOMAIN" >> /etc/hosts 
            SHELL
        end
        worker.vm.provision "shell", env: {"NODE_NAME" => "#{domain}.worker#{i}" }, inline: <<-SHELL
        sed -i "s/ --node-name=.*/ --node-name=$NODE_NAME --v=5/" /vagrant/kubeadm/init-worker.sh;
        SHELL
        worker.vm.provision "shell", path:"kubeadm/init-worker.sh"
        worker.vm.provision "shell", env: { "NODE_INDEX" => i}, inline: <<-SHELL 
            echo ">>> FIX KUBELET NODE IP"
            echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=172.16.16.20$NODE_INDEX\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
            sudo systemctl daemon-reload
            sudo systemctl restart kubelet
            SHELL
        worker.vm.provider "virtualbox" do |vb|
          vb.name   = "#{domain}.worker#{i}"
          vb.memory = "3072"
          vb.cpus = "1"
          vb.customize ["modifyvm", :id, "--nic1", "nat"]
        end
      end
    end
    
  end
