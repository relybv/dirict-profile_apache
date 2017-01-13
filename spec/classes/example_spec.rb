require 'spec_helper'

describe 'profile_apache' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir => "/foo",
            :monitor_address => "localhost",
            :nfs_address=> "localhost",
          })
        end

        context "profile_apache class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profile_apache') }
          it { is_expected.to contain_class('profile_apache::install') }
          it { is_expected.to contain_class('profile_apache::config') }
          it { is_expected.to contain_class('profile_apache::params') }
          it { is_expected.to contain_class('profile_apache::service') }
          it { is_expected.to contain_class('apache') }

          it { is_expected.to contain_package('pdftk') }
          it { is_expected.to contain_package('php5-common') }
          it { is_expected.to contain_package('php5-cli') }
          it { is_expected.to contain_package('php5-mcrypt') }
          it { is_expected.to contain_package('php5-imagick') }
          it { is_expected.to contain_package('php5-curl') }
          it { is_expected.to contain_package('php5-gd') }
          it { is_expected.to contain_package('php5-imap') }
          it { is_expected.to contain_package('php5-xsl') }
          it { is_expected.to contain_package('php5-mysql') }
          it { is_expected.to contain_package('libapache2-mod-php5') }
          it { is_expected.to contain_package('fop') }
          it { is_expected.to contain_package('dnsutils') }

          it { is_expected.to contain_apache__vhost('foo.example.com non-ssl').with( 'ssl' => false ) }
          it { is_expected.to contain_apache__vhost('foo.example.com ssl').with( 'ssl' => true ) }

          it { is_expected.to contain_apache__listen('80') }  
          it { is_expected.to contain_apache__listen('443') }

        end
      end
    end
  end
end
