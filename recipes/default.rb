#
# Cookbook Name:: observium
# Recipe:: default
#

require 'rubygems'

include_recipe 'apache2'

if platform?('centos', 'redhat')
  include_recipe 'yum'
  include_recipe 'yum-epel'
  include_recipe 'yum-repoforge'
else
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt'
end

# Run first because of dependencies for mysql gem
node['observium']['package_dependencies'].each do |p|
  package p
end

if node['observium']['db']['host'] == 'localhost'
  mysql_service 'observium' do
    socket "/var/run/mysql-observium/mysqld.sock"
    version '5.5'
    initial_root_password node['mysql']['server_root_password']
    action [:create, :start]
  end
end

mysql_connection_info = {
  host: node['observium']['db']['host'],
  username: 'root',
  password: node['mysql']['server_root_password'],
  :socket   => "/var/run/mysql-observium/mysqld.sock"
}

mysql2_chef_gem 'default' do
  action :install
end

if platform?('centos', 'redhat')
 # since include_recipe yum-epel runs later than .run_action()
  %w{php-mcrypt fping collectd-rrdtool}.each do |pkg|
    package pkg
  end
end

mysql_database node['observium']['db']['db_name'] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node['observium']['db']['user'] do
  connection mysql_connection_info
  password node['observium']['db']['password']
  database_name node['observium']['db']['db_name']
  action [:create, :grant]
end

ark 'observium' do
  url 'http://www.observium.org/observium-community-latest.tar.gz'
  prefix_root '/opt'
  path '/opt'
  home_dir node['observium']['install_dir']
  owner node['apache']['user']
  action :install
end

template "#{node['observium']['install_dir']}/config.php" do
  source 'config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
  mode 0766
end

directory "#{node['observium']['install_dir']}/rrd" do
  owner node['apache']['user']
  group node['apache']['group']
  mode 00755
  action :create
end

directory "#{node['observium']['install_dir']}/logs" do
  owner node['apache']['user']
  group node['apache']['group']
  mode 00755
  action :create
end

# only run the execute blocks, if not allready set up

if  node['observium']['installed'] == false

  # Setup the MySQL database and insert the default schema
  execute 'php includes/update/update.php' do
    cwd node['observium']['install_dir']
    # not_if ''
  end

  # create admin
  execute './adduser.php admin admin 10' do
    cwd node['observium']['install_dir']
  end

  # Initial discovery
  execute './discovery.php -h all' do
    cwd node['observium']['install_dir']
  end

  # Initial polling
  execute './poller.php -h all' do
    cwd node['observium']['install_dir']
  end
  node.normal['observium']['installed'] = true
  node.save unless Chef::Config[:solo]
end

web_app 'observium' do
  server_name node['observium']['server_name']
  server_aliases node['observium']['server_aliases']
  docroot "#{node['observium']['install_dir']}/html/"
  allow_override 'all'
end

# setup crons

cron_d 'discovery-all' do
  minute '33'
  hour '*/6'
  command "#{node['observium']['install_dir']}/discovery.php -h all >> /dev/null 2>&1"
  user 'root'
end

cron_d 'discovery-new' do
  minute '*/5'
  command "#{node['observium']['install_dir']}/discovery.php -h new >> /dev/null 2>&1"
  user 'root'
end

cron_d 'poller-wrapper' do
  minute '*/5'
  command "#{node['observium']['install_dir']}/poller-wrapper.py #{node['observium']['config']['poller_threads']} >> /dev/null 2>&1"
  user 'root'
end
