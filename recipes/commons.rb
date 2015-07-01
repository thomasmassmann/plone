#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Recipe:: commons
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

# Install and configure python, python-dev, pip and virtualenv.
include_recipe "python::default"

package "python-dev" do
  action :install
  only_if { platform?("ubuntu") }
end

# This package is currently necessary for the user resource (password functions).
package "libshadow-ruby1.8" do
  action :install
  only_if { platform?("debian") }
end

# ruby-shadow replaces libshadow-ruby1.8 for newer versions of both Debian and Ubuntu
package "ruby-shadow" do
  action :install
  only_if { platform?("ubuntu") }
end

# Add Plone group.
group node[:plone][:group] do
  action :create
end

# Add Plone user.
user node[:plone][:user] do
  action :create
  comment "Plone User"
  gid node[:plone][:group]
  home node[:plone][:home]
  shell "/bin/bash"
  supports :manage_home => true
end

# Create Plone virtualenv.
python_virtualenv "#{node[:plone][:home]}/venv" do
  owner node[:plone][:user]
  group node[:plone][:group]
  interpreter "python2.7"
  action :create
end
