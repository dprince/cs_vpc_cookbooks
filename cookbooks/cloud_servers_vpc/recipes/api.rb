#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: api
#
# Copyright 2010, Rackspace
#

include_recipe "#{@cookbook_name}::base"
include_recipe "apache2"

bash "restart_apache" do
  action :nothing
  cwd "/tmp"
  user "root"
  code "/bin/true"
  notifies :restart, resources("service[apache2]")
  subscribes :run, resources("bash[download_and_extract]")
end

web_app "cloud_servers_vpc" do
  docroot "/opt/cloud-servers-vpc/public"
  server_name "vpc.#{node[:domain]}"
  server_aliases [ "vpc", node[:hostname] ]
  rails_env "production"
end

execute "touch_cron_d" do
  command "touch /etc/cron.d"
  action :nothing
end

template "/etc/cron.d/cloud_servers_vpc" do
  mode "0644"
  source "cloud_servers_vpc.cron.erb"
  notifies :run, resources("execute[touch_cron_d]")
end

include_recipe "iptables"
iptables_rule "httpd_iptables" do
  variables(
    :rule_prefix => node[:cloud_servers_vpc][:httpd_iptables_rule_prefix]
  )
  source "httpd_iptables.erb"
end
