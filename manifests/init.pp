# == Class: serf
#
#   Downloads the serf binary from http://serfdom.io,
#   installs the appropriate init script,
#   and manages agent configuration
#
# === Parameters
#
# [*version*]
#   Specify version of serf binary to download. Defaults to '0.4.1'
#   http://serfdom.io does not currently provide a url for latest version.
#
# [*handlers_dir*]
#   Where to put the event handler scripts managed by this module.
#
# [*config_hash*]
#   Use this to populate the JSON config file for serf.
#
# [*install_method*]
#   Defaults to `url` but can be `package` if you want to install via a system package.
# 
# [*package_name*]
#   Only valid when the install_method == package. Defaults to `serf`.
# 
# [*package_ensure*]
#   Only valid when the install_method == package. Defaults to `present`.
# 
# === Examples
#
#  You can invoke this module with simply:
#
#  include serf
#
#  which is the equivalent of:
#
#  class { serf:
#    version => '0.4.1',
#    bin_dir => '/usr/local/bin'
#  }
#
# === Authors
#
# Justin Clayton <justin@claytons.net>
#
# === Copyright
#
# Copyright 2014 Justin Clayton, unless otherwise noted.
#
class serf (
  $version              = '0.4.1',
  $bin_dir              = '/usr/local/bin',
  $handlers_dir         = '/etc/serf/handlers',
  $arch                 = $serf::params::arch,
  $init_script_url      = $serf::params::init_script_url,
  $init_script_path     = $serf::params::init_script_path,
  $install_method       = $serf::params::install_method,
  $package_name         = $serf::params::package_name,
  $package_ensure       = $serf::params::package_ensure,
  $config_hash          = {}
) inherits serf::params {

  class { 'serf::install': } ~>

  file { 'config.json':
    path   => "/etc/serf/config.json",
    content => template('serf/config.json.erb'),
    notify  => Service['serf'],
  }

  service { 'serf':
    enable => true,
    ensure => running,
  }

}
