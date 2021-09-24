#
define remctl::server::command (
    $command,
    $subcommand,
    $executable,
    $acls,
    $options            = {},
    $ensure             = 'present'
) {

    if ! defined(Class['remctl::server']) {
        fail('You must include the remctl::server class before using any remctl::server::command resources')
    }

    validate_string($command)
    validate_string($subcommand)
    validate_absolute_path($executable)
    validate_hash($options)
    validate_array($acls)
    validate_re($ensure, '^(present|absent)$')

    $cmdfile = "${remctl::server::confdir}/${command}"
    $_files_ensure = $ensure ? { 'present' => 'file', 'absent' => 'absent' }

    if (!$acls or size($acls) == 0) {
        fail("Missing acls for commmand '${command}/${subcommand}'")
    }

    if ! defined(Concat[$cmdfile]) {
        concat { $cmdfile:
            # Note(remi):
            # *ensure* is not supported in puppetlabs-concat 1.0.4
            # This conflicts with the Modulefile that says that puppet-remctl
            # is compatible with all 1.x versions.
            # The easiest way to fix this without introducing backward compatibility
            # problems is to remove the *ensure* parameter from the Concat type for now.
            ensure => present,
            mode   => '0440',
            force  => false,
            owner  => $remctl::server::user,
            group  => $remctl::server::group,
            warn   => true
        }

    }

    if $ensure == 'present' {
        concat::fragment { "${command}_${subcommand}":
            target  => $cmdfile,
            content => template('remctl/server/command.erb')
        }
    }
}

# vim: tabstop=4 shiftwidth=4 softtabstop=4
