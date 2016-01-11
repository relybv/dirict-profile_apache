# == Class profile_apache::rspec_monitor
#
# This class is included from a role for install. It makes rspec acceptance tests available to the monitor system.
#
class profile_apache::rspec_monitor {
  include ::rspec_monitor
  rspec_monitor::add_tests { $module_name: }
}
