#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Recipe:: app
#
# Copyright:: 2012-2013, Thomas Massmann
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
#

# Install dependencies, prepare common directories.
include_recipe "plone::commons"

# Install additional packages.
%w{ libjpeg-dev libxslt-dev }.each do |pkg|
  package pkg do
    action :install
  end
end

# Add ZEO-Client directory.
directory node[:plone][:app_home] do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
end

# Add ZEO-Client buildout directories.
%w{ eggs downloads products }.each do |dir|
  directory "#{node[:plone][:app_home]}/#{dir}" do
    owner node[:plone][:user]
    group node[:plone][:group]
    mode 00755
    action :create
    recursive true
  end
end

# ZEO-Client buildout bootstrap.
cookbook_file "#{node[:plone][:app_home]}/bootstrap.py" do
  source "bootstrap.py"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
end

versions_path = "#{node[:plone][:app_home]}/#{node[:plone][:version]}"

# Add versions directory.
directory versions_path do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
  recursive true
end

remote_file "#{versions_path}/versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{node[:plone][:version]}/base_skeleton/versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  not_if { ::File.exists?("#{versions_path}/versions.cfg") }
end

remote_file "#{versions_path}/zope-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{node[:plone][:version]}/base_skeleton/zope-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  not_if { ::File.exists?("#{versions_path}/zope-versions.cfg") }
end

remote_file "#{versions_path}/zopeapp-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{node[:plone][:version]}/base_skeleton/zopeapp-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  not_if { ::File.exists?("#{versions_path}/zopeapp-versions.cfg") }
end

remote_file "#{versions_path}/ztk-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{node[:plone][:version]}/base_skeleton/ztk-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  not_if { ::File.exists?("#{versions_path}/ztk-versions.cfg") }
end

# ZEO-Client buildout base.
template "#{node[:plone][:app_home]}/base.cfg" do
  source "base.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :backups_dir => node[:plone][:backups][:directory],
    :environment_vars => node[:plone][:environmen_vars],
    :extensions => node[:plone][:extensions],
    :find_links => node[:plone][:find_links],
    :initial_password => node[:plone][:initial_password],
    :initial_user => node[:plone][:initial_user],
    :newest => node[:plone][:newest],
    :prefer_final => node[:plone][:prefer_final],
    :unzip => node[:plone][:unzip],
    :user => node[:plone][:user],
  })
  notifies :run, "execute[buildout_#{node[:plone][:app_name]}_client]"
end

# Search for ZEO Servers.
if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  zeo_servers = Array.new
  zeo_servers << node
else
  zeo_servers = search(:node, "role:#{node[:plone][:zeo][:role]} AND chef_environment:#{node.chef_environment}") || []
  if zeo_servers.empty?
    Chef::Log.info("No nodes returned from search, using this node so buildout.cfg has data.")
    zeo_servers = Array.new
    zeo_servers << node
  end
end

# ZEO-Client buildout configuration.
template "#{node[:plone][:app_home]}/buildout.cfg" do
  source "buildout_app.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :client_ip => node[:cloud][:local_ipv4] || node[:ipaddress],
    :client_port => node[:plone][:port],
    :dev_packages => node[:plone][:dev][:sources],
    :dev_packages_enabled => node[:plone][:dev][:enabled],
    :eggs => node[:plone][:eggs],
    :version => node[:plone][:version],
    :versions => node[:plone][:zeo][:versions],
    :zcml => node[:plone][:zcml],
    :zeo_servers => zeo_servers.uniq,
  })
  notifies :run, "execute[buildout_#{node[:plone][:app_name]}_client]"
end

# Run ZEO-Client buildout.
execute "buildout_#{node[:plone][:app_name]}_client" do
  cwd node[:plone][:app_home]
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout"
  environment({
    "HOME" => node[:plone][:home],
    "USER" => node[:plone][:user]
  })
  user node[:plone][:user]
  action :nothing
  notifies :restart, "service[#{node[:plone][:app_name]}_client]"
end

case node[:platform]
when "debian", "ubuntu"
  template "/etc/init.d/#{node[:plone][:app_name]}_client" do
    source "plone.init.erb"
    owner "root"
    group "root"
    mode "755"
    variables({
      :home => node[:plone][:app_home],
      :name => "#{node[:plone][:app_name]}_client"
    })
  end

  template "/etc/default/#{node[:plone][:app_name]}_client" do
    source "plone.default.erb"
    owner "root"
    group "root"
    mode "644"
    variables({
      :name => "#{node[:plone][:app_name]}_client"
    })
  end

  service "#{node[:plone][:app_name]}_client" do
    action [:enable, :start]
  end
end
