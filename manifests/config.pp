# == Class profile_apache::config
#
# This class is called from profile_apache for service config.
#
class profile_apache::config {

  apache::vhost { "${::profile_apache::vhost} non-ssl":
    servername      => $::profile_apache::vhost,
    port            => '80',
    docroot         => $::profile_apache::docroot,
    redirect_status => "permanent-${::profile_apache::vhost}",
    redirect_dest   => "https://${::profile_apache::ext_lb_fqdn}/",
  }

  apache::vhost { "${::profile_apache::vhost} ssl":
    servername           => $::profile_apache::vhost,
    serveradmin          => $::profile_apache::serveradmin,
    scriptalias          => $::profile_apache::scriptalias,
    log_level            => $::profile_apache::log_level,
    error_log_file       => $::profile_apache::error_log_file,
    access_log_file      => $::profile_apache::access_log_file,
    port                 => '443',
    docroot              => $::profile_apache::docroot,
    logroot              => $::profile_apache::logroot,
    ssl                  => true,
    ssl_honorcipherorder => 'On',
    ssl_cipher           => 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:HIGH:!MD5:!aNULL:!EDH',
    ssl_protocol         => 'All -SSLv2',
    ssl_cert             => $::profile_apache::ssl_cert,
    ssl_key              => $::profile_apache::ssl_key,
    ssl_chain            => $::profile_apache::ssl_chain,
    directories          => [
      { path           => $profile_apache::docroot,
        allow_override => [ 'ALL' ],
        options        => [ 'Indexes','FollowSymLinks','MultiViews' ],
      },
      { path        => '/usr/lib/cgi-bin',
        options     => [ '+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch' ],
        ssl_options => '+StdEnvVars',
      },
      { path        => '\.(cgi|shtml|phtml|php)$',
        provider    => 'filesmatch',
        ssl_options => '+StdEnvVars',
      },
    ],
  }

  file { "${::profile_apache::docroot}/working.html":
    ensure => present,
    content => template('profile_apache/working.html.erb'),
    mode => '0644';
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
