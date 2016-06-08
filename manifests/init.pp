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
(
  $zendversion = $::profile_apache::params::zendversion,
  $packages = $::profile_apache::params::packages,
  $vhost = $::profile_apache::params::vhost,
  $docroot = $::profile_apache::params::docroot,
  $monitor_address = $::profile_apache::params::monitor_address,
  $nfs_address = $::profile_apache::params::nfs_address,
  $db_address = $::profile_apache::params::db_address,
  $win_address = $::profile_apache::params::win_address,
  $serveradmin = $::profile_apache::params::serveradmin,
  $root_directory_options = $::profile_apache::params::root_directory_options,
  $scriptalias = $::profile_apache::params::scriptalias,
  $log_level = $::profile_apache::params::log_level,
  $logroot = $::profile_apache::params::logroot,
  $access_log_file = $::profile_apache::params::access_log_file,
  $error_log_file = $::profile_apache::params::error_log_file,
  $ssl_cert = $::profile_apache::params::ssl_cert,
  $ssl_key =  $::profile_apache::params::ssl_key,
  $ext_lb_fqdn = $::profile_apache::params::ext_lb_fqdn,
  $db_password = $::profile_apache::params::db_password,
  $dirict_username = $::profile_apache::params::dirict_username,
  $dirict_password = $::profile_apache::params::dirict_password,
  $azure_account = $::profile_apache::params::azure_account,
  $azure_access_key = $::profile_apache::params::azure_access_key,
  $webservices_dirict_username = $::profile_apache::params::webservices_dirict_username,
  $webservices_dirict_password = $::profile_apache::params::webservices_dirict_password,
  $webdav_dirict_templates_password = $::profile_apache::params::webdav_dirict_templates_password,
) inherits ::profile_apache::params {

  # validate parameters here

  notify {"addr from init: monitor ${monitor_address}, nfs ${nfs_address}, db ${db_address}, win ${win_address}": }

  class { '::profile_apache::install': } ->
  class { '::profile_apache::config': } ~>
  class { '::profile_apache::service': } ->
  Class['::profile_apache']
}
