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
    servername      => $::profile_apache::vhost,
    serveradmin     => $::profile_apache::serveradmin,
    scriptalias     => $::profile_apache::scriptalias,
    log_level       => $::profile_apache::log_level,
    error_log_file  => $::profile_apache::error_log_file,
    access_log_file => $::profile_apache::access_log_file,
    port            => '443',
    docroot         => $::profile_apache::docroot,
    logroot         => $::profile_apache::logroot,
    ssl             => true,
    directories     => [
      { path     => $profile_apache::docroot,
        override => [ 'all' ],
        options  => [ 'Indexes','FollowSymLinks','MultiViews' ],
      },
      { path     => '/usr/lib/cgi-bin',
        override => [  'None' ],
        options  => [ '+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch' ],
      },
    ],
  }

  if $profile_apache::nfs_address != undef {
    nfs::client::mount { $profile_apache::nfs_mountpoint:
      server  => $profile_apache::nfs_address,
      share   => '/mnt/nfs',
      options => 'hard',
      atboot  => true,
    }
  }
  else {
    file { $profile_apache::nfs_mountpoint:
      ensure => directory,
    }
  }
}
