default['solr']['version'] = '5.5.4'
default['solr']['host'] = 'archive.apache.org'
default['solr']['checksum'] = 'c1528e4afc9a0b8e7e5be0a16f40bb4080f410d502cd63b4447d448c49e9f500'
default['solr']['force_upgrade'] = false
default['solr']['download'] = Chef::Config[:file_cache_path]

if node['solr']['force_upgrade']
  default['solr']['extra_install_arguments'] = '-f'
else
  default['solr']['extra_install_arguments'] = ''
end

default['solr']['install_java'] = true
default['solr']['jdk_version'] = 8

default['solr']['install'] = '/opt'
default['solr']['directory'] = '/var/solr'
default['solr']['port'] = '8983'
default['solr']['service'] = 'solr'
default['solr']['user'] = 'solr'
default['solr']['cookbook'] = 'solr'

default['solr']['pidfile_path'] = '/var/run/solr'
default['solr']['log_path'] = '/var/log/solr'
default['solr']['home_path'] = nil
default['solr']['solr_heap'] = '512m'
