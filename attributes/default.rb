default['solr']['version'] = '5.5.5'
default['solr']['host'] = 'archive.apache.org'
default['solr']['checksum'] = '2bbe3a55976f118c5d8c2382d4591257f6e2af779c08c6561e44afa3181a87c1'
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
