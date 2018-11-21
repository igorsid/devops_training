# -*- mode: ruby -*-
# vi: set ft=ruby :

WORKER_COUNT = 2

ip_jenkins = "192.168.10.10"
ip_worker = Array.new(WORKER_COUNT) { |i| "192.168.10.#{21+i}" }

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "bento/centos-7.5"

  config.vm.define "jenkins" do |jenkins|

    jenkins.vm.box = "bento/centos-7.5"
    jenkins.vm.provider "virtualbox" do |vb|
      vb.cpus = 2         # vb.customize [ "modifyvm", :id, "--cpus", "2" ]
      vb.memory = 3072    # vb.customize [ "modifyvm", :id, "--memory", "2048" ]
    end
    jenkins.vm.hostname = "jenkins.localdomain"
    jenkins.vm.network "private_network", ip: "#{ip_jenkins}"
    jenkins.vm.network "forwarded_port", guest: 8000, host: 8000    # jenkins (--httpPort=8000)
    jenkins.vm.network "forwarded_port", guest: 8080, host: 8080    # tomcat container (8080:8080)
    jenkins.vm.network "forwarded_port", guest: 8081, host: 8081    # nexus (default 8081)
    jenkins.vm.network "forwarded_port", guest: 3000, host: 3000    # grafana
    jenkins.vm.network "forwarded_port", guest: 5601, host: 5601    # kibana

    jenkins.vm.provision "shell", inline: <<-SHELL

      yum -y install java-1.8.0-openjdk
      yum -y install java-1.8.0-openjdk-devel
      yum -y install git

      yum -y install yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      yum -y install docker-ce
      mkdir /etc/docker
      echo '{ "insecure-registries" : ["#{ip_jenkins}:5000" ] }' >/etc/docker/daemon.json
      systemctl enable docker
      systemctl start docker
      usermod -aG docker vagrant

      cd /usr/local
      tar xzvf /vagrant/nexus-2.14.9-01-bundle.tar.gz
      ln -s nexus-2.14.9-01 nexus
      chown -R root.root sonatype-work nexus-2.14.9-01
      cd /usr/local/nexus
      export RUN_AS_USER=root
      ./bin/nexus start



    SHELL

    jenkins.vm.provision "shell", inline: <<-SHELL
      cat /etc/hosts | grep jenkins || echo "#{ip_jenkins} jenkins" >> /etc/hosts
    SHELL
    (1..WORKER_COUNT).each do |i|
      jenkins.vm.provision "shell", inline: <<-SHELL
        cat /etc/hosts | grep "worker#{i}" || echo "#{ip_worker[i-1]} worker#{i}" >> /etc/hosts
      SHELL
    end

  end

  (1..WORKER_COUNT).each do |i|
    config.vm.define "worker#{i}" do |worker|

      worker.vm.box = "bento/centos-7.5"
      worker.vm.host_name = "worker#{i}.localdomain"
      worker.vm.network "private_network", ip: "#{ip_worker[i-1]}"

      worker.vm.provision "shell", inline: <<-SHELL

        yum -y install java-1.8.0-openjdk

        yum -y install yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum -y install docker-ce
        mkdir /etc/docker
        echo '{ "insecure-registries" : ["#{ip_jenkins}:5000" ] }' >/etc/docker/daemon.json
        systemctl enable docker
        systemctl start docker
        usermod -aG docker vagrant

        cat /etc/hosts | grep jenkins || echo "#{ip_jenkins} jenkins" >> /etc/hosts

      SHELL

    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

end
