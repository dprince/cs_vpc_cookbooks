#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: database
#
# Copyright 2010, Rackspace
#

include_recipe "#{@cookbook_name}::base"

package 'mysql-server' do
  action :install
end

service "mysqld" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end

bash "create_db" do
  action :nothing
  cwd "/tmp"
  user "root"
  code <<-EOH
    mysqladmin -u #{node[:cloud_servers_vpc][:mysql_admin_user]} -p\"#{node[:cloud_servers_vpc][:mysql_admin_password]}\" create #{node[:cloud_servers_vpc][:db_name]}
  EOH
  not_if do File.exists?("/var/lib/mysql/#{node[:cloud_servers_vpc][:db_name]}") end
end

create_db_user node[:cloud_servers_vpc][:db_user] do
  password node[:cloud_servers_vpc][:db_password]
  database node[:cloud_servers_vpc][:db_name]
end

bash "create_update_db" do
  action :nothing
  cwd "/#{node[:cloud_servers_vpc][:home]}"
  user "root"
  code <<-EOH
    RAILS_ENV=production /opt/ruby-enterprise/bin/ruby /opt/ruby-enterprise/bin/rake db:migrate
  EOH
  subscribes :run, resources("bash[download_and_extract]")
end

include_recipe "iptables"
iptables_rule "mysql_iptables" do
  variables(
    :rule_prefix => node[:cloud_servers_vpc][:mysql_iptables_rule_prefix]
  )
  source "mysql_iptables.erb"
end
