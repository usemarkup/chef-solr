if Chef::Config[:solo]
    node.expand!('disk')
else
    node.expand!('server')
end

default["solr"]["version"] = "5.3.0"
default["solr"]["host"] = "archive.apache.org"
default["solr"]["link"] = "http://#{node['solr']['host']}/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
default["solr"]["checksum"] = "26aec63d81239a65f182f17bbf009b1070f7db0bb83657ac2a67a08b57227f7c" #sha256
default["solr"]["download"] = "#{Chef::Config[:file_cache_path]}"

default["solr"]["install_java"] = true
default["solr"]["jdk_version"] = 7

default["solr"]["install"] = "/opt"
default["solr"]["directory"] = "/var/solr"
default["solr"]["port"] = "8983"
default["solr"]["service"] = "solr"
default["solr"]["user"] = "solr"

default["solr"]["pidfile_path"] = nil
default["solr"]["log_path"] = nil
default["solr"]["home_path"] = nil
default["solr"]["solr_heap"] = "512m"

