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

# Install rsync, necessary for backup.
include_recipe "rsync"

# Add ZEO-Server directory.
directory node[:plone][:zeo][:dir] do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
end

# Add Backups directory.
directory node[:plone][:backups][:directory] do
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 00755
  action :create
  recursive true
end

# Add ZEO-Server buildout directories.
%w{ eggs downloads }.each do |dir|
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

versions_path = "#{node[:plone][:zeo][:dir]}/#{node[:plone][:version]}"

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

# ZEO-Server buildout configuration.
template "#{node[:plone][:zeo][:dir]}/base.cfg" do
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
    :user => node[:plone][:user]
  })
  notifies :run, "execute[buildout_#{node[:plone][:app_name]}_zeoserver]"
end

zeo_ip = begin
  if node[:plone][:zeo][:custom_ip]
    node[:plone][:zeo][:custom_ip]
  elsif node.attribute?("cloud")
    case node[:cloud][:provider]
    when "rackspace", "vagrant"
      node[:cloud][:local_ipv4]
    else
      node[:ipaddress]
    end
  else
    node[:ipaddress]
  end
end
node.set[:plone][:zeo][:ip] = zeo_ip

# ZEO-Server buildout configuration.
template "#{node[:plone][:zeo][:dir]}/buildout.cfg" do
  source "buildout_zeo.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :version => node[:plone][:version],
    :versions => node[:plone][:zeo][:versions],
    :zeo_ip => zeo_ip,
    :zeo_port => node[:plone][:zeo][:port]
  })
  notifies :run, "execute[buildout_#{node[:plone][:app_name]}_zeoserver]"
end

# Run ZEO-Server buildout.
execute "buildout_#{node[:plone][:app_name]}_zeoserver" do
  cwd node[:plone][:zeo][:dir]
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout"
  user node[:plone][:user]
  action :nothing
  notifies :restart, "service[#{node[:plone][:app_name]}_zeoserver]"
end

# ZEO-Server daily backup.
cron "zeoserver-backup" do
  minute node[:plone][:backups][:minute]
  hour node[:plone][:backups][:hour]
  command "#{node[:plone][:zeo][:dir]}/bin/backup -q"
  user node[:plone][:user]
  action node[:plone][:backups][:enabled] == true ? :create : :delete
end

# ZEO-Server weekly database pack.
cron "zeoserver-pack" do
  minute node[:plone][:pack][:minute]
  hour node[:plone][:pack][:hour]
  weekday node[:plone][:pack][:weekday]
  command "#{node[:plone][:zeo][:dir]}/bin/zeopack #{zeo_ip}:#{node[:plone][:zeo][:port]}"
  user node[:plone][:user]
  action node[:plone][:pack][:enabled] == true ? :create : :delete
end

case node[:platform]
when "debian", "ubuntu"
  template "/etc/init.d/#{node[:plone][:app_name]}_zeoserver" do
    source "plone.init.erb"
    owner "root"
    group "root"
    mode "755"
    variables({
      :home => node[:plone][:zeo][:dir],
      :name => "#{node[:plone][:app_name]}_zeoserver"
    })
  end

  template "/etc/default/#{node[:plone][:app_name]}_zeoserver" do
    source "plone.default.erb"
    owner "root"
    group "root"
    mode "644"
    variables({
      :name => "#{node[:plone][:app_name]}_zeoserver"
    })
  end

  service "#{node[:plone][:app_name]}_zeoserver" do
    action [:enable, :start]
  end
end
