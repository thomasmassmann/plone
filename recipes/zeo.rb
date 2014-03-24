#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Recipe:: zeo
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

# Install rsync, necessary for backup.
include_recipe "rsync"

zeo_dir = node[:plone][:zeo][:dir]

# Add ZEO-Server directory.
directory zeo_dir do
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
  directory "#{zeo_dir}/#{dir}" do
    owner node[:plone][:user]
    group node[:plone][:group]
    mode 00755
    action :create
    recursive true
  end
end

# ZEO-Server buildout bootstrap.
cookbook_file "#{zeo_dir}/bootstrap.py" do
  source "bootstrap.py"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
end

versions_path = "#{zeo_dir}/#{node[:plone][:version]}"

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

case node[:platform]
when "debian", "ubuntu"
  template "/etc/init.d/plone_zeoserver" do
    source "plone.init.erb"
    owner "root"
    group "root"
    mode "755"
    variables({
      :home => zeo_dir,
      :name => "plone_zeoserver"
    })
  end

  template "/etc/default/plone_zeoserver" do
    source "plone.default.erb"
    owner "root"
    group "root"
    mode "644"
    variables({
      :name => "plone_zeoserver"
    })
  end

  service "plone_zeoserver" do
    action :nothing
  end
end

# ZEO-Server buildout configuration.
template "#{zeo_dir}/base.cfg" do
  source "base.cfg.erb"
  owner node[:plone][:user]
  group node[:plone][:group]
  mode 0644
  variables({
    :backups_dir => node[:plone][:backups][:directory],
    :backups_keep => node[:plone][:backups][:keep],
    :backups_keep_blob_days => node[:plone][:backups][:keep_blob_days],
    :environment_vars => node[:plone][:environment_vars],
    :extensions => node[:plone][:extensions],
    :find_links => node[:plone][:find_links],
    :initial_password => node[:plone][:initial_password],
    :initial_user => node[:plone][:initial_user],
    :newest => node[:plone][:newest],
    :prefer_final => node[:plone][:prefer_final],
    :unzip => node[:plone][:unzip],
    :user => node[:plone][:user]
  })
  notifies :run, "execute[buildout_plone_zeoserver]"
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
template "#{zeo_dir}/buildout.cfg" do
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
  notifies :run, "execute[buildout_plone_zeoserver]", :immediately
end

# Run ZEO-Server buildout.
execute "buildout_plone_zeoserver" do
  cwd zeo_dir
  command "#{node[:plone][:home]}/venv/bin/python bootstrap.py && ./bin/buildout"
  user node[:plone][:user]
  action :nothing
  notifies :restart, "service[plone_zeoserver]", :immediately
end

# ZEO-Server daily backup.
cron "zeoserver-backup" do
  minute node[:plone][:backups][:minute]
  hour node[:plone][:backups][:hour]
  command "#{zeo_dir}/bin/backup -q"
  user node[:plone][:user]
  action node[:plone][:backups][:enabled] == true ? :create : :delete
end

# ZEO-Server weekly database pack.
cron "zeoserver-pack" do
  minute node[:plone][:pack][:minute]
  hour node[:plone][:pack][:hour]
  weekday node[:plone][:pack][:weekday]
  command "#{zeo_dir}/bin/zeopack #{zeo_ip}:#{node[:plone][:zeo][:port]}"
  user node[:plone][:user]
  action node[:plone][:pack][:enabled] == true ? :create : :delete
end

case node[:platform]
when "debian", "ubuntu"
  service "plone_zeoserver" do
    action [:enable, :start]
  end
end
