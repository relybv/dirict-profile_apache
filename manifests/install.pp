# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  package {  $::profile_apache::packages:
    ensure => present,
  }

  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }


}
