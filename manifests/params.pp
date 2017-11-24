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
  $vhost = $::fqdn
  $docroot = '/home/notarisdossier/application/current/frontends/office/public/'
  $php5_packages = ['pdftk','php5-common','php5-cli','php5-mcrypt','php5-imagick','php5-curl','php5-gd','php5-imap', 'php-pear', 'php5-dev',
  'php5-xsl','dnsutils','php5-mysql','libapache2-mod-php5', 'fop', 'imagemagick', 'dnsutils', 'curl', 'graphviz', 'redis-tools']
  $php7_packages = ['libapache2-mod-php','pdftk','dnsutils','fop', 'imagemagick', 'dnsutils', 'curl', 'php-pear']
  $monitor_address = $::monitor_address
  $nfs_address = $::nfs_address
  $db_address = $::db_address
  $serveradmin = 'webmaster@notarisdossier.nl'
  $root_directory_options = [ 'FollowSymLinks']
  $scriptalias = '/cgi-bin/ /usr/lib/cgi-bin/'
  $log_level = 'info'
  $logroot = '/home/notarisdossier/vhostlog/'
  $error_log_file = 'pro.notarisdossier.nl.log'
  $access_log_file = 'pro.notarisdossier.nl.ssl_access.log'
  # use undef ssl setting for default, use hieradata to distribute production keys
  $ssl_cert = undef
  $ssl_key = undef
  $ext_lb_fqdn = $::ext_lb_fqdn
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
      if $::operatingsystemrelease == '16.04' {
        $packages = $php7_packages
      } else {
        $packages = $php5_packages
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
