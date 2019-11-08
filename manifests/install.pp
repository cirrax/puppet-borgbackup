#
# internal class borgbackup::install
#
# @summary
# internal class borgbackup::install
# to install the packages
# (used by ::borgbackup::server and ::borgbackup)
#
# @param packages
#   packages to install
#   defaults to ['borgbackup']
# @param package_ensure
#   defaults to 'installed'
#
class borgbackup::install (
  Array  $packages       = ['borgbackup'],
  String $package_ensure = 'installed',
){

  package{ $packages:
    ensure => $package_ensure,
    tag    => 'borgbackup',
  }
}
