

# just some sample things to change from the defaults
rackspace_sysctl 'kernel.panic_on_oops' do
  value '1'
end

rackspace_sysctl_multi 'awesome' do
  instructions 'vm.swappiness' => '50', 'kernel.sysrq' => '1'
end
