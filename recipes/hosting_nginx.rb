#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Recipe:: hosting_nginx
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

# Install nginx webserver.
include_recipe "nginx"

# Get the vhost data bag name for this node.
data_bag = node[:plone][:vhost_data_bag]

vhosts = Array.new

# Get the vhost entries for nginx.
if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  # Load VHost entries from the data bag.
  begin
    vhosts = search(data_bag, '*:*')
  rescue Net::HTTPServerException
    Chef::Log.info("Could not search for #{data_bag} data bag items, skipping dynamically generated vhost entries.")
  end
  if vhosts.nil? || vhosts.empty?
    Chef::Log.info("No vhost entries returned from data bag search.")
  end
end

# Generate all vhost entries.
vhosts.each do |vhost|
  plone_vhost vhost[:domain] do
    plone_site vhost[:site]
    backend_ip node[:cloud][:local_ipv4] || node[:ipaddress]
  end
end
