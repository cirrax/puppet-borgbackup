#
# internal class borgbackup::install
# to install the packages
# (used by ::borgbackup::server and ::borgbackup)
#
# Parameters:
#  $packages:
#    packages to install
#    defaults to ['borgbackup']
#  $package_ensure
#    defaults to 'installed'
#
class borgbackup::install (
  $packages       = ['borgbackup'],
  $package_ensure = 'installed',
){

  package{ $packages:
    ensure => $package_ensure,
    tag    => 'borgbackup',
  }
}
