# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {

  include nfs::client

  # install packages
  ensure_packages( $::profile_apache::packages )

  # create root and logpath
  $logpath = dirname( "${::profile_apache::logroot}${::profile_apache::error_log_file}" )
  $rootpath = dirname( $::profile_apache::docroot )

  exec { $logpath:
    # mode? uid/gid? you decide...
    command => "/bin/mkdir -p ${logpath}",
    creates => $logpath,
  }

  exec { $rootpath:
    # mode? uid/gid? you decide...
    command => "/bin/mkdir -p ${rootpath}",
    creates => $rootpath,
  }

  # create certificate path only if certificate is defined
  if ($profile_apache::ssl_cert != undef) and ($profile_apache::ssl_cert != '') {
    $certpath = dirname($::profile_apache::ssl_cert)
    exec { $certpath:
      command => "/bin/mkdir -p ${certpath}",
      creates => $certpath,
    }
  }

  class { 'apache':
    default_vhost          => false,
    mpm_module             => 'prefork',
    root_directory_options => $::profile_apache::root_directory_options,
    require                => Exec[ $logpath ],
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::ssl':
    ssl_compression => false,
  }

}
