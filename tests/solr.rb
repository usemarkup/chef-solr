describe service('solr') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command("curl http://127.0.0.1:8983/solr/") do
  its("stdout") { should match "Solr Admin" }
end

# Solr 5.3 does not have a `-v` option...
#describe 'runtime is available' do
#  it 'has solr' do
#    expect(command('/opt/solr/bin/solr -v').exit_status).to eq(0)
#  end
#end
