# == Class profile_apache::params
#
# This class is meant to be called from profile_apache.
# It sets variables according to platform.
#
class profile_apache::params {
  $vhost = $::fqdn
  $docroot = '/home/notarisdossier/application/current/frontends/office/public/'
  $php_packages = ['pdftk','php5-common','php5-cli','php5-mcrypt','php5-imagick','php5-curl','php5-gd','php5-imap','php5-xsl','php5-xdebug','php5-mysql','libapache2-mod-php5', 'fop']
  $monitor_address = $::monitor_address
  $nfs_address = $::nfs_address
  $nfs_mountpoint = '/mnt/templates'
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
  $ssl_chain = undef

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
