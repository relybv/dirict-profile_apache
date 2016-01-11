# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  package { $::profile_apache::package_name:
    ensure => present,
  }
}
