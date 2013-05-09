require 'chefspec'

describe 'plone::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'plone::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
