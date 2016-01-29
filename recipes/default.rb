#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2010, Jiva Technology Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'java'
package 'lsof'

remote_file "#{node['solr']['download']}/solr-#{node['solr']['version']}.tgz" do
  source   node['solr']['link']
  checksum node['solr']['checksum']
  mode     0644
end

user 'solr' do
  home "#{node['solr']['install']}"
  system true
  shell '/bin/bash'
end

bash 'unpack solr' do
  code   "tar xzf #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz -C /var/chef/"
  not_if "test -d #{node['solr']['download']}/solr-#{node['solr']['version']}"
  not_if "test `sha256sum #{node['solr']['download']}` = `#{node['solr']['checksum']}`"
end

bash 'install solr' do
  code "#{node['solr']['download']}/solr-#{node['solr']['version']}/bin/install_solr_service.sh #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz -d #{node['solr']['directory']} -i #{node['solr']['install']} -p #{node['solr']['port']} -s #{node['solr']['service']} -u #{node['solr']['user']}"
  not_if "test -d /#{node['solr']['install']}/solr"
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

