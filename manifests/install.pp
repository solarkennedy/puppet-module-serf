# == Class: serf::install
#
class serf::install {

  if $serf::install_method == 'url' {

    $download_url = "https://dl.bintray.com/mitchellh/serf/${serf::version}_linux_${serf::arch}.zip"
    staging::file { 'serf.zip':
      source => $download_url,
    } ->
    staging::extract { 'serf.zip':
      target  => $serf::bin_dir,
      creates => "${serf::bin_dir}/serf",
    } ->
    file { [$serf::handlers_dir, '/etc/serf']:
      ensure  => directory,
    }

  } elsif $serf::install_method == 'package' {

    package { $serf::package_name:
      ensure => $serf::package_ensure
    }

  } else {
    fail("The provided install method ${serf::install_method} is invalid")
  }

  # The init script is installed regardless of the install_method
  staging::file { $serf::init_script_path:
    source => $serf::init_script_url,
    target => $serf::init_script_path,
  } ->
  file { $serf::init_script_path:
    mode    => '0755',
    notify  => Service['serf'],
  }

}
