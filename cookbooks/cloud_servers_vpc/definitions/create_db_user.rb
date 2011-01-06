define :create_db_user do

  user=params[:name]
  password=params[:password]
  db_name=params[:database]

  bash "create #{db_name} DB user: #{user}" do
    cwd "/tmp"
    user "mysql"
    code <<-EOH

	if [ ! -f /var/lib/mysql/existing_db_users/#{user} ]; then

mysql -u \"#{node[:cloud_servers_vpc][:mysql_admin_user]}\" >& /dev/null <<-EOF_MYSQL
CREATE USER #{user} IDENTIFIED BY '#{password}';
CREATE USER #{user}@localhost IDENTIFIED BY '#{password}';
EOF_MYSQL

	fi

mysql -u \"#{node[:cloud_servers_vpc][:mysql_admin_user]}\" >& /dev/null <<-EOF_MYSQL
GRANT ALL ON #{db_name}.* TO #{user};
GRANT ALL ON #{db_name}.* TO #{user}@localhost;
EOF_MYSQL

	mkdir -p /var/lib/mysql/existing_db_users/
	touch /var/lib/mysql/existing_db_users/#{user}

	mkdir -p /var/lib/mysql/#{db_name}/existing_db_users/
	touch /var/lib/mysql/#{db_name}/existing_db_users/#{user}

    EOH
    not_if do File.exists?("/var/lib/mysql/#{db_name}/existing_db_users/#{user}") end
  end

end
