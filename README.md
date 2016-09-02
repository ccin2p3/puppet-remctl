#remctl

[![Puppet Forge](https://img.shields.io/puppetforge/v/ccin2p3/remctl.svg)](https://forge.puppet.com/ccin2p3/remctl)
[![Puppet Forge Download](https://img.shields.io/puppetforge/dt/ccin2p3/remctl.svg)](https://forge.puppet.com/ccin2p3/remctl)
[![Build Status](https://travis-ci.org/ccin2p3/puppet-remctl.svg?branch=master)](https://travis-ci.org/ccin2p3/puppet-remctl)

####Table of Contents

1. [Overview - What is the remctl module](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Module Versioning - What version numbers means](#module-versioning)
4. [Setup - The basics of getting started with remctl](#setup)
    * [What remctl affects](#what-remctl-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with remctl](#beginning-with-remctl)
5. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: remctl](#class-remctl)
        * [Class: remctl::client](#class-remctlclient)
        * [Class: remctl::server](#class-remctlserver)
        * [Defined Type: remctl::server::aclfile](#defined-type-remctlserveraclfile)
        * [Defined Type: remctl::server::command](#defined-type-remctlservercommand)
6. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
        * [Public Classes](#public-classes)
        * [Private Classes](#private-classes)
    * [Defined Types](#defined-types)
        * [Public defined types](#public-defined-types)
7. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The remctl module allows you to:
* install remctl client through puppet manifests.
* set up remctl server through xinetd.
* manage remctl command and ACL files via puppet manifests.

##Module Description

[remctl](http://www.eyrie.org/~eagle/software/remctl/) is a client/server application that supports remote execution of specific commands, using Kerberos GSS-API for authentication and confidentiality.
This module provides simplified way to deploy server, command and ACL files.

##Module Versioning

This module adheres to [Semantic versioning](http://semver.org/) and it's version numbers use the format _X.Y.Z_, where:

* _X_ must increase for major backwards-incompatible changes
* _Y_ must increase for backwards-compatible new functionality
* _Z_ must increase for bug fixes

##Setup

###What remctl affects

* configuration files and directories (created and written to) 
* package and configuration files for remctl
* xinetd service
* listened-to ports

###Requirements

* [puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib.git)
* [puppetlabs-xinetd](https://github.com/puppetlabs/puppetlabs-xinetd.git)

###Beginning with remctl    

To install remctl client

```puppet
    class { 'remctl::client':
        ensure      => present
    }
```

To install remctl server

```puppet
    class { 'remctl::server':
        ensure          => present,
        debug           => false,
        only_from       => [ '0.0.0.0' ],
        disable         => false
    } 
```

To create an ACL file

```puppet
    remctl::server::aclfile { 'administrators':
        ensure          => present,
        acls            => ['pcre:.+/admin@TEST.REALM.ORG']
    }
```

To create a new puppet managed command

```puppet
    remctl::server::command { 'reboot':
        command         => 'reboot',
        subcommand      => 'ALL',
        executable      => '/sbin/reboot',
        options         => {
            'help'  => '--help',
        },
        acls            => ["file:${remctl::server::acldir}/administrators"],
        ensure          => present,
    }
```

To create multiple subcommands

```puppet
    remctl::server::command { 'kadmin_cpw':
        command         => 'kadmin',
        subcommand      => 'change_password',
        executable      => '/usr/sbin/kadmin',
        options         => {
            'help'      => '--help',
            'summary'   => '--summary',
        },
        acls            => ['ANYUSER']
    }

    remctl::server::command { 'kadmin_lock':
        command         => 'kadmin',
        subcommand      => 'lock_user',
        executable      => '/usr/sbin/kadmin',
        options         => {
            'help'      => '--help',
            'summary'   => '--summary',
        },
        acls            => ['princ:admin@EXAMPLE.ORG']
    }
```

To use with hiera, write in your puppet manifest

```
include ::remctl::server
```

and in your hiera file

```yaml
---
remctl::server::ensure: present
remctl::server::disable: false
remctl::server::only_from:
  - '0.0.0.0'
remctl::server::commands:
  'kadmin_lock':
    command     : 'kadmin'
    subcommand  : 'lock_user'
    executable  : '/usr/sbin/kadmin'
    options     :
      'help'    : '--help'
      'summary' : '--summary'
    acls        :
      - 'princ:admin@EXAMPLE.ORG'
```

##Usage


###Classes and Defined Types

####Class: `remctl`

Base class that actually does nothing anymore.

**Parameters within `remctl`:**

####Class: `remctl::client`

This class is used to install remctl client.

**Parameters within `remctl::client`:**

#####`ensure`

`ensure` property, passed to puppet `package` type.

#####`package_name`

Name of package to be installed. Defaults to:

* `remctl` on RedHat `osfamily`
* `remctl-client` on Debian `osfamily`

####Class: `remctl::server`

This class is used to install remctl server and configure it through xinetd.
This class MUST be declared in order to be able to use ACL or command types.

**Parameters within `remctl::server`:**

#####`ensure`
`ensure` property, passed to `xinetd::service` and `package`. Defaults to `present`.

#####`package_name`

Name of package to be installed. Defaults to:

* `remctl` on RedHat `osfamily`
* `remctl-server` on Debian `osfamily`

#####`debug`

Enable verbose debug logging (see `remctld(8)` `-d` option). Defaults to `false`.

#####`disable`

Disable remctl xinetd service. Defaults to `true`.

#####`krb5_service`

Specifies which principal is used as the server identity for client authentication (see `remctld(8)` `-s` option). By default, remctld accepts any principal with a key in the specified keytab file.

#####`krb5_keytab`

Specifies keytab to use as the keytab for server credentials rather than the system default or the value of the KRB5_KTNAME environment variable (see `remctld(8)` `-k` option). Defaults to `undef`.

#####`port`

Specifies port to use. Defaults to `4373`.

#####`user`

User to run remctl xinetd service as. Defaults to `root`.

#####`group`

Group to run remctl xinetd service as. Defaults to `root`.

#####`manage_user`

Should we ensure that `user` and `group` are present / absent.
If `manage_user` is set to `true` and user or group is root or zero, this module behaves like if `manage_user` was set to `false`.

#####`only_from`

List of remote hosts that are allowed to access remctl service (see `xinetd.conf(5)` `only_from` option for format). Defaults to `[ '0.0.0.0' ]`.

#####`no_access`

List of remote hosts that are not allowed to access remctl service (see `xinetd.conf(5)` `no_access` option for format). Defaults to `[]`.

#####`bind`

Allows a service to be bound to a specific interface on the machine (see `xinetd.conf(5)` `bind` or `interface` option for format). Defaults to `undef`.

##### `commands`

List of [remctl::server::command](#defined-type-remctlservercommand) that will be passed to `create_resources()`.

##### `aclfiles`

List of [remctl::server::aclfile](#defined-type-remctlserveraclfile) that will be passed to `create_resources()`.

####Defined Type: `remctl::server::aclfile`

remctl ACL file resource type.
This class should be used to describe a set of resources that will be granted access to a set of remctl commands.
Class `remctl::server` must have been included before using this defined type.

**Parameters within `remctl::server::aclfile`:**

#####`ensure`

State of the aclfile resource. Defaults to `present`.

#####`acldir`

Directory where we want to save aclfile. This must be an absolute path. Defaults to `/etc/remctl.d`.

#####`acls`

Array of ACLs as desribed in `remctld(8)` `acl` section.

####Defined Type: `remctl::server::command`

remctl command file resource type.
This class should be used to describe a command that will be available through the remctl interface.

**Parameters within `remctl::server::command`:**

#####`command`

Required. command as described in `remctld(8)` `command` section.

#####`subcommand`

Required. subcommand as described in `remctld(8)` `subcommand` section.

#####`executable`

Required. executable as described in `remctld(8)` `executable` section. Must be an absolute path.

#####`options`

Hash of options as described in `remctld(8)` `option=value` section. Defaults to `{}`.

```puppet
    remctl::server::command { 'reboot':
        [...],
        options         => {
            help    => '--help',
            summary => '--summary',
            user    => 'remctl'
        },
    }
```

#####`acls`

Array of acls as desribed in `remctld(8)` `acl` section.

```puppet
    remctl::server::command { 'reboot':
        [...],
        acls        => ['princ:testuser@TEST.REALM.ORG'],
    }
```


##Reference

###Classes

####Public Classes

* [`remctl`](#class-remctl): This class actually does nothing.
* [`remctl::client`](#class-remctlclient): Installs remctl client.
* [`remctl::server`](#class-remctlserver): Installs, configures remctl server through xinetd and handles configuration file.

####Private Classes

* `remctl::params`: Manages remctl parameters.

###Defined Types

####Public Defined Types

* [`remctl::server::aclfile`](#defined-type-remctlserveraclfile): Creates an ACL file compliant with remctl ACL file format.
* [`remctl::server::command`](#defined-type-remctlservercommand): Creates a new command definition.

##Limitations

This module currently only works on `RedHat` and `Debian` os families and expects that the `remctl*` packages are available with your current repository configuration.

All xinetd options were not exposed through the `remctl::server` class. If you need a specific xinetd option, please file a bug report and we'll add it.

## Contributing

Found a bug or simply have a new idea / new feature ? External contributions are welcome.

Please read the [contribution guide](CONTRIBUTING.md) to see how to contribute.
