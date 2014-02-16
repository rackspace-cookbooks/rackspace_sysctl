require 'spec_helper'

# these will actually verify that the test cookbook set these params
describe command('sysctl -a') do
  it { should return_stdout(/vm.swappiness = 50/) }
  it { should return_stdout(/kernel.panic_on_oops = 1/) }
  it { should return_stdout(/kernel.sysrq = 1/) }
end
