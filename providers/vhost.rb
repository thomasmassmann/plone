#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Provider:: vhost
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

action :enable do
 Chef::Log.debug "Adding #{new_resource.domain_name}."

  template "#{node[:nginx][:dir]}/sites-available/#{new_resource.domain_name}.conf" do
    source new_resource.template
    cookbook new_resource.cookbook
    owner "root"
    group "root"
    mode "644"
    variables :vhost => new_resource
    notifies :reload, 'service[nginx]'
  end

  nginx_site "#{new_resource.domain_name}.conf" do
    enable true
  end

  new_resource.updated_by_last_action(true)
end

action :disable do
  Chef::Log.debug "Disabling #{new_resource.domain_name}."

  disable_config

  new_resource.updated_by_last_action(true)
end

action :remove do
  Chef::Log.debug "Removing #{new_resource.domain_name}."

  disable_config
  file "#{node[:nginx][:dir]}/sites-available/#{new_resource.domain_name}.conf" do
    action :delete
    notifies :reload, 'service[nginx]'
  end

  new_resource.updated_by_last_action(true)
end

def disable_config
  nginx_site "#{new_resource.domain_name}.conf" do
    enable false
    notifies :reload, 'service[nginx]'
  end
end