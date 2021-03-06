package 'lsof'
package 'initscripts'

if node['solr']['install_java']
  node.override['java']['jdk_version'] = node['solr']['jdk_version']

  include_recipe 'java'
end

user 'solr' do
  home node['solr']['install']
  system true
  shell '/bin/bash'
end

remote_file "#{node['solr']['download']}/solr-#{node['solr']['version']}.tgz" do
  source    "https://#{node['solr']['host']}/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
  checksum  node['solr']['checksum']
  mode      0644
end

execute 'Unpack Solr' do
  command "tar xzf #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz -C #{node['solr']['download']}"
  not_if "test -d #{node['solr']['download']}/solr-#{node['solr']['version']}"
end

if node['solr']['version'].to_i < 7
  ruby_block 'patch_solr_installer' do
    block do
      file = Chef::Util::FileEdit.new("#{node['solr']['download']}/solr-#{node['solr']['version']}/bin/install_solr_service.sh")
      # Required for Solr < 7
      # See https://github.com/apache/lucene-solr/commit/a1bbc996e4e6324f899a18c4ea9e31075abdc0ad#diff-dde070c28a5e04e74eb7cadf421bbf93
      # This allows for better detection in environments like Docker
      file.search_file_replace_line(%r{proc_version=\`cat \/proc\/version\`}, 'proc_version="Red Hat"')
      file.write_file
    end
  end
end

execute "Install Solr #{node['solr']['version']}" do
  live_stream true
  command <<-EOH

if [ -f #{node['solr']['install']}/solr/bin/solr ]; then
  if [ "#{node['solr']['version']}" == "5.3.0" ]; then
     if [ "#{node['solr']['force_upgrade']}" == "false" ]; then
        # We cannot detect the Solr Version as `-v` as only added in Solr 5.4
        # https://github.com/apache/lucene-solr/commit/3860eec3f071fa0a458b6c64c0556cdafdae8731

        echo "Solr 5.3.0 already installed, we cannot detect the exact version correctly so aborting"
        echo "Either upgrade solr with the force or manually upgrade to at least 5.4"
        echo "set force_upgrade to true"
        exit 0
     fi
  else
    version=$(#{node['solr']['install']}/solr/bin/solr -v)

    if [ "$version" == "#{node['solr']['version']}" ]; then
      echo "Solr Version #{node['solr']['version']} is already, skipping"
      exit 0
    fi

    if [ "$version" == "#{node['solr']['version']}" ]; then
      if [ "#{node['solr']['force_upgrade']}" == "false" ]; then
        echo "Solr Version mismatch, but force_upgrade is false, so skipping upgrading"
        echo "Set force_upgrade to true if you wish to upgrade also"
        
        exit 0
      fi
    fi
  fi
fi

echo "installed" > /tmp/solr-installed

#{node['solr']['download']}/solr-#{node['solr']['version']}/bin/install_solr_service.sh \
  #{node['solr']['download']}/solr-#{node['solr']['version']}.tgz \
  -d #{node['solr']['directory']} \
  -i #{node['solr']['install']} \
  -p #{node['solr']['port']} \
  -s #{node['solr']['service']} \
  -u #{node['solr']['user']} #{node['solr']['extra_install_arguments']}
      EOH
end

# The solr installer will boot solr, however it will be in the
# wrong configuration, this attempts to stop it
execute '/tmp/solr-installed' do
  command '/etc/init.d/solr stop && rm -rf /tmp/solr-installed'
  retries 5
  retry_delay 10
  only_if { ::File.exist?("/tmp/solr-installed") }
end

directory 'solr_log' do
  path node['solr']['log_path']
  owner 'solr'
  group 'solr'
  mode '0755'
  action :create
  only_if { node['solr']['log_path'] }
end

directory 'solr_pidfile' do
  path node['solr']['pidfile_path']
  owner 'solr'
  group 'solr'
  mode '0755'
  action :create
  only_if { node['solr']['pidfile_path'] }
end

# Create a default solr.in.sh
template '/etc/default/solr.in.sh' do
  atomic_update false
  source 'solr.in.sh.erb'
  owner node['solr']['user']
  variables ({ solr: node['solr'] })
  cookbook node['solr']['cookbook']
  notifies :restart, 'service[solr]', :delayed
end

# Create a default solr.in.sh in the solr directory
template "#{node['solr']['directory']}/solr.in.sh" do
  atomic_update false
  source 'solr.in.sh.erb'
  owner node['solr']['user']
  variables ({ solr: node['solr'] })
  cookbook node['solr']['cookbook']
  notifies :restart, 'service[solr]', :delayed
end

if node['platform_version'].to_i > 6
  file '/usr/lib/tmpfiles.d/solr.conf' do
    content 'D /var/run/solr 0755 solr solr -'
    mode '0755'
  end
end

service 'solr' do
  if node['platform_version'].to_i > 6
    provider Chef::Provider::Service::Systemd
  end
  supports status: true, restart: true, enable: true, start: true
  action [:enable]
end
