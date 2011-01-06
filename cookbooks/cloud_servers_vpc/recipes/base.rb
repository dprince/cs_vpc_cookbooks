#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: base
#
# Copyright 2010, Rackspace
#

include_recipe "ruby_enterprise"

package 'mysql-devel' do
action :install
end

[
  ['rake','0.8.7'],
  ['rails','2.3.8'],
  ['mysql','2.8.1'],
  ['json','1.4.3'],
  ['resque','1.10.0'],
  ['SystemTimer','1.2.1']
].each do |gem_version|

  ree_gem gem_version[0] do
    version gem_version[1]
  end

end

user "cloud_servers_vpc" do
  comment "Cloud Servers VPC"
end

version_check_file="#{node[:cloud_servers_vpc][:home]}/version_#{node[:cloud_servers_vpc][:version]}"
bash "download_and_extract" do
  action :run
  cwd "/tmp"
  code <<-EOH
    mkdir -p #{node[:cloud_servers_vpc][:home]}
    cd #{node[:cloud_servers_vpc][:home]}
    wget --no-check-certificate #{node[:cloud_servers_vpc][:git_hub_url]}/#{node[:cloud_servers_vpc][:version]} -O - | tar -xz
    mv *-cloud_servers_vpc*/* .
    rm -Rf *-cloud_servers_vpc*
    cd /opt && chown cloud_servers_vpc:cloud_servers_vpc -R cloud-servers-vpc
    touch #{version_check_file}
  EOH
  not_if do File.exists?(version_check_file) end
end

["tmp", "tmp/pids", "log"].each do |tmp_dir|
  directory "#{node[:cloud_servers_vpc][:home]}/#{tmp_dir}" do
    owner "cloud_servers_vpc"
    mode "0755"
    action :create
    recursive true
  end
end

redis_server=node[:cloud_servers_vpc][:redis_hostname]
if redis_server.nil? then
  redis_server=search(:node, "role:redis")[0].name
end

database_server=node[:cloud_servers_vpc][:db_hostname]
if database_server.nil? then
  database_server=search(:node, "role:database")[0].name
end

template "#{node[:cloud_servers_vpc][:home]}/config/environments/production.rb" do
  owner "cloud_servers_vpc"
  mode "0644"
  source "production.rb.erb"
  variables(:redis_server => redis_server)
end

template "#{node[:cloud_servers_vpc][:home]}/config/database.yml" do
  owner "cloud_servers_vpc"
  mode "0644"
  source "database.yml.erb"
  variables(:database_server => database_server)
end

include_recipe "iptables"
iptables_rule "ssh_iptables" do
  source "ssh_iptables.erb"
end
