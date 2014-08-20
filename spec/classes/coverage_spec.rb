
# Note(remi):
# Uggly explicit filter list...
# if someone knows how to handle this properly
# please, do so !
['Class[Stdlib::Stages]', 'Class[Xinetd::Params]',
 'Class[Stdlib]', 'Class[Remctl::Params]',
 'File[/etc/xinetd.conf]', 'File[/etc/xinetd.d/remctl]',
 'File[/etc/xinetd.d]', 'Service[xinetd]',
 'Package[xinetd]', 'Stage[deploy]', 'Stage[deploy_app]',
 'Stage[deploy_infra]', 'Stage[runtime]', 'Stage[setup]',
 'Stage[setup_app]', 'Stage[setup_infra]',
 'Remctl::Server::Aclfile[rspec-aclfile]',
 'Class[Concat::Setup]', 'Exec[concat_/etc/remctl/conf.d/kadmin]',
 'Concat::Fragment[kadmin_puppet_header]',

 'File[/etc/remctl/conf.d/kadmin]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments.concat.out]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments.concat]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments/01_kadmin_puppet_header]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments/02_kadmin_change_pw]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments/02_kadmin_other]',
 'File[/tmp/_etc_remctl_conf.d_kadmin/fragments]',
 'File[/tmp/_etc_remctl_conf.d_kadmin]',
 'File[/tmp/bin/concatfragments.sh]',
 'File[/usr/local/bin/concatfragments.sh]',
 'File[/tmp/bin]',
 'File[/tmp]',
 'Remctl::Server::Command[10-kadmin_changepw]',
 'Remctl::Server::Command[rspec-command]',
 'Remctl::Server::Command[00-kadmin_other]'].each do |f|
    RSpec::Puppet::Coverage.filters << f
end

at_exit { RSpec::Puppet::Coverage.report! }
