#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Attributes:: zeo
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

# Default settings for the Plone ZEO-Server.
default[:plone][:zeo][:dir] = "#{node[:plone][:home]}/zeo"
default[:plone][:zeo][:custom_ip] = nil
default[:plone][:zeo][:port] = "8100"
default[:plone][:zeo][:versions] = [
    "Cheetah = 2.2.1",
    "Products.DocFinderTab = 1.0.5",
    "ZopeSkel = 2.21.2",
    "collective.recipe.backup = 2.10",
    "plone.recipe.unifiedinstaller = 4.3.1",
    "plone.recipe.command = 1.1",
    "plone.recipe.precompiler = 0.6",
    "zopeskel.dexterity = 1.5.0",
    "zopeskel.diazotheme = 1.0",
]
