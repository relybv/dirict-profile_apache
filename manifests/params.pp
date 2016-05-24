# == Class profile_apache::params
#
# This class is meant to be called from profile_apache.
# It sets variables according to platform.
#
class profile_apache::params {
  $vhost = $::fqdn
  $docroot = '/var/www'
  $ssl_docroot = "${docroot}/ssl"
  $php_packages = ['pdftk','php5-common','php5-cli','php5-mcrypt','php5-imagick','php5-curl','php5-gd','php5-imap','php5-xsl','php5-xdebug','php5-mysql','libapache2-mod-php5', 'fop']
  $monitor_address = $::monitor_address
  $nfs_address = $::nfs_address
  $nfs_mountpoint = '/mnt/templates'
  $serveradmin            = 'webmaster@notarisdossier.nl'
  $root_directory_options = [ 'FollowSymLinks', 'AllowOverride all']
  $scriptalias            = '/cgi-bin/ /usr/lib/cgi-bin/'
  $log_level              = 'warn'
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
