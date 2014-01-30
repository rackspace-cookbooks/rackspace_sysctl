# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

describe 'rackspace_sysctl::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['rackspace_sysctl']['config']['vm.swappiness'] = 10
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

    # see converge above for sample values I'm testing for
    expect(chef_run)
      .to create_template("/etc/sysctl.d/50-chef-attributes-vm.swapiness.conf")
      .with_owner('root')
      .with_group('root')
      .with_mode(0644)
  end

  it 'populate config template with correct values' do
    expect(chef_run)
      .to render_file('/etc/sysctl.d/50-chef-attributes-vm.swapiness.conf')
      .with_content('vm.swapiness = 10')
  end

  it 'make sure it runs sysctl -p' do
    expect(chef_run.execute('sysctl -p'))
  end
end
