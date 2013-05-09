require 'chefspec'

describe 'plone::app' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'plone::app' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
