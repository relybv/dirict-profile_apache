# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {
  $zendversion = $::profile_apache::zendversion
  $zendurl = "https://packages.zendframework.com/releases/ZendFramework-${zendversion}/ZendFramework-${zendversion}.tar.gz"
  $zenddestination = "/tmp/ZendFramework-${zendversion}.tar.gz"
  $libsodiumurl = 'https://download.libsodium.org/libsodium/releases/LATEST.tar.gz'
  include nfs::client
  include wget
  include apt

  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # add php5.6 repo
  apt::source { 'php56':
    location => 'http://packages.dotdeb.org',
    release  => 'wheezy-php56',
    repos    => 'all',
    key      => {
      'id'     => '7E3F070089DF5277',
      'source' => 'http://www.dotdeb.org/dotdeb.gpg',
    },
    before   => Package['php-pear'],
    notify   => Exec['apt_update'],
  }

  # install packages
  ensure_packages( $::profile_apache::packages )

  # install zend framework
  exec { "wget-${zendurl}":
    command => "wget --no-check-certificate ${zendurl} -O ${zenddestination}",
    path    => '/usr/bin',
    creates => $zenddestination,
    notify  => Exec[ 'tar-zf' ],
  }

  exec { 'tar-zf':
    command     => "/bin/tar -xzf ${zenddestination}",
    cwd         => '/tmp',
    refreshonly => true,
    notify      => Exec[ 'mv-zf' ],
  }

  exec { 'mv-zf':
    command     => "/bin/mv /tmp/ZendFramework-${zendversion}/library/Zend /usr/share/php/",
    refreshonly => true,
  }

  # create logpath
  $logpath = dirname( "${::profile_apache::logroot}${::profile_apache::error_log_file}" )

  exec { $logpath:
    command => "/bin/mkdir -p ${logpath}",
    creates => $logpath,
  }

  # replace empty certs with undef
  if $profile_apache::ssl_cert == '' {
    $ssl_cert = undef
  }
  else {
    $ssl_cert = $::profile_apache::ssl_cert
  }

  if $ssl_cert != undef {
    exec { 'mk_cert_path':
      command => '/bin/mkdir -p /etc/ssl/certs; /bin/mkdir -p /etc/ssl/private',
      creates => '/etc/ssl/certs',
    }
    file { '/etc/ssl/certs/ssl-cert-default.pem':
      ensure => link,
      target => $ssl_cert,
    }
    $ssl_cert_path = '/etc/ssl/certs/ssl-cert-default.pem'
  }

  if $profile_apache::ssl_key == '' {
    $ssl_key = undef
  }
  else {
    $ssl_key = $::profile_apache::ssl_key
  }

  if $ssl_key != undef {
    exec { 'mk_key_path':
      command => '/bin/mkddir -p /etc/ssl/private',
      creates => '/etc/ssl/private',
    }
    file { '/etc/ssl/private/ssl-cert-default.key':
      ensure => link,
      target => $ssl_key,
    }
    $ssl_key_path = '/etc/ssl/private/ssl-cert-default.key'
  }

  class { 'apache':
    default_vhost          => false,
    mpm_module             => false,
    root_directory_options => $::profile_apache::root_directory_options,
    log_level              => $::profile_apache::log_level,
    log_formats            => {
      # new log format
      combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"',
      # custom logformat, X-Forwarded-For as source ip
      # combined => '%{X-Forwarded-For}i %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\"',
    },
    keepalive              => 'On',
    max_keepalive_requests => '250',
    require                => Exec[ $logpath ],
    default_mods           => [
      'php',
      'headers',
      'rewrite',
      'expires',
    ],
  }

  class { 'apache::mod::ssl':
    ssl_compression => false,
  }

  class { 'apache::mod::prefork':
    startservers        => '10',
    minspareservers     => '10',
    maxspareservers     => '20',
    serverlimit         => '256',
    maxclients          => '256',
    maxrequestsperchild => '100',
  }

  # build and install libsodium
  exec { 'download-libsodium':
    cwd     => '/tmp',
    command => "/usr/bin/curl --silent ${libsodiumurl} -o /tmp/libsodium.tar.gz",
    creates => '/tmp/libsodium.tar.gz',
    notify  => Exec[ 'tar-libsodium' ],
  }

  exec { 'tar-libsodium':
    command     => '/bin/tar -xzf libsodium.tar.gz',
    refreshonly => true,
    cwd         => '/tmp',
    notify      => Exec[ 'make-libsodium' ],
  }

  exec { 'make-libsodium':
    command     => '/tmp/libsodium-stable/configure && /usr/bin/make -j 4 && /usr/bin/make -j 4 check',
    refreshonly => true,
    cwd         => '/tmp/libsodium-stable',
    notify      => Exec[ 'install-libsodium' ],
  }

  exec { 'install-libsodium':
    command     => '/usr/bin/make install',
    refreshonly => true,
    cwd         => '/tmp/libsodium-stable',
    creates     => '/usr/local/lib/pkgconfig/libsodium.pc',
  }

}
