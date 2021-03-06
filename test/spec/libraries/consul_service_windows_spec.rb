require 'spec_helper'
require_relative '../../../libraries/consul_service'
require_relative '../../../libraries/consul_service_windows'

describe ConsulCookbook::Resource::ConsulService do
  step_into(:consul_service)
  let(:chefspec_options) { { platform: 'windows', version: '2012R2' } }
  let(:shellout) { double('shellout') }

  context 'with default properties' do
    before do
      allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)
      allow(shellout).to receive(:live_stream)
      allow(shellout).to receive(:live_stream=)
      allow(shellout).to receive(:error!)
      allow(shellout).to receive(:stderr)
      allow(shellout).to receive(:run_command)
      allow(shellout).to receive(:exitstatus)
      allow(shellout).to receive(:stdout).and_return("Consul v0.6.0\nConsul Protocol: 3 (Understands back to: 1)\n")

      # Stub admin_user method since we are testing a Windows host via Linux
      # Fixed in https://github.com/poise/poise/commit/2f42850c82e295af279d060155bcd5c7ebb31d6a but not released yet
      allow(Poise::Utils::Win32).to receive(:admin_user).and_return('Administrator')
    end

    recipe 'consul::default'

    it do
      skip('Add poise inversion system to consul_service otherwise windows tests will not pass')
      is_expected.to create_directory('C:\Program Files\consul\conf.d')
    end

    it do
      skip('Add poise inversion system to consul_service otherwise windows tests will not pass')
      is_expected.to create_directory('C:\Program Files\consul\data')
    end

    it do
      skip('Add poise inversion system to consul_service otherwise windows tests will not pass')
      expect(chef_run).to install_nssm('consul').with(
        program: 'C:\Program Files\consul\0.7.1\consul.exe',
        args: 'agent -config-file="""C:\Program Files\consul\consul.json""" -config-dir="""C:\Program Files\consul\conf.d"""'
      )
    end
  end
end
