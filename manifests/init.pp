# == Class: profile_apache
#
# Full description of class profile_apache here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class profile_apache
{
  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  class { 'apache::mod::php': }

  apache::vhost { 'ssl.example.com':
    port    => '443',
    docroot => '/var/www/ssl',
    ssl     => true,
  }
}
