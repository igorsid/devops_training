#
# Cookbook:: task9
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

yum_package 'pkg_java_1_8_0' do
  package_name 'java-1.8.0-openjdk'
  action :install
end

yum_package 'yum-utils'

bash 'rep_docker' do
  code <<-EOH
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    EOH
end

yum_package 'docker-ce' do
  flush_cache :before
  action :install
end

directory '/etc/docker' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/etc/docker/daemon.json' do
  content '{ "insecure-registries" : ["192.168.10.10:5000" ] }'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

service 'docker' do
  action [ :enable, :start ]
end

bash 'usermod_vagrant' do
  code <<-EOH
    usermod -aG docker vagrant
    EOH
end

bash 'registry_run' do
  code <<-EOH
    docker run -d -p 5000:5000 --name registry registry:2
  EOH
  only_if 'test -z $( docker container ls -a -q -f name=registry )'
end
bash 'registry_start' do
  code <<-EOH
    docker start registry
  EOH
  only_if 'test -z $( docker ps -q -f name=registry )'
end

