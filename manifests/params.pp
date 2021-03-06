# == Class profile_apache::params
#
# This class is meant to be called from profile_apache.
# It sets variables according to platform.
#
class profile_apache::params {
  $office_server_name = hiera('profile_apache::office_server_name', $::fqdn)
  $office_server_alias = hiera('profile_apache::office_server_alias', "rely01-${::hostname}.notarisdossier.nl" )
  $office_document_root = hiera('profile_apache::office_document_root', '/home/notarisdossier/application/current/frontends/office/public/')
  $office_error_log = hiera('profile_apache::office_error_log', 'office_error.log')
  $office_access_log = hiera('profile_apache::office_access_log', 'office_access.log')

  $client_server_name = hiera('profile_apache::client_server_name', "wildcard.${::domain}")
  $client_server_alias = hiera('profile_apache::client_server_alias', '*.notarisdossier.nl' )
  $client_document_root = hiera('profile_apache::client_document_root', '/home/notarisdossier/application/current/frontends/client/public/')
  $client_error_log = hiera('profile_apache::client_error_log', 'client_error.log')
  $client_access_log = hiera('profile_apache::client_access_log', 'client_access.log')


  $zendversion = '1.10.8'
  $phpversion = '7.0' # change to 5.0 / 7.0 7.1
  $vhost = $::fqdn
  $docroot = '/home/notarisdossier/application/current/frontends/office/public/'
  $php5_packages = ['pdftk','php5-common','php5-cli','php5-mcrypt','php5-imagick','php5-curl','php5-gd','php5-imap','php-pear',
  'php5-dev','build-essential','php5-xsl','dnsutils','php5-mysql','libapache2-mod-php5','fop','imagemagick','dnsutils','curl',
  'graphviz','redis-tools','poppler-utils']
  $php70_packages = ['php','libapache2-mod-php','mysql-client','php-bz2','php-cli','php-curl','php-gd','php-imagick','php-imap',
  'php-libsodium','php-mbstring','php-mcrypt','php-mysql','php-soap','php-xml','php-zip','pdftk','graphviz','fop','imagemagick',
  'php-redis','redis-tools','poppler-utils']
  $php71_packages = ['php7.1','php7.1-fpm','php7.1-common','php7.1-cli','pdftk','dnsutils','fop','imagemagick','dnsutils','curl',
  'php-pear','build-essential','php7.1-dev','php7.1-xml','libsodium-dev','php7.1-bz2','php7.1-curl','php7.1-gd','php-imagick',
  'php7.1-imap','php-sodium','php7.1-mbstring','php7.1-mcrypt','php7.1-soap','php7.1-zip','php7.1-mysql','mysql-client','php-redis',
  'redis-tools','poppler-utils']
  $monitor_address = $::monitor_address
  $nfs_address = $::nfs_address
  $db_address = $::db_address
  $serveradmin = 'webmaster@notarisdossier.nl'
  $root_directory_options = [ 'FollowSymLinks']
  $scriptalias = '/cgi-bin/ /usr/lib/cgi-bin/'
  $log_level = 'warn'
  $logroot = '/home/notarisdossier/vhostlog/'
  $error_log_file = 'pro.notarisdossier.nl.log'
  $access_log_file = 'pro.notarisdossier.nl.ssl_access.log'
  # use undef ssl setting for default, use hieradata to distribute production keys
  $ssl_cert = undef
  $ssl_key = undef
  $ext_lb_fqdn = $::ext_lb_fqdn
  $deploy_key = hiera('deploy_key', 'ssh-rsa')
  $db_password = hiera('db_password', 'welkom01')
  $dirict_username = 'dirict'
  $dirict_password = 'welkom01'
  $azure_account = ''
  $azure_access_key = ''
  $webservices_dirict_username = 'dirict'
  $webservices_dirict_password = 'welkom01'
  $webdav_dirict_templates_password = 'welkom01'

  case $::osfamily {
    'Debian': {
      if $::operatingsystemmajrelease == '9' {
        case $phpversion {
          '7.0': { $packages = $php70_packages }
          '7.1': {
            $packages = $php71_packages
            $php_repo_location = 'https://packages.sury.org/php'
            $php_repo_release = 'stretch'
            $php_repo_id = 'DF3D585DB8F0EB658690A554AC0E47584A7A714D'
            $php_repo_source = 'https://packages.sury.org/php/apt.gpg'
          }
          default: { fail("PHP version ${phpversion} on this os version not supported") }
        }
        $php_repo_location = 'https://packages.sury.org/php'
        $php_repo_release = 'stretch'
        $php_repo_id = 'DF3D585DB8F0EB658690A554AC0E47584A7A714D'
        $php_repo_source = 'https://packages.sury.org/php/apt.gpg'
      } else {
        $packages = $php5_packages
        $php_repo_location = 'http://packages.dotdeb.org'
        $php_repo_release = 'wheezy-php56'
        $php_repo_id = '7E3F070089DF5277'
        $php_repo_source = 'http://www.dotdeb.org/dotdeb.gpg'
      }
    }
    'RedHat', 'Amazon': {
      $packages = $php5_packages
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
