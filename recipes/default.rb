#
# Cookbook Name:: sysctl
# Recipe:: default
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 2012, Societe Publica.
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

# TODO(Youscribe) change this by something more "clean".
execute 'remove old files' do
  command 'rm --force /etc/sysctl.d/50-chef-attributes.conf'
  action :run
end

# redhat supports sysctl.d but doesn't create it by default
directory '/etc/sysctl.d' do
  owner 'root'
  group 'root'
  mode '755'
end

# pass config hash to template
template '/etc/sysctl.d/50-chef-attributes.conf' do
  source 'sysctl.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables('instructions' => node['rackspace_sysctl']['config'])
  notifies :run, 'execute[sysctl-runfiles]'
end

# only run when notified
execute 'sysctl-runfiles' do
  command '/bin/true' # when no conf files, need a default command
  Dir.glob('/etc/sysctl.d/*.conf').each do |file|
    command  "sysctl -p #{file}"
  end
  action :nothing
end



rackspace_sysctl 'vm.swappiness' do
  value '99'
end

rackspace_sysctl_multi 'awesome' do
  instructions 'vm.swappiness' => '50', 'kernel.sysrq' => '1'
end
