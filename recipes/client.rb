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

client_dir = node[:plone][:client][:dir]
plone_version = node[:plone][:version]
versions_path = "#{client_dir}/#{plone_version}"

# Install additional packages.
%w{ libjpeg-dev libxslt-dev }.each do |pkg|
  package pkg do
    action :install
  end
end

# Add ZEO-Client directory.
directory client_dir do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
end

directory "#{client_dir}/products" do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
end

directory "#{versions_path}/buildout-cache" do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
  recursive true
end

# Add ZEO-Client buildout directories.
%w{ eggs downloads }.each do |dir|
  directory "#{versions_path}/buildout-cache/#{dir}" do
    owner node[:plone][:user]
    group node[:plone][:group]
    mode 00755
    action :create
    recursive true
  end
end

# ZEO-Client buildout bootstrap.
cookbook_file "#{client_dir}/bootstrap.py" do
  source "bootstrap.py"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
end

# Add versions directory.
directory versions_path do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
  recursive true
end

remote_file "#{versions_path}/versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{plone_version}/base_skeleton/versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  action :create_if_missing
end

remote_file "#{versions_path}/zope-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{plone_version}/base_skeleton/zope-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  action :create_if_missing
end

remote_file "#{versions_path}/zopeapp-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{plone_version}/base_skeleton/zopeapp-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  action :create_if_missing
end

remote_file "#{versions_path}/ztk-versions.cfg" do
  source "https://raw.github.com/plone/Installers-UnifiedInstaller/#{plone_version}/base_skeleton/ztk-versions.cfg"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  action :create_if_missing
end

# ZEO-Client buildout base.
template "#{client_dir}/base.cfg" do
  source "base.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :backups_dir => node[:plone][:backups][:directory],
    :environment_vars => node[:plone][:environment_vars],
    :extensions => node[:plone][:extensions],
    :find_links => node[:plone][:find_links],
    :initial_password => node[:plone][:initial_password],
    :initial_user => node[:plone][:initial_user],
    :newest => node[:plone][:newest],
    :prefer_final => node[:plone][:prefer_final],
    :unzip => node[:plone][:unzip],
    :user => node[:plone][:user],
  })
  notifies :run, "execute[buildout_plone_client]"
end

# Search for ZEO Servers.
if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  zeo_servers = Array.new
  zeo_servers << node
else
  zeo_servers = search(:node, "role:#{node[:plone][:client][:zeo_role]} AND chef_environment:#{node.chef_environment}") || []
  if zeo_servers.empty?
    Chef::Log.info("No nodes returned from search, using this node so buildout.cfg has data.")
    zeo_servers = Array.new
    zeo_servers << node
  end
end

# ZEO-Client buildout configuration.
template "#{client_dir}/buildout.cfg" do
  source "buildout_app.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :client_ip => node[:cloud][:local_ipv4] || node[:ipaddress],
    :client_port => node[:plone][:client][:port_base].to_i,
    :clients => node[:plone][:client][:count],
    :dev_packages => node[:plone][:client][:dev][:sources],
    :dev_packages_enabled => node[:plone][:client][:dev][:enabled],
    :eggs => node[:plone][:client][:eggs],
    :extends => node[:plone][:client][:extends],
    :version => plone_version,
    :versions => node[:plone][:zeo][:versions],
    :zcml => node[:plone][:client][:zcml],
    :zeo_servers => zeo_servers.uniq,
  })
  notifies :run, "execute[buildout_plone_client]"
end

# Run ZEO-Client buildout.
execute "buildout_plone_client" do
  cwd client_dir
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout > buildout.txt"
  environment({
    "HOME" => node[:plone][:home],
    "USER" => node[:plone][:user]
  })
  user node[:plone][:user]
  action :nothing
  notifies :restart, "service[plone_client]"
end

case node[:platform]
when "debian", "ubuntu"
  template "/etc/init.d/plone_client" do
    source "plone.init.erb"
    owner "root"
    group "root"
    mode "755"
    variables({
      :home => client_dir,
      :name => "plone_client"
    })
  end

  template "/etc/default/plone_client" do
    source "plone.default.erb"
    owner "root"
    group "root"
    mode "644"
    variables({
      :name => "plone_client"
    })
  end

  service "plone_client" do
    action [:enable, :start]
  end
end
