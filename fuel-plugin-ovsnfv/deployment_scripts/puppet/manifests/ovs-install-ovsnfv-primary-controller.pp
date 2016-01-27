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
    controller          => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
