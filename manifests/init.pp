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
  # software
  $zendversion = $::profile_apache::params::zendversion,
  $packages = $::profile_apache::params::packages,
  # infra
  $monitor_address = $::profile_apache::params::monitor_address,
  $nfs_address = $::profile_apache::params::nfs_address,
  $db_address = $::profile_apache::params::db_address,
  $win_address = $::profile_apache::params::win_address,
  $ext_lb_fqdn = $::profile_apache::params::ext_lb_fqdn,
  # apache
  $serveradmin = $::profile_apache::params::serveradmin,
  $root_directory_options = $::profile_apache::params::root_directory_options,
  $scriptalias = $::profile_apache::params::scriptalias,
  $log_level = $::profile_apache::params::log_level,
  $logroot = $::profile_apache::params::logroot,
  # certificates
  $ssl_cert = $::profile_apache::params::ssl_cert,
  $ssl_key =  $::profile_apache::params::ssl_key,
  # vhost office
  $office_server_name = $::profile_apache::params::office_server_name,
  $office_document_root = $::profile_apache::params::office_document_root,
  $office_error_log = $::profile_apache::params::office_error_log,
  $office_access_log = $::profile_apache::params::office_access_log,
  # vhosts client
  $client_server_name = $::profile_apache::params::client_server_name,
  $client_document_root = $::profile_apache::params::client_document_root,
  $client_error_log = $::profile_apache::params::client_error_log,
  $client_access_log = $::profile_apache::params::client_access_log,

  # old vhost
  $vhost = $::profile_apache::params::vhost,
  $docroot = $::profile_apache::params::docroot,
  $access_log_file = $::profile_apache::params::access_log_file,
  $error_log_file = $::profile_apache::params::error_log_file,
  # accounts
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
  validate_string($office_server_name)
  validate_absolute_path($office_document_root)
  validate_string($office_error_log)
  validate_string($office_access_log)

  validate_string($zendversion)
  validate_array($packages)
  validate_string($vhost)
  validate_absolute_path($docroot)
  validate_string($serveradmin)
  validate_array($root_directory_options)
  validate_string($scriptalias)
  validate_string($log_level)
  validate_absolute_path($logroot)
  validate_string($access_log_file)
  validate_string($error_log_file)
  validate_string($ext_lb_fqdn)
  validate_string($db_password)
  validate_string($dirict_username)
  validate_string($dirict_password)
  validate_string($azure_account)
  validate_string($azure_access_key)
  validate_string($webservices_dirict_username)
  validate_string($webservices_dirict_password)
  validate_string($webdav_dirict_templates_password)

  notify {"addr from init: monitor ${monitor_address}, nfs ${nfs_address}, db ${db_address}, win ${win_address}": }

  class { '::profile_apache::install': } ->
  class { '::profile_apache::config': } ~>
  class { '::profile_apache::service': } ->
  Class['::profile_apache']
}
