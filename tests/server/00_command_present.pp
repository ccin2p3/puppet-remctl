
class {'remctl::server': }

$ensure = 'present'

remctl::server::command { 'my_test_command':
    command             => 'command_name',
    subcommand          => 'ALL',
    executable          => '/bin/test',
    acls                => ['princ:test@TEST.REALM.ORG']
}

remctl::server::command { 'kadmin_cpw':
    ensure          => $ensure,
    command         => 'kadmin',
    subcommand      => 'change_password',
    executable      => '/usr/sbin/kadmin',
    options         => {
        help      => '--help',
        'summary' => '--summary',
    },
    acls            => ['ANYUSER']
}

remctl::server::command { 'kadmin_lock':
    ensure          => $ensure,
    command         => 'kadmin',
    subcommand      => 'lock_user',
    executable      => '/usr/sbin/kadmin',
    options         => {
        'help'      => '--help',
        'summary'   => '--summary',
    },
    acls            => ['princ:admin@EXAMPLE.ORG']
}

remctl::server::command { 'kadmin_aa':
    ensure          => $ensure,
    command         => 'kadmin',
    subcommand      => '00aasomehting',
    executable      => '/usr/sbin/kadmin',
    options         => {
        'help'      => '--help',
        'summary'   => '--summary',
    },
    acls            => ['princ:where@EXAMPLE.ORG']
}


# vim: tabstop=4 shiftwidth=4 softtabstop=4
