#
type Remctl::Server::Deployment_flavor_options::Xinetd = Struct[{
  only_from => Optional[Array[Stdlib::IP::Address]],
  no_access => Optional[Array[Stdlib::IP::Address]],
  bind      => Optional[String],
  cps_count => Optional[Integer[0]],
  cps_delay => Optional[Integer[0]],
  disable   => Optional[Boolean],
}]
