require 'chefspec'

describe 'plone::zeo' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'plone::zeo' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
