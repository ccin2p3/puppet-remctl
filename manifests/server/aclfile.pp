#
define remctl::server::aclfile (
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Absolutepath $acldir = $::remctl::server::acldir,
  Array[String] $acls = [],
) {

  if (! defined(Class['remctl::server'])) {
    fail('You must include the remctl::server class before using any remctl::server::acl resources')
  }

  $_files_ensure = $ensure ? { 'present' => 'file', 'absent' => 'absent' }

  if ($acls and size($acls) > 0) {
    $aclfile_ensure = $_files_ensure
  }
  else {
    $aclfile_ensure = 'absent'
  }

  file { "${acldir}/${name}":
    ensure  => $aclfile_ensure,
    owner   => $remctl::server::user,
    group   => $remctl::server::group,
    mode    => '0440',
    content => template('remctl/server/aclfile.erb')
  }

  if ($remctl::server::deployment_flavor == 'systemd_socket') {
    File["${acldir}/${name}"]
    ~> Exec["reload ${remctl::server::systemd_socket::service_name}"]
  }
}
