# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

describe 'rackspace_sysctl::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['memory']['total'] = 100
      node.set['sysctl']['config']['port'] = '12345'
      node.set['sysctl']['config']['sysctlconf']['-l'] = '127.0.0.1'
    end.converge(described_recipe)
  end

  it '/etc/sysctl.d should exist with permissions and ownership' do
    expect(chef_run)
      .to create_directory('/etc/sysctl.d')
      .with_owner('root')
      .with_group('root')
      .with_mode('755')
  end

  # check config template exists, right modes and owners
  it 'create template files with permissions and ownership' do

    # /etc/sysctl.d/50-chef-attributes-#{f_name}.conf

    if node.attribute?('sysctl')
      node['sysctl'].each do |item|
        f_name = item.first.gsub(' ', '_')

        expect(chef_run)
          .to create_template("/etc/sysctl.d/50-chef-attributes-#{f_name}.conf")
          .with_owner('root')
          .with_group('root')
          .with_mode(0644)
      end
    end
  end

  it 'populate config template with correct values' do
    expect(chef_run)
      .to render_file('/etc/sysctl.conf')
      .with_content('-m 75')
      .with_content('-p 12345')
      .with_content('-l 127.0.0.1')
  end

  it 'make sure it runs sysctl -p' do
    expect(chef_run.execute('sysctl -p'))
  end
end
