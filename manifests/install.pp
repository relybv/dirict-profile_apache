# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  include nfs::client
  # install packages
  ensure_packages( $::profile_apache::packages )

  class { 'apache':
    default_vhost          => false,
    mpm_module             => 'prefork',
    root_directory_options => $::profile_apache::root_directory_options,
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }


}
