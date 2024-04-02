#
# remctl server class
#
class remctl::server (
  String $package_name,
  Enum['systemd_socket', 'xinetd'] $deployment_flavor,
  Stdlib::Port $port,
  Enum['present', 'absent'] $ensure,
  Boolean $debug,
  Boolean $alter_etc_services,
  Stdlib::Absolutepath $krb5_keytab,
  Stdlib::Absolutepath $server_bin,
  Stdlib::Absolutepath $basedir,
  String $user,
  String $group,
  Boolean $manage_user,
  Optional[String] $krb5_service = undef,
  Hash $commands = {},
  Hash $aclfiles = {}
) inherits ::remctl {

  $default_port = 4373

  #
  # Computed values
  #
  $_directories_ensure = $ensure ? { 'present' => 'directory', 'absent' => 'absent' }
  $_files_ensure = $ensure ? { 'present' => 'file', 'absent' => 'absent' }
  $deployment_klass = "remctl::server::${deployment_flavor}"

  $confdir = "${basedir}/conf.d"
  $conffile = "${basedir}/remctl.conf"
  $acldir = "${basedir}/acl"

  if ($debug) {
    $_debug = '-d'
  }
  else {
    $_debug = undef
  }

  if ($krb5_service == undef) {
    $_krb5_service = undef
  }
  else {
    $_krb5_service = "-s ${krb5_service}"
  }

  $_conffile = "-f ${conffile}"

  if ($krb5_keytab == undef) {
    $_krb5_keytab = undef
  }
  else {
    $_krb5_keytab = "-k ${krb5_keytab}"
  }

  if ($manage_user == true) {

    if ($group != 'root' and $group != '0') {
      group { $group:
        ensure => $ensure,
      }

      $_user_require = [Group[$group]]

      Group[$group] -> Class[$deployment_klass]
    }
    else {
      $_user_require = undef
    }

    if ($user != 'root' and $user != '0') {
      user { $user:
        ensure  => $ensure,
        comment => 'remctl user',
        gid     => $group,
        require => $_user_require,
        notify  => Package[$package_name],
      }

      User[$group] -> Class[$deployment_klass]
    }
  }

  if (! defined(Package[$package_name])) {
    package { $package_name:
      ensure => $ensure,
      before => File[$basedir],
    }
  }

  file { $basedir:
    ensure => $_directories_ensure,
    mode   => '0750',
    owner  => $user,
    group  => $group
  }

  -> file { $confdir:
    ensure => $_directories_ensure,
    mode   => '0750',
    owner  => $user,
    group  => $group
  }

  -> file { $acldir:
    ensure => $_directories_ensure,
    mode   => '0750',
    owner  => $user,
    group  => $group
  }

  -> file { $conffile:
    ensure  => $_files_ensure,
    content => template('remctl/remctl.conf'),
    mode    => '0640',
    owner   => $user,
    group   => $group,
  }

  if ($alter_etc_services == true) {
    # Note(remi):
    # As suggested by Russ A.:
    # - Only update /etc/services if official remctl port was used.
    # - Do not register UDP service anymore as it's very unlikely that
    #   UDP will be used someday.
    augeas { 'remctl_etc_services':
      context => '/files/etc/services',
      changes => [
        'defnode remctltcp service-name[.="remctl"][protocol = "tcp"] remctl',
        "set \$remctltcp/port ${default_port}",
        'set $remctltcp/protocol tcp',
        'set $remctltcp/#comment "remote authenticated command execution"',
      ],
    }
  }

  $base_args = [
    $_debug,
    $_krb5_keytab,
    $_krb5_service,
    $_conffile,
  ]

  $common_args = $base_args.filter |$val| { $val =~ NotUndef }

  class { $deployment_klass:
    require => File[$conffile],
  }

  create_resources('::remctl::server::command', $commands, {})
  create_resources('::remctl::server::aclfile', $aclfiles, {})
}
