#
# remctl client class
#
class remctl::client (
  String $package_name,
  Stdlib::Ensure::Package $ensure = 'present',
) {
  if ! defined(Package[$package_name]) {
    package { $package_name:
      ensure => $ensure,
    }
  }
}
