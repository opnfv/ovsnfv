$fuel_settings = parseyaml(file('/etc/astute.yaml'))
$master_ip = $::fuel_settings['master_ip']

if $operatingsystem == 'Ubuntu' {
  class { '::ovsdpdk':
    ovs_bridge_mappings => '',
    ovs_socket_mem      => '512',
    ovs_num_hugepages   => '256',
    controller          => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
