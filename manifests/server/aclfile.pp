#
define remctl::server::aclfile (
    $ensure         = 'present',
    $acldir         = $remctl::server::acldir,
    $acls           = []
) {

    if ! defined(Class['remctl::server']) {
        fail('You must include the remctl::server class before using any remctl::server::acl resources')
    }

    validate_re($ensure, '^(present|absent)$')
    validate_array($acls)
    validate_absolute_path($acldir)

    $_files_ensure = $ensure ? { 'present' => 'file', 'absent' => 'absent' }

    if ($acls and size($acls) > 0) {
        $aclfile_ensure = $_files_ensure
    }
    else {
        $aclfile_ensure = 'absent'
    }

    file { "${acldir}/${name}":
        ensure      => $aclfile_ensure,
        owner       => $remctl::server::user,
        group       => $remctl::server::group,
        mode        => '0440',
        content     => template('remctl/server/aclfile.erb')
    }
}

# vim: tabstop=4 shiftwidth=4 softtabstop=4
