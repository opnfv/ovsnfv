$fuel_settings = parseyaml(file('/etc/astute.yaml'))
$master_ip = $::fuel_settings['master_ip']

if $operatingsystem == 'Ubuntu' {
  class { '::ovsdpdk':
    controller          => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
