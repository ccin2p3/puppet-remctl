#
class remctl::server::systemd_socket(
  String $service_name,
  Boolean $daemon_reload = true,
  Boolean $socket_enable = true,
  Boolean $socket_active = true,
  Optional[String] $trigger_limit_interval = undef,
  Optional[Integer[1]] $trigger_limit_burst = undef,
) inherits ::remctl::server
{
  systemd::unit_file { "${service_name}.socket":
    ensure        => $remctl::server::ensure,
    content       => epp("${module_name}/server/systemd/remctld.socket.epp"),
    enable        => $socket_enable,
    active        => $socket_active,
    daemon_reload => $daemon_reload,
  }

  -> systemd::unit_file { "${service_name}.service":
    ensure        => $remctl::server::ensure,
    content       => epp("${module_name}/server/systemd/remctld.service.epp"),
    enable        => false,
    active        => false,
    daemon_reload => $daemon_reload,
  }

  -> exec { "reload ${service_name}":
    command     => "systemctl reload ${service_name}.service",
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    refreshonly => true,
    onlyif      => "test `systemctl is-active ${service_name}.service` = \"active\"",
  }
}

# vim: ft=puppet
