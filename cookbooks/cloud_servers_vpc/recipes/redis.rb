#
# Cookbook Name:: cloud_servers_vpc
# Recipe:: redis
#
# Copyright 2010, Rackspace
#

ip_addr=node[:ipaddress]

user "redis" do
  comment "Redis"
  home "/var/lib/redis"
  shell "/sbin/nologin"
end

package "redis"

template "/etc/redis.conf" do
  owner "redis"
  source "redis.conf.erb"
end

service "redis" do
  action [ :start, :enable ]
  subscribes :restart, resources("template[/etc/redis.conf]")
end

include_recipe "iptables"
iptables_rule "redis_iptables" do
  variables(
    :rule_prefix => node[:cloud_servers_vpc][:redis_iptables_rule_prefix]
  )
  source "redis_iptables.erb"
end
