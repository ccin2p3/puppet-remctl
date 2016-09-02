# -*- encoding : utf-8 -*-
if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
end

source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
    gem 'rspec', '< 3.0.0',        :require => false
    gem 'rake', '10.1.1',          :require => false
    # Latest rspec-puppet is required for coverage
    #gem 'rspec-puppet',            :git => 'https://github.com/rodjek/rspec-puppet.git'
    gem 'rspec-puppet',            :require => false
    gem 'puppetlabs_spec_helper',  :require => false
    gem 'puppet-lint',             :require => false

    # Ruby version specificities
    gem 'simplecov', :platforms => [:ruby_19, :ruby_20, :ruby_21], :require => false
    gem 'coveralls', :platforms => [:ruby_19, :ruby_20, :ruby_21], :require => false
    # Failures with ruby 1.8 and json_pure 2.x that requires ruby v2.x
    gem 'json_pure', '~> 1.8', :platforms => [:ruby_18, :ruby_19], :require => false
    # Failures with ruby 1.9 and json 2.x that requires ruby v2.x
    gem 'json', '~> 1.8', :platforms => [:ruby_19], :require => false
    # Failures with ruby 1.9 and tins 1.12.x that requires ruby v2.x
    gem 'tins', '1.6.0', :platforms => [:ruby_19], :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
    gem 'facter', facterversion, :require => false
else
    gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
else
    gem 'puppet', :require => false
end

# vim:ft=ruby tabstop=4 shiftwidth=4 softtabstop=4
