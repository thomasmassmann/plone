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

deploy_revision "/opt/zeoserver" do
  repo "https://github.com/propertyshelf/buildout_zeoserver.git"
  revision "master"
  create_dirs_before_symlink []
  symlink_before_migrate({})
  symlinks({})
  action :force_deploy
end
