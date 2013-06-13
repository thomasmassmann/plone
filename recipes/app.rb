#
# Cookbook Name:: plone
# Recipe:: app
#
# Copyright 2013, Propertyshelf, Inc.
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
%w{ eggs downloads extends-cache products }.each do |dir|
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

# ZEO-Client buildout configuration.
template "#{node[:plone][:app_home]}/buildout.cfg" do
  source "buildout_app.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :client_ip => "127.0.0.1",
    :client_port => "8080",
    :eggs => node[:plone][:eggs],
    :version => node[:plone][:version],
    :versions => node[:plone][:zeo][:versions],
    :zcml => node[:plone][:zcml],
    :zeo_ip => "127.0.0.1",
    :zeo_port => node[:plone][:zeo][:port],
  })
  notifies :run, "execute[buildout_#{node[:plone][:app_name]}_client]"
end

# Run ZEO-Client buildout.
execute "buildout_#{node[:plone][:app_name]}_client" do
  cwd node[:plone][:app_home]
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout"
  user node[:plone][:user]
  action :nothing
  # notifies :restart, "supervisor_service[zeoserver]", :immediately
end
