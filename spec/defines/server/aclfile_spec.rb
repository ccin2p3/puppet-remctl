# vim: tabstop=4 shiftwidth=4 softtabstop=4
require 'spec_helper'

oses_specs = @oses_specs

describe 'remctl::server::aclfile', :type => :define do

    let :title do
        'rspec-aclfile'
    end

    let :default_acldir do
        '/etc/remctl/acl'
    end

    let :default_user do
        'root'
    end

    let :default_group do
        'root'
    end

    let :default_file_mode do
        '0440'
    end

    let :aclfile do
        "#{default_acldir}/#{title}"
    end

    context 'without remctl::server' do
        it 'should fail' do
            expect {
                should compile
            }.to raise_error(/You must include the remctl::server class before/)
        end
    end # context 'without remctl::server'

    oses_specs.each do |osname, specs|

        describe "running on #{osname}" do

            let :pre_condition do
                'class { "remctl::server": }'
            end

            let :facts do {
                :osfamily               => specs[:osfamily],
                :operatingsystem        => specs[:operatingsystem]
            } end

            describe '#ensure' do

                context 'with default values' do
                    let :params do {
                    } end

                    it 'should have acl file absent' do
                        should contain_file(aclfile).with_ensure('absent')
                    end

                end # context with default values

                context 'with bad value' do
                    let :params do {
                        :ensure     => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile
                        }.to raise_error()
                    end

                end # context with bad value

                context 'with ensure present and acl' do
                    let :params do {
                        :ensure     => 'present',
                        :acls       => ['princ:someone@IN2P3.FR', 'pts:someptsgroup']
                    } end

                    it 'should have acl file present' do
                        should contain_file(aclfile).with({
                            :ensure     => 'file',
                            :owner      => default_user,
                            :group      => default_group,
                            :mode       => default_file_mode,
                            :content    => /^princ:someone@IN2P3.FR\npts:someptsgroup$/
                        })
                    end

                end # context with ensure present and acl

                context 'with ensure present' do
                    let :params do {
                        :ensure     => 'present'
                    } end

                    it 'should have acl file present' do
                        should contain_file(aclfile).with_ensure('absent')
                    end

                end # context with ensure present

                context 'with ensure absent' do
                    let :params do {
                        :ensure     => 'absent'
                    } end

                    it 'should have acl file absent' do
                        should contain_file(aclfile).with_ensure('absent')
                    end

                end # context with ensure absent

            end # describe #ensure

            describe '#acls' do

                context 'with bad value' do
                    let :params do {
                        :acls   => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile
                        }.to raise_error(/ is not an Array/)
                    end
                end # context 'with bad value'

            end # describe '#acls'

            describe '#acldir' do

                context 'with bad value' do
                    let :params do {
                        :acldir   => false
                    } end

                    it 'should raise error' do
                        expect {
                            should compile
                        }.to raise_error(/ is not an absolute path/)
                    end
                end # context 'with bad value'

                context 'with custom value' do
                    let :params do {
                        :acldir => '/acls'
                    } end

                    it 'should have file in directory' do
                        should contain_file("/acls/#{title}")
                    end

                end # context 'with custom value'

            end # describe '#acldir'

        end # describe running on

    end # oses_facts.each

end
