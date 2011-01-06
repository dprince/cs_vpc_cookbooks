#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: cron
#
# Copyright 2010, Rackspace
#

include_recipe "#{@cookbook_name}::base"

execute "touch_cron_d" do
  command "touch /etc/cron.d"
  action :nothing
end

template "/etc/cron.d/cloud_servers_vpc" do
  mode "0644"
  source "cloud_servers_vpc.cron.erb"
  notifies :run, resources("execute[touch_cron_d]")
end
