# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  include nfs::client
  # install packages
  ensure_packages( $::profile_apache::packages )

  # create logpath
  $logpath = dirname($::profile_apache::access_log_file)
  exec { $logpath:
    # mode? uid/gid? you decide...
    command => "/bin/mkdir -p ${logpath}",
    creates => $logpath,
  }


  class { 'apache':
    default_vhost          => false,
    mpm_module             => 'prefork',
    root_directory_options => $::profile_apache::root_directory_options,
    require                => Exec[ $logpath ],
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }


}
