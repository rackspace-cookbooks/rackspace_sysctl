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
  command 'rm --force /etc/sysctl.d/50-chef-attributes-*.conf'
  action :run
end

# redhat supports sysctl.d but doesn't create it by default
directory '/etc/sysctl.d' do
  owner 'root'
  group 'root'
  mode '755'
end

# due to the fact that the template has to support a large list
# of parameters in one file, it must accept a config hash, but this invocation
# below only supplies a single config entry. |variable| becomes an array, so
# I have had to repack it in 'pair' before passing it back to the template
node['rackspace_sysctl']['config'].each do |variable|
  f_name = variable.first.gsub(' ', '_')
  pair = { variable[0] => variable[1] }
  template "/etc/sysctl.d/50-chef-attributes-#{f_name}.conf" do
    source 'sysctl.conf.erb'
    mode '0644'
    owner 'root'
    group 'root'
    variables('name' => variable.first, 'instructions' => pair)
    notifies :run, 'execute[sysctl-runfiles]'
  end
end

# only run when notified
execute 'sysctl-runfiles' do
  Dir.glob('/etc/sysctl.d/*.conf').each do |file|
    command  "sysctl -p #{file}"
  end
  action :nothing
end
