# -*- mode: ruby -*-
# vi: set ft=ruby :

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

  config.vm.define "apache" do |apache|

    apache.vm.box = "bento/centos-7.5"
    apache.vm.hostname = "apache.localdomain"
    apache.vm.network "private_network", ip: "192.168.10.11"
    apache.vm.network "forwarded_port", guest: 80, host: 8080

    apache.vm.provision "shell", inline: <<-SHELL

      yum -y install httpd
      cp -v /vagrant/mod_jk.so /etc/httpd/modules/
      cp -v /vagrant/mod_jk.conf /etc/httpd/conf.d/
      cp -v /vagrant/workers.properties /etc/httpd/conf/
      systemctl enable httpd
      systemctl start httpd

      cat /etc/hosts | grep tomcat1 || echo "192.168.10.21 tomcat1" >> /etc/hosts
      cat /etc/hosts | grep tomcat2 || echo "192.168.10.22 tomcat2" >> /etc/hosts

      #firewall-cmd --permanent --zone=public --add-port=80/tcp
      #firewall-cmd --reload

    SHELL

  end

  config.vm.define "tomcat1" do |tomcat1|

    tomcat1.vm.box = "bento/centos-7.5"
    tomcat1.vm.host_name = "tomcat1.localdomain"
    tomcat1.vm.network "private_network", ip: "192.168.10.21"
    #tomcat1.vm.network "forwarded_port", guest: 8080, host: 8081

    tomcat1.vm.provision "shell", inline: <<-SHELL

      yum -y install java-1.8.0-openjdk
      yum -y install tomcat tomcat-webapps tomcat-admin-webapps
      systemctl enable tomcat
      systemctl start tomcat

      mkdir /usr/share/tomcat/webapps/test
      echo "tomcat1" >/usr/share/tomcat/webapps/test/index.html

    SHELL

  end

  config.vm.define "tomcat2" do |tomcat2|

    tomcat2.vm.box = "bento/centos-7.5"
    tomcat2.vm.host_name = "tomcat2.localdomain"
    tomcat2.vm.network "private_network", ip: "192.168.10.22"
    #tomcat2.vm.network "forwarded_port", guest: 8080, host: 8082

    tomcat2.vm.provision "shell", inline: <<-SHELL

      yum -y install java-1.8.0-openjdk
      yum -y install tomcat tomcat-webapps tomcat-admin-webapps
      systemctl enable tomcat
      systemctl start tomcat

      mkdir /usr/share/tomcat/webapps/test
      echo "tomcat2" >/usr/share/tomcat/webapps/test/index.html

    SHELL

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
