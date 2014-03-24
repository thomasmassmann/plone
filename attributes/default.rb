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
default[:plone][:home] = "/home/plone"

# Basic buildout settings used by client and server.
default[:plone][:environment_vars] = [
    "zope_i18n_compile_mo_files true",
    "PYTHON_EGG_CACHE ${buildout:directory}/var/.python-eggs",
    "PYTHONHASHSEED random",
    "#    TZ US/Eastern",
    "#    zope_i18n_allowed_languages en es de fr",
]
default[:plone][:extensions] = [
    "buildout.dumppickedversions",
    "buildout.sanitycheck",
]
default[:plone][:find_links] = [
    "http://dist.plone.org",
    "http://download.zope.org/ppix/",
    "http://download.zope.org/distribution/",
    "http://effbot.org/downloads",
]
default[:plone][:initial_password] = "admin"
default[:plone][:initial_user] = "admin"
default[:plone][:newest] = false
default[:plone][:prefer_final] = true
default[:plone][:unzip] = true
default[:plone][:version] = "4.3"

# Backup settings.
default[:plone][:backups][:enabled] = true
default[:plone][:backups][:directory] = "/var/backups/Plone"
default[:plone][:backups][:minute] = "5"
default[:plone][:backups][:hour] = "1"
default[:plone][:backups][:keep] = "2"
default[:plone][:backups][:keep_blob_days] = "14"

# Packing settings.
default[:plone][:pack][:enabled] = true
default[:plone][:pack][:minute] = "5"
default[:plone][:pack][:hour] = "0"
default[:plone][:pack][:weekday] = "1"

# Plone Hosting settings.
default[:plone][:vhost_data_bag] = "plone_vhosts"
