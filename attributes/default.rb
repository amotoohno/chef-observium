default['mysql']['server_root_password'] = 'root'
default['mysql']['data_dir'] = '/data'

case node[:platform]
when 'debian', 'ubuntu'
  default['mysql']['version'] = '5.5'
  default['apache']['user'] = 'www-data'
  default['apache']['group'] = 'www-data'
  default['observium']['package_dependencies'] = %w{build-essential libmysqlclient-dev libapache2-mod-php5 php5-cli php5-mysql php5-gd php5-snmp php-pear snmp graphviz php5-mcrypt php5-json subversion mysql-client rrdtool fping imagemagick whois mtr-tiny nmap ipmitool python-mysqldb}
when 'centos', 'redhat'
  default['mysql']['version'] = '5.1'
  default['apache']['user'] = 'apache'
  default['apache']['group'] = 'apache'
  default['observium']['package_dependencies'] = %w{wget ruby-devel gcc rubygems php mysql mysql-devel php-mysql php-gd php-snmp php-pear net-snmp net-snmp-utils graphviz subversion rrdtool ImageMagick jwhois nmap ipmitool MySQL-python}
end

default['observium']['installed'] = true
default['observium']['install_dir'] = '/opt/observium'
default['observium']['server_name'] = 'observium.example.com'
default['observium']['server_aliases'] = ['observium.localhost']

default['observium']['device_status']['devices'] = true
default['observium']['device_status']['ports'] = false
default['observium']['device_status']['errors'] = true
default['observium']['device_status']['services'] = true
default['observium']['device_status']['bgp'] = false
default['observium']['device_status']['uptime'] = true

default['observium']['config']['fping_path'] = '/usr/bin/fping'
default['observium']['config']['collectd_dir'] = '/var/lib/collectd/rrd/'
default['observium']['config']['poller_threads'] = '8'

default['observium']['db']['host'] = 'localhost'
default['observium']['db']['user'] = 'observium'
default['observium']['db']['password'] = 'observium'
default['observium']['db']['db_name'] = 'observium'

default['observium']['alert']['enable'] = true
default['observium']['alert']['email'] = 'mail@example.com'
default['observium']['alert']['default_only'] = true
default['observium']['alert']['email_enable'] = true
default['observium']['alert']['uptime_warning'] = '86400'
default['observium']['alert']['port_status'] = false
