# == Class profile_apache::config
#
# This class is called from profile_apache for service config.
#
class profile_apache::config {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  notice ("client_server_name is: ${::profile_apache::client_server_name}")

  # php settings
  file_line { 'upload_max_filesize':
    ensure => present,
    path   => '/etc/php5/apache2/php.ini',
    line   => 'upload_max_filesize = 16M',
    match  => '^upload_max_filesize = 2M',
  }

  # create group
  group { 'notarisdossier':
    ensure => present,
    gid    => 2000,
  }

  # create user
  user { 'notarisdossier':
    ensure => present,
    shell  => '/bin/bash',
    uid    => 2000,
    gid    => 'notarisdossier',
  }

  # set owner
  file { '/home/notarisdossier':
    ensure => directory,
    owner  => 'notarisdossier',
    group  => 'notarisdossier',
  }

  # create ssh dirs and file
  file { '/home/notarisdossier/.ssh':
    ensure => directory,
    owner  => 'notarisdossier',
    group  => 'notarisdossier',
    mode   => '0600',
  }

  # create ssh keys
  $ssh_keys = hiera('ssh_keys', {} )
  create_resources('profile_apache::notarisdossier_user_keys', $ssh_keys)

  file { '/home/notarisdossier/.ssh/authorized_keys':
    ensure  => present,
    owner   => 'notarisdossier',
    group   => 'notarisdossier',
    mode    => '0600',
    require => File['/home/notarisdossier/.ssh'],
  }

  file { '/home/notarisdossier/sessions':
    ensure  => directory,
    owner   => 'notarisdossier',
    group   => 'notarisdossier',
    mode    => '0777',
    require => User['notarisdossier'],
  }

  # create dummy application directory
  file { [ '/home/notarisdossier/application', '/home/notarisdossier/application/releases',
  '/home/notarisdossier/application/releases/dummy', '/home/notarisdossier/application/releases/dummy/frontends',
  '/home/notarisdossier/application/releases/dummy/frontends/office',
  '/home/notarisdossier/application/releases/dummy/frontends/client',
  '/home/notarisdossier/application/releases/dummy/frontends/office/public' ]:
    ensure  => directory,
    owner   => 'notarisdossier',
    group   => 'www-data',
    mode    => '0640',
    require => User['notarisdossier'],
  }

  # redirect vhost directory
  file { '/home/notarisdossier/redirect':
    ensure  => directory,
    owner   => 'notarisdossier',
    group   => 'www-data',
    mode    => '0750',
    require => User['notarisdossier'],
  }

  # enable status page
  class {'::apache::mod::status':}

  # create vhosts
  # redirect vhost
  apache::vhost { "${::profile_apache::vhost} non-ssl":
    servername => $::profile_apache::vhost,
    port       => '80',
    docroot    => '/home/notarisdossier/redirect',
    log_level  => $::profile_apache::log_level,
  }

  # office vhost
  apache::vhost { $::profile_apache::office_server_name:
    servername           => $::profile_apache::office_server_name,
    serveradmin          => $::profile_apache::serveradmin,
    serveraliases        => $::profile_apache::office_server_alias,
    scriptalias          => $::profile_apache::scriptalias,
    log_level            => $::profile_apache::log_level,
    error_log_file       => $::profile_apache::office_error_log,
    access_log_file      => $::profile_apache::office_access_log,
    port                 => '443',
    docroot              => $::profile_apache::office_document_root,
    docroot_owner        => 'notarisdossier',
    docroot_group        => 'www-data',
    logroot              => $::profile_apache::logroot,
    ssl                  => true,
    ssl_honorcipherorder => 'On',
    ssl_cipher           => 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:HIGH:!MD5:!aNULL:!EDH',
    ssl_protocol         => 'All -SSLv2 -SSLv3',
    ssl_cert             => $::profile_apache::install::ssl_cert_path,
    ssl_key              => $::profile_apache::install::ssl_key_path,
    ssl_chain            => '/etc/ssl/certs/Comodo_PositiveSSL_bundle.crt',
    directories          => [
      { path           => $profile_apache::office_document_root,
        allow_override => [ 'ALL' ],
        options        => [ 'Indexes','FollowSymLinks','MultiViews' ],
      },
      { path        => '/usr/lib/cgi-bin',
        options     => [ '+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch' ],
        ssl_options => '+StdEnvVars',
      },
      { path        => '\.(cgi|shTml|phtml|php)$',
        provider    => 'filesmatch',
        ssl_options => '+StdEnvVars',
      },
    ],
  }

  # client vhost
  apache::vhost { $::profile_apache::client_server_name:
    servername           => $::profile_apache::client_server_name,
    serveradmin          => $::profile_apache::serveradmin,
    serveraliases        => $::profile_apache::client_server_alias,
    scriptalias          => $::profile_apache::scriptalias,
    log_level            => $::profile_apache::log_level,
    error_log_file       => $::profile_apache::client_error_log,
    access_log_file      => $::profile_apache::client_access_log,
    port                 => '443',
    docroot              => $::profile_apache::client_document_root,
    docroot_owner        => 'notarisdossier',
    docroot_group        => 'www-data',
    logroot              => $::profile_apache::logroot,
    ssl                  => true,
    ssl_honorcipherorder => 'On',
    ssl_cipher           => 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:HIGH:!MD5:!aNULL:!EDH',
    ssl_protocol         => 'All -SSLv2 -SSLv3',
    ssl_cert             => $::profile_apache::install::ssl_cert_path,
    ssl_key              => $::profile_apache::install::ssl_key_path,
    ssl_chain            => '/etc/ssl/certs/Comodo_PositiveSSL_bundle.crt',
    directories          => [
      { path           => $profile_apache::client_document_root,
        allow_override => [ 'ALL' ],
        options        => [ 'Indexes','FollowSymLinks','MultiViews' ],
      },
      { path        => '/usr/lib/cgi-bin',
        options     => [ '+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch' ],
        ssl_options => '+StdEnvVars',
      },
      { path        => '\.(cgi|shTml|phtml|php)$',
        provider    => 'filesmatch',
        ssl_options => '+StdEnvVars',
      },
    ],
  }

  # org vhost
  apache::vhost { "${::profile_apache::vhost} ssl":
    ensure               => absent,
    servername           => $::profile_apache::vhost,
    serveradmin          => $::profile_apache::serveradmin,
    serveraliases        => [ "rely01-${::hostname}.notarisdossier.nl" ], # rely01-app1.notarisdossier.nl
    scriptalias          => $::profile_apache::scriptalias,
    log_level            => $::profile_apache::log_level,
    error_log_file       => $::profile_apache::error_log_file,
    access_log_file      => $::profile_apache::access_log_file,
    port                 => '443',
    docroot              => $::profile_apache::docroot,
    docroot_owner        => 'notarisdossier',
    docroot_group        => 'www-data',
    logroot              => $::profile_apache::logroot,
    ssl                  => true,
    ssl_honorcipherorder => 'On',
    ssl_cipher           => 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:HIGH:!MD5:!aNULL:!EDH',
    ssl_protocol         => 'All -SSLv2 -SSLv3',
    ssl_cert             => $::profile_apache::install::ssl_cert_path,
    ssl_key              => $::profile_apache::install::ssl_key_path,
    ssl_chain            => '/etc/ssl/certs/Comodo_PositiveSSL_bundle.crt',
    directories          => [
      { path           => $profile_apache::docroot,
        allow_override => [ 'ALL' ],
        options        => [ 'Indexes','FollowSymLinks','MultiViews' ],
      },
      { path        => '/usr/lib/cgi-bin',
        options     => [ '+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch' ],
        ssl_options => '+StdEnvVars',
      },
      { path        => '\.(cgi|shTml|phtml|php)$',
        provider    => 'filesmatch',
        ssl_options => '+StdEnvVars',
      },
    ],
  }

  # install certificate bundle
  wget::fetch { 'http://www.dirict.nl/downloads/Comodo_PositiveSSL_bundle.crt':
    destination => '/etc/ssl/certs/Comodo_PositiveSSL_bundle.crt',
  }

  # configure syslog
  rsyslog::imfile { "${::profile_apache::office_server_name}-error":
    file_name     => "${::profile_apache::logroot}${::profile_apache::office_error_log}",
    file_tag      => $::profile_apache::office_error_log,
    file_facility => 'info',
  }

  rsyslog::imfile { "${::profile_apache::office_server_name}-access":
    file_name     => "${::profile_apache::logroot}${::profile_apache::office_access_log}",
    file_tag      => $::profile_apache::office_access_log,
    file_facility => 'info',
  }

  rsyslog::imfile { "${::profile_apache::client_server_name}-error":
    file_name     => "${::profile_apache::logroot}${::profile_apache::client_error_log}",
    file_tag      => $::profile_apache::client_error_log,
    file_facility => 'info',
  }

  rsyslog::imfile { "${::profile_apache::client_server_name}-access":
    file_name     => "${::profile_apache::logroot}${::profile_apache::client_access_log}",
    file_tag      => $::profile_apache::client_access_log,
    file_facility => 'info',
  }

  # redirect page
  file { '/home/notarisdossier/redirect/index.html':
    ensure  => present,
    content => template('profile_apache/redirect.html.erb'),
    owner   => 'notarisdossier',
    group   => 'www-data',
    mode    => '0640',
  }

  # check working page
  file { '/home/notarisdossier/application/releases/dummy/frontends/office/public/working.html':
    ensure  => present,
    content => template('profile_apache/working.html.erb'),
    owner   => 'notarisdossier',
    group   => 'www-data',
    mode    => '0640',
  }


  if $profile_apache::nfs_address == undef {
    # no nfs server defined
    exec { '/bin/mkdir -p /home/notarisdossier/application/current/frontends/office/public':
      creates => '/home/notarisdossier/application/current/frontends/office/public/',
      before  => Apache::Vhost["${::profile_apache::vhost} ssl"],
    }
    exec { '/bin/mkdir -p /home/notarisdossier/application/current/frontends/client':
      creates => '/home/notarisdossier/application/current/frontends/client/',
      before  => Apache::Vhost["${::profile_apache::vhost} ssl"],
    }
    file { ['/home/notarisdossier/config', '/home/notarisdossier/office-templates', '/home/notarisdossier/errors', '/home/notarisdossier/logs', '/home/notarisdossier/application/current',]:
      ensure  => directory,
      owner   => 'notarisdossier',
      before  => Apache::Vhost["${::profile_apache::vhost} ssl"],
      require => User['notarisdossier'],
    }
    notify { 'local directory, no nfs server found': }
  }
  else {
    # using nfs server, mounting directorys
    $nfs_address = $profile_apache::nfs_address

    file { '/home/notarisdossier/application/current':
      ensure  => link,
      target  => '/home/notarisdossier/application/releases/dummy',
      owner   => 'notarisdossier',
      group   => 'www-data',
      force   => true,
      replace => false,
    }

    nfs::client::mount { '/home/notarisdossier/config':
      server => $nfs_address,
      share  => '/mnt/nfs/config',
      mount  => '/home/notarisdossier/config',
      owner  => 'notarisdossier',
      group  => 'notarisdossier',
      atboot => true,
    }

    nfs::client::mount { '/home/notarisdossier/office-templates':
      server => $nfs_address,
      share  => '/mnt/nfs/office-templates',
      mount  => '/home/notarisdossier/office-templates',
      owner  => 'notarisdossier',
      group  => 'notarisdossier',
      atboot => true,
    }

    nfs::client::mount { '/home/notarisdossier/errors':
      server => $nfs_address,
      share  => '/mnt/nfs/errors',
      mount  => '/home/notarisdossier/errors',
      owner  => 'notarisdossier',
      group  => 'notarisdossier',
      perm   => '0777',
      atboot => true,
    }

    nfs::client::mount { '/home/notarisdossier/logs':
      server => $nfs_address,
      share  => '/mnt/nfs/logs',
      mount  => '/home/notarisdossier/logs',
      owner  => 'notarisdossier',
      group  => 'notarisdossier',
      perm   => '0777',
      atboot => true,
    }

    file { '/home/notarisdossier/config/local.php':
      ensure  => present,
      content => template('profile_apache/local.php.erb'),
      owner   => 'notarisdossier',
      group   => 'notarisdossier',
      mode    => '0644',
      require => Nfs::Client::Mount[ '/home/notarisdossier/config' ],
    }
  }
}
