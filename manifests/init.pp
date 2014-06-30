class grafana (
  $version         = '1.6.1',
  $destination_dir = '/usr/local/grafana',
  $tmp             = '/tmp',
) {

  validate_string($user)
  validate_absolute_path($destination_dir)
  validate_absolute_path($tmp)

  ensure_packages(['wget'])

  file { 'grafana home':
    ensure => 'directory',
    path   => $destination_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  exec { 'download grafana':
    cwd     => $tmp,
    path    => '/sbin:/bin:/usr/bin',
    command => "wget http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz",
    creates => "${tmp}/grafana-${version}.tar.gz",
    require => Package['wget'],
  }

  exec { 'untar grafana':
    cwd     => $tmp,
    path    => '/sbin:/bin:/usr/bin',
    command => "tar -zxvf grafana-${version}.tar.gz",
    creates => "${tmp}/grafana-${version}/index.html",
    require => Exec['download grafana'],
  }

  exec { 'move to dest':
    cwd     => $tmp,
    path    => '/sbin:/bin:/usr/bin',
    command => "\\cp -rfT grafana-${version} ${destination_dir}",
    creates => "${destination_dir}/index.html",
    require => [Exec['untar grafana'], File['grafana home']],
  }
}
