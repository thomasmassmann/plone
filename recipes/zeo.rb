#
# Cookbook Name:: plone
# Recipe:: zeo
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

# Add ZEO-Server directory.
directory node[:plone][:zeo][:dir] do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
end

# Add ZEO-Server buildout directories.
%w{ eggs downloads extends-cache }.each do |dir|
  directory "#{node[:plone][:zeo][:dir]}/#{dir}" do
    owner node[:plone][:user]
    group node[:plone][:group]
    mode 00755
    action :create
    recursive true
  end
end

# ZEO-Server buildout bootstrap.
cookbook_file "#{node[:plone][:zeo][:dir]}/bootstrap.py" do
  source "bootstrap.py"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
end

# ZEO-Server buildout configuration.
template "#{node[:plone][:zeo][:dir]}/base.cfg" do
  source "base.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
  })
end

# ZEO-Server buildout configuration.
template "#{node[:plone][:zeo][:dir]}/buildout.cfg" do
  source "buildout_zeo.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
  })
  notifies :run, "execute[buildout]", :immediately
end

# Run ZEO-Server buildout.
execute "buildout" do
  cwd node[:plone][:zeo][:dir]
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout"
  user node[:plone][:user]
  action :nothing
  # notifies :restart, "supervisor_service[zeoserver]", :immediately
end
