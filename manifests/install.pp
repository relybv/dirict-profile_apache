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

  if ( $::profile_apache::params::phpversion == '5.0' ) or ( $::profile_apache::params::phpversion == '7.1' ) {
    # add php repo
    apt::source { 'php':
      location => $::profile_apache::params::php_repo_location,
      release  => $::profile_apache::params::php_repo_release,
      repos    => 'main',
      key      => {
        'id'     => $::profile_apache::params::php_repo_id,
        'source' => $::profile_apache::params::php_repo_source,
      },
      before   => Package['pdftk'],
      notify   => Exec['apt_update'],
    }

    # install packages
    ensure_packages( $::profile_apache::packages, {
      'require' => Apt::Source['php'],
    })
    # install php redis
    exec { 'install-redis':
      path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
      command => 'pecl install redis',
      cwd     => '/',
      creates => '/usr/share/php/docs/redis/README.markdown',
      require => Package['php-pear'],
    }
  } else {
    ensure_packages( $::profile_apache::packages, { })
  }

  package { 'openssl':
    ensure  => latest,
    require => Exec['apt_update'],
  }

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

  file { '/usr/share/php':
    ensure => directory,
  }

  exec { 'mv-zf':
    command     => "/bin/mv /tmp/ZendFramework-${zendversion}/library/Zend /usr/share/php/.",
    refreshonly => true,
    require     => File['/usr/share/php'],
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
    mpm_module             => 'prefork',
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
  }

  class { 'apache::mod::headers': }
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::expires': }
  include apache::mod::php

  class { 'apache::mod::ssl':
    ssl_compression => false,
  }

  if $::profile_apache::params::phpversion == '5.0' {
    # install libsodium
    exec { 'install-libsodium':
      path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
      command => 'pecl install -f libsodium',
      cwd     => '/',
      creates => '/usr/lib/php/20160303/sodium.so',
      require => Package['php-pear'],
    }
  }

}
