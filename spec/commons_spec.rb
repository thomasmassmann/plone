require 'chefspec'

describe 'plone::commons' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'plone::commons' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
