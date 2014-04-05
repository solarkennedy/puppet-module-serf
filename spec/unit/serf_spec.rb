require 'spec_helper'

$config_hash_param_value = {
  "role" => "load-balancer",
  "event_handlers" => [
    "handle.sh",
    "user:deploy=deploy.sh"
  ]
}

describe 'serf', :type => :class do
  let(:params) {{
    :version      => '0.4.1',
    :bin_dir      => '/usr/local/bin',
    :config_hash  => $config_hash_param_value,
  }}

  context 'on linux' do
    let(:facts) {{
      :kernel       => 'Linux',
      :architecture => 'i386',
      :osfamily     => 'redhat'
    }}
    context '32-bit by default' do
      let(:facts) {{
        :kernel       => 'Linux',
        :architecture => 'i386',
        :osfamily     => 'redhat'
      }}
      it 'should download serf' do
        should contain_staging__file('serf.zip').with_source('https://dl.bintray.com/mitchellh/serf/0.4.1_linux_386.zip')
      end
      it 'should extract serf' do
        should contain_staging__extract('serf.zip').with({
          :target  => '/usr/local/bin',
          :creates => '/usr/local/bin/serf',
        })
      end
    end
    context '64-bit by default' do
      let(:facts) {{
        :kernel       => 'Linux',
        :architecture => 'x86_64',
        :osfamily     => 'redhat'
      }}
      it 'should download serf' do
        should contain_staging__file('serf.zip').with_source('https://dl.bintray.com/mitchellh/serf/0.4.1_linux_amd64.zip')
      end
      it 'should extract serf' do
        should contain_staging__extract('serf.zip').with({
          :target  => '/usr/local/bin',
          :creates => '/usr/local/bin/serf',
        })
      end
    end
    context 'unsupported architecture' do
      let(:facts) {{
        :kernel       => 'Linux',
        :architecture => 'fuuuu',
        :osfamily     => 'redhat'
      }}
      it 'should fail with an error' do
        expect { subject }.to raise_error(Puppet::Error,/Unsupported kernel architecture \"fuuuu\"/)
      end
    end
    context 'When requesting to install via a package with defaults' do
      let(:params) {{
        :version      => '0.4.1',
        :bin_dir      => '/usr/local/bin',
        :config_hash  => $config_hash_param_value,
        :install_method => 'package'
      }}
      it { should contain_package('serf').with(:ensure => 'present') }
    end
    context 'When requesting to install via a custom package and version' do
      let(:params) {{
        :version        => '0.4.1',
        :bin_dir        => '/usr/local/bin',
        :config_hash    => $config_hash_param_value,
        :install_method => 'package',
        :package_ensure => 'specific_release',
        :package_name   => 'custom_serf_package'
      }}
      it { should contain_package('custom_serf_package').with(:ensure => 'specific_release') }
    end
    it 'should manage configs' do
      should contain_file('config.json').with({
        :path => '/etc/serf/config.json',
      })
    end
    it 'should manage event handler script dir' do
      should contain_file('/etc/serf/handlers')
    end
    it 'should manage serf agent as a service' do
      should contain_file('/etc/init.d/serf').with({
        :path => '/etc/init.d/serf',
        :mode => '0755',
      })
      should contain_service('serf').with({
        :enable   => true,
        :ensure   => 'running',
      })
    end
  end
  context 'on unsupported os' do
    let(:facts) {{ :kernel => 'fuuuu' }}
    it 'should fail with an error' do
      expect { subject }.to raise_error(Puppet::Error,/Unsupported kernel \"fuuuu\"/)
    end
  end
end
