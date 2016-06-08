# == Class profile_apache::params
#
# This class is meant to be called from profile_apache.
# It sets variables according to platform.
#
class profile_apache::params {
  $zendversion = '1.10.8'
  $vhost = $::fqdn
  $docroot = '/home/notarisdossier/application/current/frontends/office/public/'
  $php_packages = ['pdftk','php5-common','php5-cli','php5-mcrypt','php5-imagick','php5-curl','php5-gd','php5-imap','php5-xsl','dnsutils','php5-mysql','libapache2-mod-php5', 'fop']
  $monitor_address = $::monitor_address
  $nfs_address = $::nfs_address
  $db_address = 'localhost'
  $serveradmin = 'webmaster@notarisdossier.nl'
  $root_directory_options = [ 'FollowSymLinks']
  $scriptalias = '/cgi-bin/ /usr/lib/cgi-bin/'
  $log_level = 'warn'
  $logroot = '/home/notarisdossier'
  $error_log_file = '/vhostlog/pro.notarisdossier.nl.log'
  $access_log_file = '/home/notarisdossier/vhostlog/pro.notarisdossier.nl.ssl_access.log'
  # use undef ssl setting for default, use hieradata to distribute production keys
  $ssl_cert = undef
  $ssl_key = undef
  $ext_lb_fqdn = $::ext_lb_fqdn
  $db_password = 'changeme'
  $dirict_username = 'dirict'
  $dirict_password = 'changeme'
  $azure_account = ''
  $azure_access_key = ''
  $webservices_dirict_username = 'dirict'
  $webservices_dirict_password = 'changeme'
  $webdav_dirict_templates_password = 'changeme'

  case $::osfamily {
    'Debian': {
      $packages = $php_packages
    }
    'RedHat', 'Amazon': {
      $packages = $php_packages
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
