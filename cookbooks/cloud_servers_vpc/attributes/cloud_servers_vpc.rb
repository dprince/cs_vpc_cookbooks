default[:cloud_servers_vpc][:version]="master"
default[:cloud_servers_vpc][:git_hub_url]="https://github.com/rackspace/cloud_servers_vpc/tarball"

default[:cloud_servers_vpc][:rackspace_cloud_username]="test"
default[:cloud_servers_vpc][:rackspace_cloud_api_key]="test"

default[:cloud_servers_vpc][:rackspace_cloud_server_name_prefix]="" #optional

set[:cloud_servers_vpc][:home]="/opt/cloud-servers-vpc"

default[:cloud_servers_vpc][:resque_workers]="6"

default[:cloud_servers_vpc][:mysql_admin_user]="root"
default[:cloud_servers_vpc][:mysql_admin_password]=""

default[:cloud_servers_vpc][:db_name]="cs_vpc_prod"
default[:cloud_servers_vpc][:db_user]="vpc"
default[:cloud_servers_vpc][:db_password]="vpc123"

default[:cloud_servers_vpc][:mysql_iptables_rule_prefix]="-i tun+"
default[:cloud_servers_vpc][:redis_iptables_rule_prefix]="-i tun+"
