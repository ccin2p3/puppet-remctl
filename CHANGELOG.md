#### 2014-08-20 - Remi Ferrand <puppet@cc.in2p3.fr> - 2.1.1
##### Bugfixes
* Fixes inexistent parameter `ensure` on type `concat` introduced in puppetlabs-concat v1.1.0. This module is meant to support puppetlabs-concat v1.x and versions prior to v1.1.0 do not have parameter `ensure` in ̀̀`concat` type. Until puppetlabs officially supports puppetlabs-concat v1.1.x, there is actually no way to completely remove a command file created with this remctl module. The command will no longer be available through remctl but an empty file will remain (only with puppet headers).

#### 2014-05-23 - Remi Ferrand <puppet@cc.in2p3.fr> - 2.1.0
##### Bugfixes
* Fixes random sort changes in command files when using multiple `options` was specified (https://github.com/ccin2p3/puppet-remctl/issues/11).

##### New features
* Now relies on `puppetlabs-concat` to concat all subcommands of a command in the same file.

#### 2014-05-16 - Remi Ferrand <puppet@cc.in2p3.fr> - 2.0.0
##### Bugfixes
* Fixed duplicate resource declaration when client is included before server 
(https://github.com/ccin2p3/puppet-ccin2p3-remctl/issues/10).
* Fixed bug causing `krb5_keytab` to be ignored when specified.

##### New features
* Enforce common interface and introduce the `ensure` parameter for all classes that allows one to cleanup
classes, packages, commands and acls.
* Add more xinetd security restriction options to remctl `xinetd::service` (xinetd `bind` and `no_access`).

##### Incompatibility with previous version
 * Enforcing parameter `ensure` to all classes requires us to rename old parameters (`package_ensure` and so on).
 * In `remctl::server::command`, parameter `acls` is now mandatory (old behavior was irrelevant).
 * In `remctl::server`, parameter `manage_group` was removed. Group is now managed if `manage_user` is
set to ̀`true`.

#### 2014-04-16 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.1.1
##### Bugfixes
* Fix duplicate package declaration on RedHat osfamily when client and server were
defined (Thank you A. Ntaflos for reporting this)

#### 2014-04-11 - Remi Ferrand <puppet@cc.in2p3.fr> - 1.1.0
##### New features
* subcommands array
* dedicated `remctl::client` class

##### Bugfixes
* This version allow usage of subcommands array (one command with multiple subcommands,
  each with specific options or ACL) which was previously impossible.
* `/etc/services` is left untouched if user specifies a non standard remctl port.

##### Known bugs
* Adding support for *subcommand arrays* requires us to add a mandatory `command`
parameter to `remctl::server::command` class. Users of prior versions must fix their manifest
or puppet will complain about a mandatory parameter that is missing.
* Usage of puppet `undef` value could make this module imcompatible with puppet 2.x.

##### TODO
* Write proper `rspec` test suite
