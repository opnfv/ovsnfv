$fuel_settings = parseyaml(file('/etc/astute.yaml'))
$master_ip = $::fuel_settings['master_ip']

#$adminrc_access = $::fuel_settings['access']
#$adminrc_user = $adminrc_access['user']
#$adminrc_password = $adminrc_access['password']
#$adminrc_tenant = $adminrc_access['tenant']
#$adminrc_public_ssl = $::fuel_settings['public_ssl']
#$adminrc_hostname = $adminrc_public_ssl['hostname']

if $operatingsystem == 'Ubuntu' {
  class { '::ovsdpdk':
    ovs_bridge_mappings => 'default:ens1f1',
    ovs_socket_mem      => '512,512',
    ovs_num_hugepages   => '2048',
    compute             => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
