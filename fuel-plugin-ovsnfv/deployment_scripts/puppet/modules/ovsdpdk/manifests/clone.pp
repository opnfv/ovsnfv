# == Class: ovsdpdk::clone
#
# Responsible for downloading all relevant git repos for setting up of OVS+DPDK
#
class ovsdpdk::clone(
  $dest                    = $::ovsdpdk::params::dest,
  $ovs_dir                 = $::ovsdpdk::params::ovs_dir,
  $ovs_dpdk_dir            = $::ovsdpdk::params::ovs_dpdk_dir,
  $networking_ovs_dpdk_dir = $::ovsdpdk::params::networking_ovs_dpdk_dir,
  $ovs_git_tag             = $::ovsdpdk::params::ovs_git_tag,
  $ovs_dpdk_git_tag        = $::ovsdpdk::params::ovs_dpdk_git_tag,
  $ovs_plugin_git_tag      = $::ovsdpdk::params::ovs_plugin_git_tag,
  $master_ip               = $::ovsdpdk::params::master_ip,
) inherits ovsdpdk {

  file { $dest:
    ensure => directory,
    mode   => '0755',
  }

  package { 'git':
    ensure   => installed,
  }

  package { 'python-pip':
    ensure   => installed,
  }

  exec { "wget dpdk":
    command => "rm -rf dpdk.tgz $ovs_dpdk_dir && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/dpdk.tgz && tar xf dpdk.tgz && mv dpdk $ovs_dpdk_dir",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  }

  exec { "wget ovs":
    command => "rm -rf ovs.tgz $ovs_dir && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/ovs.tgz && tar xf ovs.tgz && mv ovs $ovs_dir",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  }

  exec { "wget networking_ovs_dpdk":
    command => "rm -rf networking-ovs-dpdk.tgz $networking_ovs_dpdk_dir && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/networking-ovs-dpdk.tgz && tar xf networking-ovs-dpdk.tgz && mv networking-ovs-dpdk $networking_ovs_dpdk_dir",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  }

  exec { "install pbr":
    command => "wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/pbr-1.8.1-py2.py3-none-any.whl && pip install pbr-1.8.1-py2.py3-none-any.whl",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => Package['python-pip'],
  }
}
