#
# Cookbook Name:: plone
# Recipe:: commons
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

# Install and configure python, python-dev, pip and virtualenv.
include_recipe "python::default"

# This package is currently necessary for the user resource (password functions).
package "libshadow-ruby1.8" do
  action :install
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
  supports :manage_home => true
end
