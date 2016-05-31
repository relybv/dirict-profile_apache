# == Class: profile_apache::notarisdossier_user_keys
#
#Installs ssh keys from hiera.
#
#
define profile_apache::notarisdossier_user_keys(
  $user,
  $ssh_key,

) {

  file_line { $user:
    path    => '/home/notarisdossier/.ssh/authorized_keys',
    line    => "$ssh_key $user",
    require => File['/home/notarisdossier/.ssh/authorized_keys']
  }

}
