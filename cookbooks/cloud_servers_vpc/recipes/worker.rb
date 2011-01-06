#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: default
#
# Copyright 2010, Rackspace
#

include_recipe "#{@cookbook_name}::base"

package "monit"

service "monit" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

node[:cloud_servers_vpc][:resque_workers].to_i.times do |worker_id|
  template "/etc/monit.d/cloud_servers_vpc_#{worker_id}.monit" do
    mode "0644"
    source "cloud_servers_vpc.monit.erb"
    variables (:worker_id => worker_id, :queue => 'linux')
    notifies :restart, resources("service[monit]")
  end
end

bash "stop_workers" do
  action :nothing
  cwd "/tmp"
  user "root"
  code <<-EOH
      #{node[:cloud_servers_vpc][:home]}/script/stop_workers || /bin/true
  EOH
  notifies :restart, resources("service[monit]")
  subscribes :run, resources("bash[download_and_extract]", "template[#{node[:cloud_servers_vpc][:home]}/config/environments/production.rb]")
end
