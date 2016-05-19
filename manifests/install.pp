# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  # install packages
  ensure_packages( $::profile_apache::packages )

  if ! defined(Package['nfs-common']) {
    package { 'nfs-common':
        ensure => installed,
    }
  }

  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }


}
