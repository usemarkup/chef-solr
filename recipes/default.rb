#
# Cookbook Name:: solr
# Recipe:: default

package 'lsof'

if node['solr']['install_java']
    node.override[:java][:jdk_version] = node[:solr][:jdk_version]

    include_recipe 'java'
end

remote_file "#{node['solr']['download']}/solr-#{node['solr']['version']}.tgz" do
  source    node['solr']['link']
  checksum  node['solr']['checksum']
  mode      0644
  notifies  :run, "bash[unpacksolr]", :immediately
end

bash 'unpacksolr' do
  code      "tar xzf #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz -C #{node['solr']['download']}"
  action    :nothing
  notifies  :run, "bash[installsolr]", :immediately
end

bash 'installsolr' do
  code      "#{node['solr']['download']}/solr-#{node['solr']['version']}/bin/install_solr_service.sh #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz -d #{node['solr']['directory']} -i #{node['solr']['install']} -p #{node['solr']['port']} -s #{node['solr']['service']} -u #{node['solr']['user']}"
  action    :nothing
end

service 'solr' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  retry_delay 5
  retries 3
end

directory 'solr_log' do
  path node[:solr][:log_path]
  owner 'solr'
  group 'solr'
  mode '0755'
  action :create
  only_if { node[:solr][:log_path] }
end

directory 'solr_pidfile' do
  path node[:solr][:pidfile_path]
  owner 'solr'
  group 'solr'
  mode '0755'
  action :create
  only_if { node[:solr][:pidfile_path] }
end

directory 'solr_home' do
  path node[:solr][:home_path]
  owner 'solr'
  group 'solr'
  mode '0755'
  action :create
  only_if { node[:solr][:home_path] }
end

ruby_block "modify config solr.in.sh" do
    block do
      file = Chef::Util::FileEdit.new("/var/solr/solr.in.sh")
      unless node[:solr][:home_path].nil?
        file.search_file_replace_line(/SOLR_HOME.*/, "SOLR_HOME=\"#{node['solr']['home_path']}\"")
        file.write_file
      end
      unless node[:solr][:log_path].nil?
        file.search_file_replace_line(/SOLR_LOGS_DIR.*/, "SOLR_LOGS_DIR=\"#{node['solr']['log_path']}\"")
        file.write_file
      end
      unless node[:solr][:pidfile_path].nil?
        file.search_file_replace_line(/SOLR_PID_DIR.*/, "SOLR_PID_DIR=\"#{node['solr']['pidfile_path']}\"")
        file.write_file
      end
    end
  notifies :restart, resources(:service => "solr"), :delayed
end
