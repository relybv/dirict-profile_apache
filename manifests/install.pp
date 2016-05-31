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
    command => "/bin/mkdir -p ${logpath}",
    creates => $logpath,
  }

  exec { $rootpath:
    command => "/bin/mkdir -p ${rootpath}",
    creates => $rootpath,
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
      content =>  $ssl_cert,
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
      content =>  $ssl_key,
    }
    $ssl_key_path = '/etc/ssl/private/ssl-cert-default.key'
  }

  class { 'apache':
    default_vhost          => false,
    mpm_module             => 'prefork',
    root_directory_options => $::profile_apache::root_directory_options,
    require                => Exec[ $logpath ],
  }

  class { 'apache::mod::php': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::expires': }
  class { 'apache::mod::ssl':
    ssl_compression => false,
  }

}
