# == Class profile_apache::params
#
# This class is meant to be called from profile_apache.
# It sets variables according to platform.
#
class profile_apache::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'profile_apache'
      $service_name = 'profile_apache'
    }
    'RedHat', 'Amazon': {
      $package_name = 'profile_apache'
      $service_name = 'profile_apache'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
