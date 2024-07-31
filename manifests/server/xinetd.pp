#
class remctl::server::xinetd(
  Array[Stdlib::IP::Address] $only_from = ['0.0.0.0'],
  Array[Stdlib::IP::Address] $no_access = [],
  Optional[String] $bind = undef,
  Integer[0] $cps_count = 50,
  Integer[0] $cps_delay = 10,
  Boolean $disable = false,
) inherits remctl::server
{
  if ($remctl::server::port == $remctl::server::default_port) {
    $_xinetd_service_type = undef
  }
  else {
    $_xinetd_service_type = 'UNLISTED'
  }

  if ($only_from.empty()) {
    $_only_from = undef
  }
  else {
    $_only_from = $only_from.join(' ')
  }

  if ($no_access.empty()) {
    $_no_access = undef
  }
  else {
    $_no_access = $no_access.join(' ')
  }

  if $disable {
    $_disable = 'yes'
  }
  else {
    $_disable = 'no'
  }

  $cps = "${cps_count} ${cps_delay}"

  include xinetd

  xinetd::service { 'remctl':
    ensure       => $remctl::server::ensure,
    port         => $remctl::server::port, # Dupplicate with /etc/services info but xinetd::service requires it
    service_type => $_xinetd_service_type,
    server       => $remctl::server::server_bin,
    server_args  => $remctl::server::common_args.join(' '),
    disable      => $_disable,
    protocol     => 'tcp',
    socket_type  => 'stream',
    user         => $remctl::server::user,
    group        => $remctl::server::group,
    only_from    => $_only_from,
    no_access    => $_no_access,
    bind         => $bind,
    cps          => $cps,
  }
}
