require 'chefspec'

describe 'The recipe plone::commons' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'plone::commons' }

  it 'should install package libshadow' do
    expect(chef_run).to install_package 'libshadow-ruby1.8'
  end

end
