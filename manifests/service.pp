# == Class profile_apache::service
#
# This class is meant to be called from profile_apache.
# It ensure the service is running.
#
class profile_apache::service {

  service { $::profile_apache::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
