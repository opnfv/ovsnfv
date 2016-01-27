$fuel_settings = parseyaml(file('/etc/astute.yaml'))
$master_ip = $::fuel_settings['master_ip']

if $operatingsystem == 'Ubuntu' {
  class { '::ovsdpdk':
    ovs_bridge_mappings => 'default:ens1f1',
    ovs_socket_mem      => '512,512',
    ovs_num_hugepages   => '2048',
    compute             => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
