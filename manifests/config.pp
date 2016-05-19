# == Class profile_apache::config
#
# This class is called from profile_apache for service config.
#
class profile_apache::config {

  apache::vhost { "${::profile_apache::vhost} non-ssl":
    servername      => $::profile_apache::vhost,
    port            => '80',
    docroot         => $::profile_apache::docroot,
    redirect_status => 'permanent',
    redirect_dest   => "https:://${::profile_apache::vhost}/",
  }

  apache::vhost { "${::profile_apache::vhost} ssl":
    servername => $::profile_apache::vhost,
    port       => '443',
    docroot    => $::profile_apache::ssl_docroot,
    ssl        => true,
  }

  if $profile_apache::nfs_address != undef {
#    mount { $profile_apache::nfs_mountpoint:
#      ensure  => 'mounted',
#      device  => "${::profile_apache::nfs_address}:/mnt/nfs",
#      fstype  => 'nfs',
#      options => 'intr,soft',
#      atboot  => true,
#    }

    nfs::client::mount { $profile_apache::nfs_mountpoint:
      server  => $profile_apache::nfs_address,
      share   => $profile_apache::nfs_mountpoint,
      options => 'intr,soft',
      atboot  => true,
    }
  }
  else {
    file { $profile_apache::nfs_mountpoint:
      ensure => directory,
    }
  }
}
