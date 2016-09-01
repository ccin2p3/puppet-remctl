# vim: tabstop=4 shiftwidth=4 softtabstop=4
require 'spec_helper'

oses_specs = @oses_specs

describe 'remctl::server', :type => :class do

    let :xservice_name do
        'remctl'
    end

    let :augeas_name do
        'remctl_etc_services'
    end

    let :default_user do
        'root'
    end

    let :default_group do
        'root'
    end

    context 'running on unsupported osfamily' do

        let :facts do {
            :osfamily       => 'something-unsupported',
        } end

        it 'should fail' do
            expect {
                should compile.with_all_deps
            }.to raise_error(/remctl: module does not support osfamily #{facts[:osfamily]}/)
        end

    end # context running on unsupported osfamily

    oses_specs.each do |osname, specs|

        describe "running on #{osname}" do

            let :package_name do
                specs[:remctl_server_package]
            end

            let :facts do {
                :osfamily               => specs[:osfamily],
                :operatingsystem        => specs[:operatingsystem]
            } end

            describe 'xinetd interaction' do

                it 'should include Xinetd' do
                    should contain_class('Xinetd')
                end

            end # describe 'xinetd interaction'

            describe '#ensure' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have server package' do
                        should contain_package(package_name).with_ensure('present')
                    end

                    it 'should have xinetd service' do
                        should contain_xinetd__service(xservice_name).with_ensure('present')
                    end

                    it 'should have base remctl directory' do
                        should contain_file(specs[:basedir]).with({
                            'ensure'        => 'directory',
                            'mode'          => '0750',
                            'owner'         => default_user,
                            'group'         => default_group
                        }).that_comes_before("File[#{specs[:confdir]}]")
                    end

                    it 'should have remctl configuration directory' do
                        should contain_file(specs[:confdir]).with({
                            'ensure'        => 'directory',
                            'mode'          => '0750',
                            'owner'         => default_user,
                            'group'         => default_group
                        }).that_comes_before("File[#{specs[:acldir]}]")
                    end

                    it 'should have remctl ACLs directory' do
                        should contain_file(specs[:acldir]).with({
                            'ensure'        => 'directory',
                            'mode'          => '0750',
                            'owner'         => default_user,
                            'group'         => default_group
                        }).that_comes_before("File[#{specs[:conffile]}]")
                    end

                    it 'should have remctl configuration file' do
                        should contain_file(specs[:conffile]).with({
                            'ensure'        => 'file',
                            'mode'          => '0640',
                            'owner'         => default_user,
                            'group'         => default_group
                        }).that_comes_before("Augeas[#{augeas_name}]")
                    end

                    it 'should modify /etc/services before xinetd service declarated' do
                        should contain_augeas(augeas_name).that_comes_before("Xinetd::Service[#{xservice_name}]")
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :ensure     => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad value

                context 'with ensure absent' do
                    let :params do {
                        :ensure     => 'absent'
                    } end

                    it 'should have passed value' do
                        should contain_package(package_name).with_ensure('absent')
                    end

                    it 'should have xinetd service' do
                        should contain_xinetd__service(xservice_name).with_ensure('absent')
                    end

                end # context with custom value

                describe 'interaction with #manage_user' do

                    context 'with ensure absent' do
                        let :params do {
                            :ensure         => 'absent',
                            :manage_user    => true,
                            :user           => 'someuser'
                        } end
                        
                        it 'should have user absent' do
                            should contain_user('someuser').with_ensure('absent')
                        end
                    end

                    context 'with ensure present' do
                        let :params do {
                            :ensure         => 'present',
                            :manage_user    => true,
                            :user           => 'someuser'
                        } end
                        
                        it 'should have user present' do
                            should contain_user('someuser').with_ensure('present')
                        end
                    end
                end # describe 'interaction with #manage_user' do

            end # describe #ensure

            describe '#debug' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should NOT have debug enabled' do
                        should_not contain_xinetd__service(xservice_name).with({
                            'server_args'       => /^-d\s+/
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :debug      => 'astring'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a boolean/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :debug      => true
                    } end

                    it 'should have debug enabled' do
                        should contain_xinetd__service(xservice_name).with({
                            'server_args'       => /^-d\s+/
                        })
                    end
                end # context with custom value

            end # describe #debug

            describe '#disable' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have xinetd service disabled' do
                        should contain_xinetd__service(xservice_name).with({
                            'disable'       => 'yes' 
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :disable    => 'astring'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a boolean/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :disable    => false
                    } end

                    it 'should have debug enabled' do
                        should contain_xinetd__service(xservice_name).with({
                            'disable'       => 'no'
                        })
                    end
                end # context with custom value

            end # describe #disable

            describe '#krb5_service' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should NOT have -s option in server args' do
                        should_not contain_xinetd__service(xservice_name).with({
                            'server_args'       => /-s .+/
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :krb5_service   => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :krb5_service   => 'remctl'
                    } end

                    it 'should have passed value for -s option' do
                        should contain_xinetd__service(xservice_name).with({
                            'server_args'       => /-s remctl\s+/
                        })
                    end
                end # context with custom value

            end # describe #krb5_service

            describe '#krb5_keytab' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have proper xinetd server args' do
                        should contain_xinetd__service(xservice_name).with({
                            'server_args'       => /-k \/etc\/krb5\.keytab\s+/
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :krb5_keytab    => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :krb5_keytab    => '/path/remctl.keytab'
                    } end

                    it 'should have passed value' do
                        should contain_xinetd__service(xservice_name).with({
                            'server_args'       => /-k \/path\/remctl\.keytab\s+/
                        })
                    end
                end # context with custom value

            end # describe #krb5_keytab

            describe '#port' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have default port' do
                        should contain_xinetd__service(xservice_name).with({
                            'port'      =>  specs[:port]
                        })
                    end

                    it 'should have remctl augeas resource' do
                        should contain_augeas(augeas_name).with({
                            'context'   => '/files/etc/services',
                            'changes'   => [
                                'defnode remctltcp service-name[.="remctl"][protocol = "tcp"] remctl',
                                "set \$remctltcp/port #{specs[:port]}",
                                'set $remctltcp/protocol tcp',
                                'set $remctltcp/#comment "remote authenticated command execution"',
                            ]
                        })
                    end

                    it 'should have NULL xinetd service type' do
                        should contain_xinetd__service(xservice_name).with({
                            'service_type'  => nil
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :port       => 'NaN'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/Expected.+to be an Integer/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :port       => 12345
                    } end

                    it 'should have passed port' do
                        should contain_xinetd__service(xservice_name).with({
                            'port'      => 12345
                        })
                    end

                    it 'should have remctl augeas resource with official port' do
                        should contain_augeas(augeas_name).with({
                            'context'   => '/files/etc/services',
                            'changes'   => [
                                'defnode remctltcp service-name[.="remctl"][protocol = "tcp"] remctl',
                                "set \$remctltcp/port #{specs[:port]}",
                                'set $remctltcp/protocol tcp',
                                'set $remctltcp/#comment "remote authenticated command execution"',
                            ]
                        })
                    end

                    it 'should have UNLISTED xinetd service type' do
                        should contain_xinetd__service(xservice_name).with({
                            'service_type'  => 'UNLISTED'
                        })
                    end

                end # context with custom value

            end # describe #port

            describe '#user / #group / #manage_user' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should NOT have user' do
                        should_not contain_user(default_user)
                    end

                    it 'should NOT have group' do
                        should_not contain_group(default_group)
                    end

                end # context with default values

                context 'with bad user value for user' do
                    let :params do {
                        :user   => false,
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad user value

                context 'with bad group value for group' do
                    let :params do {
                        :group   => false,
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad group value

                context 'with bad manage_user value' do
                    let :params do {
                        :manage_user    => 'astring'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a boolean/)
                    end

                end # context with manage_user value

                context 'with custom values' do
                    let :params do {
                        :manage_user    => true,
                        :user           => 'username',
                        :group          => 'groupname'
                    } end

                    it 'should have user' do
                        should contain_user('username').that_notifies("Package[#{package_name}]")
                        should contain_user('username').that_requires('Group[groupname]')
                    end

                    it 'should have group' do
                        should contain_group('groupname')
                    end

                end # context with custom value

                context 'with custom value root' do
                    
                    let :params do {
                        :manage_user    => true,
                        :user           => 'root',
                        :group           => 'root',
                    } end

                    it 'should not have user' do
                        should_not contain_user('root')
                    end

                    it 'should not have group' do
                        should_not contain_group('root')
                    end

                end # context 'with custom value root'

                context 'with custom value zero' do
                    
                    let :params do {
                        :manage_user    => true,
                        :user           => '0',
                        :group           => '0'
                    } end

                    it 'should not have user' do
                        should_not contain_user('0')
                    end

                    it 'should not have group' do
                        should_not contain_group('0')
                    end

                end # context 'with custom value zero'

                context 'with non-root user and root group' do
                    let :params do {
                        :manage_user    => true,
                        :user           => 'username',
                        :group          => 'root'
                    } end

                    it 'should have user with empty require' do
                        should contain_user('username').with({
                            :require    => nil
                        })
                    end

                end # context 'with user root and non-root group'

            end # describe #user / #manage_user

            describe '#only_from' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have default' do
                        should contain_xinetd__service(xservice_name).with({
                            :only_from      => [ '0.0.0.0' ]
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :only_from  => 'somestring'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not an Array/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :only_from  => [ '134.158.69.34', '127.0.0.1' ]
                    } end

                    it 'should have passed only from' do
                        should contain_xinetd__service(xservice_name).with({
                            :only_from  => /^134.158.69.34 127.0.0.1$/
                        })
                    end

                end # context with custom value

            end # describe #only_from

            describe '#no_access' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have default' do
                        should contain_xinetd__service(xservice_name).with({
                            :no_access      => nil
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :no_access  => 'somestring'
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not an Array/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :no_access  => [ '134.158.69.34', '127.0.0.1' ]
                    } end

                    it 'should have passed no access' do
                        should contain_xinetd__service(xservice_name).with({
                            :no_access  => /^134.158.69.34 127.0.0.1$/
                        })
                    end

                end # context with custom value

            end # describe #no_access

            describe '#bind' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have default' do
                        should contain_xinetd__service(xservice_name).with({
                            :bind   => nil
                        })
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :bind   => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile.with_all_deps
                        }.to raise_error(/ is not a string/)
                    end

                end # context with bad value

                context 'with custom value' do
                    let :params do {
                        :bind   => '134.158.69.34'
                    } end

                    it 'should have passed bind' do
                        should contain_xinetd__service(xservice_name).with({
                            :bind   => '134.158.69.34'
                        })
                    end

                end # context with custom value

            end # describe #bind

            context 'with client also declared' do

                let :pre_condition do
                    "
                    class { 'remctl::client':
                        ensure  => present
                    }
                    "
                end

                let :params do {
                    :ensure     => 'present'
                } end

                # Just for coverage report ...
                it 'should contain client' do
                    should contain_class('Remctl::Client')
                end

                # https://github.com/ccin2p3/puppet-ccin2p3-remctl/issues/10
                it 'shouldn\'t declare package twice' do
                    should compile.with_all_deps
                end

            end # context 'with client also declared'

        end # describe running on

    end # oses_facts.each

end
