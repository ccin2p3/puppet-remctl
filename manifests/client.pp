#
# remctl client class
#
class remctl::client (
    $ensure             = 'present',
    $package_name       = $::remctl::params::client_package_name
) inherits ::remctl::params {

    require stdlib

    validate_string($ensure)
    validate_string($package_name)

    if ! defined(Package[$package_name]) {
        package { $package_name:
            ensure      => $ensure,
        }
    }
}
