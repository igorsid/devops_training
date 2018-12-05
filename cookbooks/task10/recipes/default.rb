#
# Cookbook:: task10
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

if node.attribute?( 'version' )
  puts "version: #{node['version']}"
else
  puts 'version is unknown'
end

begin
  host = node['service_host']
  port1 = node['service_port1']
  port2 = node['service_port2']

  p_lst = {}
  [ port1, port2 ].each do |p|
    begin
      Timeout.timeout(4) do
        Socket.tcp( host, p ){}
      end
      p_lst[p] = true
      puts "port #{p} is listening"
    rescue 
      p_lst[p] = false
      puts "port #{p} is free"
    end
  end

  p_start = !p_lst[port1] ? port1 : !p_lst[port2] ? port2 : 0
  p_stop = p_lst[port1] ? port1 : p_lst[port2] ? port2 : 0
  if p_start != 0
    puts "Will be start service on #{p_start}"
    if p_stop != 0
      puts "Will be stop service on #{p_stop}"
    end
  else
    puts "Error define service ports"
  end

  node.override['port_start'] = p_start if p_start != 0
  node.override['port_stop'] = p_stop if p_stop != 0
end

execute 'service_start' do
  command "docker run -d -p #{node['port_start']}:8080 --name #{node['service_name']}_#{node['port_start']} #{node['registry_ip']}:5000/#{node['service_name']}:#{node['version']}"
  only_if { node.attribute?('port_start') }
end

execute 'service_stop' do
  command "docker stop #{node['service_name']}_#{node['port_stop']} && docker rm #{node['service_name']}_#{node['port_stop']}"
  only_if { node.attribute?('port_stop') }
end
