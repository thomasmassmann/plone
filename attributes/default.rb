#
# Author:: Thomas Massmann <thomas@propertyshelf.com>
# Cookbook Name:: plone
# Attributes:: default
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

# General settings.
default[:plone][:user] = "plone"
default[:plone][:group] = "plone"
default[:plone][:home] = "/home/#{node[:plone][:user]}"

# ZEO Server settings.
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
default[:plone][:zeo][:role] = "plone_zeo"

# Plone settings.
default[:plone][:port] = "8080"
default[:plone][:app_name] = "Plone"
default[:plone][:app_home] = "#{node[:plone][:home]}/#{node[:plone][:app_name]}"
default[:plone][:version] = "4.3"
default[:plone][:newest] = false
default[:plone][:prefer_final] = true
default[:plone][:unzip] = true
default[:plone][:find_links] = [
    "http://dist.plone.org",
    "http://download.zope.org/ppix/",
    "http://download.zope.org/distribution/",
    "http://effbot.org/downloads",
]
default[:plone][:extensions] = [
    "buildout.dumppickedversions",
    "buildout.sanitycheck",
]
default[:plone][:environmen_vars] = [
    "zope_i18n_compile_mo_files true",
    "PYTHON_EGG_CACHE ${buildout:directory}/var/.python-eggs",
    "PYTHONHASHSEED random",
    "#    TZ US/Eastern",
    "#    zope_i18n_allowed_languages en es de fr",
]
default[:plone][:initial_user] = "admin"
default[:plone][:initial_password] = "admin"
default[:plone][:eggs] = []
default[:plone][:zcml] = []

# Backup settings.
default[:plone][:backups][:enabled] = true
default[:plone][:backups][:directory] = "/var/backups/#{node[:plone][:app_name]}"
default[:plone][:backups][:minute] = "5"
default[:plone][:backups][:hour] = "1"

# Packing settings.
default[:plone][:pack][:enabled] = true
default[:plone][:pack][:minute] = "5"
default[:plone][:pack][:hour] = "0"
default[:plone][:pack][:weekday] = "1"

# Plone Hosting settings.
default[:plone][:vhost_data_bag] = "plone_vhosts"

# Development packages.
default[:plone][:dev][:enabled] = false
default[:plone][:dev][:sources] = []
