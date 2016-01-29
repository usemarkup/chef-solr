require 'chefspec'

describe 'chef-solr::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'chef-solr::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
