# == Class profile_apache::install
#
# This class is called from profile_apache for install.
#
class profile_apache::install {
  $zendversion = $::profile_apache::zendversion
  $zendurl = "https://packages.zendframework.com/releases/ZendFramework-${zendversion}/ZendFramework-${zendversion}.tar.gz"
  $destination = "/tmp/ZendFramework-${zendversion}.tar.gz"
  include nfs::client
  include wget

  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # install packages
  ensure_packages( $::profile_apache::packages )

  # install zend framework
  exec { "wget-${zendurl}":
    command => "wget --no-check-certificate ${zendurl} -O ${destination}",
    path    => '/usr/bin',
    creates => $destination,
    notify  => Exec[ 'tar-zf' ],
  }

  exec { 'tar-zf':
    command     => "/bin/tar -xzf ${destination}",
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
    mpm_module             => 'prefork',
    root_directory_options => $::profile_apache::root_directory_options,
    log_level              => $::profile_apache::log_level,
    require                => Exec[ $logpath ],
    default_mods           => [
      'php',
      'headers',
      'rewrite',
      'expires',
      'myfixip',
    ],
  }

  class { 'apache::mod::ssl':
    ssl_compression => false,
  }

}
