require 'spec_helper'

describe 'profile_apache' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir => "/foo",
            :monitor_address => "localhost",
            :nfs_address => "localhost",
            :db_address => "localhost",
            :ext_lb_fqdn => "localhost",
            :win_address => "localhost",
            :ssl_cert_path => "/etc/ssl/certs/ssl-cert-default.pem",
            :ssl_key_path => "/etc/ssl/private/ssl-cert-default.key",
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

          case facts[:operatingsystemrelease]
          when '16.04'
            it { is_expected.to contain_package('libapache2-mod-php') }
            it { is_expected.to contain_package('pdftk') }
            it { is_expected.to contain_package('fop') }
            it { is_expected.to contain_package('dnsutils') }
            it { is_expected.to contain_package('imagemagick') }
            it { is_expected.to contain_package('curl') }
          else
            it { is_expected.to contain_apt__source('php56') }
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
            it { is_expected.to contain_package('pdftk') }
            it { is_expected.to contain_package('fop') }
            it { is_expected.to contain_package('dnsutils') }
            it { is_expected.to contain_package('imagemagick') }
            it { is_expected.to contain_package('curl') }
            it { is_expected.to contain_package('graphviz') }
            it { is_expected.to contain_package('php-pear') }
            it { is_expected.to contain_package('php5-dev') }
            it { is_expected.to contain_package('redis-tools') }
          end
          it { is_expected.to contain_file('/home/notarisdossier/.ssh/authorized_keys') }
          it { is_expected.to contain_file('/home/notarisdossier/.ssh') }
          it { is_expected.to contain_file('/home/notarisdossier/application/current') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy/frontends/client') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy/frontends/office/public/working.html') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy/frontends/office/public') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy/frontends/office') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy/frontends') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases/dummy') }
          it { is_expected.to contain_file('/home/notarisdossier/application/releases') }
          it { is_expected.to contain_file('/home/notarisdossier/application') }
          it { is_expected.to contain_file('/home/notarisdossier/config/local.php') }
          it { is_expected.to contain_file('/home/notarisdossier/redirect/index.html') }
          it { is_expected.to contain_file('/home/notarisdossier/redirect') }
          it { is_expected.to contain_file('/home/notarisdossier/sessions') }
          it { is_expected.to contain_file('/home/notarisdossier') }

          it { is_expected.to contain_File_line('upload_max_filesize') }
          it { is_expected.to contain_File_line('phpapache2-libsodium') }
          it { is_expected.to contain_File_line('phpapache2-redis') }
          it { is_expected.to contain_File_line('phpcli-libsodium') }
          it { is_expected.to contain_File_line('session-save-handler') }
          it { is_expected.to contain_File_line('session-save-path') }

          it { is_expected.to contain_group('notarisdossier') }
          it { is_expected.to contain_user('notarisdossier') }

          it { is_expected.to contain_exec('install-redis') }
          it { is_expected.to contain_exec('mv-zf') }
          it { is_expected.to contain_exec('tar-zf') }
          it { is_expected.to contain_exec('/home/notarisdossier/vhostlog') }
          it { is_expected.to contain_exec('wget-https://packages.zendframework.com/releases/ZendFramework-1.10.8/ZendFramework-1.10.8.tar.gz') }
          it { is_expected.to contain_exec('copy-libsodium') }
          it { is_expected.to contain_file('libsodium.so') }
          it { is_expected.to contain_file('libsodium.so.18') }

          it { is_expected.to contain_wget__fetch('http://www.dirict.nl/downloads/Comodo_PositiveSSL_bundle.crt') }

          it { is_expected.to contain_apache__vhost('wildcard.example.com' ) }
          it { is_expected.to contain_apache__vhost('foo.example.com') }
          it { is_expected.to contain_apache__vhost('foo.example.com non-ssl').with( 'ssl' => false ) }
          it { is_expected.to contain_apache__vhost('foo.example.com ssl').with( 'ssl' => true ) }

          it { is_expected.to contain_apache__listen('80') }  
          it { is_expected.to contain_apache__listen('443') }

          it { is_expected.to contain_nfs__client__mount('/home/notarisdossier/config') }
          it { is_expected.to contain_nfs__client__mount('/home/notarisdossier/errors') }
          it { is_expected.to contain_nfs__client__mount('/home/notarisdossier/logs') }
          it { is_expected.to contain_nfs__client__mount('/home/notarisdossier/office-templates') }

          it { is_expected.to contain_rsyslog__imfile('foo.example.com-access') }
          it { is_expected.to contain_rsyslog__imfile('foo.example.com-error') }
          it { is_expected.to contain_rsyslog__imfile('wildcard.example.com-access') }
          it { is_expected.to contain_rsyslog__imfile('wildcard.example.com-error') }

          it { is_expected.to contain_notify('addr from init: monitor localhost, nfs localhost, db localhost, win localhost') }

        end
      end
    end
  end
end
