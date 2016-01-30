# Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# == Class ovsdpdk::postinstall_ovs_dpdk
#
# Postinstall configuration of ovs-dpdk service
#
class ovsdpdk::postinstall_ovs_dpdk (
  $plugin_dir               = $::ovsdpdk::params::plugin_dir,
  $nova_conf                = $::ovsdpdk::params::nova_conf,
  $openvswitch_service_name = $::ovsdpdk::params::openvswitch_service_name,
  $ml2_conf                 = $::ovsdpdk::params::ml2_conf,
  $ml2_ovs_conf             = $::ovsdpdk::params::ml2_ovs_conf,
  $neutron_l3_conf          = $::ovsdpdk::params::neutron_l3_conf,
  $openvswitch_agent        = $::ovsdpdk::params::openvswitch_agent,
) inherits ovsdpdk {

  require ovsdpdk::install_ovs_dpdk

  package {'crudini': ensure => installed }

  # compute node specific changes
  if $compute == 'True' {
    # adapt configuration files
    exec {'adapt_nova_conf':
      command => "${plugin_dir}/files/set_vcpu_pin.sh ${nova_conf}",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${nova_conf}",
      require => Package['crudini'],
    }

    exec {'adapt_ml2_conf_datapath':
      command => "sudo crudini --set ${ml2_conf} ovs datapath_type ${ovs_datapath_type}",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${ml2_conf}",
      require => Package['crudini'],
    }

    exec {'adapt_ml2_conf_agent_type':
      command => "sudo crudini --set ${ml2_conf} agent agent_type 'DPDK OVS Agent'",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${ml2_conf}",
      require => Package['crudini'],
    }

    exec {'adapt_neutron_l3':
      command => "sudo crudini --set ${neutron_l3_conf} DEFAULT external_network_bridge br-ex",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${neutron_l3_conf}",
      require => Package['crudini'],
    }


    service {"${openvswitch_service_name}": ensure => 'running' }

    # restart OVS to synchronize ovsdb-server with ovs-vswitchd needed
    # due to several new --no-wait entries
    exec {'restart_ovs':
      command => "/usr/sbin/service ${openvswitch_service_name} restart",
      user    => root,
      require => Service["${openvswitch_service_name}"],
    }

    exec {'configure_bridges':
      command => "${plugin_dir}/files/configure_bridges.sh ${ovs_datapath_type}",
      user    => root,
      require => Exec['restart_ovs'],
    }

    service { 'libvirtd': ensure => running }

    exec {'libvirtd_disable_tls':
      command => "sudo crudini --set /etc/libvirt/libvirtd.conf '' listen_tls 0",
      path    => ['/usr/bin','/bin'],
      user    => root,
      require => Package['crudini'],
      notify  => Service['libvirtd'],
    }

    exec {'restart_nova_compute':
      command => "/usr/sbin/service nova-compute restart",
      user    => root,
      require => [ Exec['libvirtd_disable_tls'], Service['libvirtd'] ],
    }

    service {"${openvswitch_agent}":
      ensure  => 'running',
      require => [ Exec['restart_ovs'], Service["${openvswitch_service_name}"], Exec['adapt_ml2_conf_datapath'], Exec['adapt_ml2_conf_agent_type']  ],
    }

    exec { "ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=${ovs_pmd_core_mask}":
      path    => ['/usr/bin','/bin'],
      user    => root,
      require => Service["${openvswitch_agent}"],
    }
  }

  # controller specific part
  if $controller == 'True' {
    service {'neutron-server':
      ensure => 'running',
    }

    exec {'append_NUMATopologyFilter':
      command => "sudo crudini --set ${nova_conf} DEFAULT scheduler_default_filters RetryFilter,AvailabilityZoneFilter,RamFilter,\
CoreFilter,DiskFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,NUMATopologyFilter",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${nova_conf}",
      require => Package['crudini'],
    }

    exec { 'agents_flavors_update':
      command => "${plugin_dir}/files/agents_flavors_update.sh",
      user      => 'root',
      logoutput => 'true',
      timeout   => 0,
      require   => [ Service['neutron-server'], Exec['append_NUMATopologyFilter'] ],
    }

    exec {'restart_neutron_server':
      command => "/usr/sbin/service neutron-server restart",
      user    => root,
      require => Exec['agents_flavors_update'],
    }

    exec {'restart_nova_scheduler':
      command => "/usr/sbin/service nova-scheduler restart",
      user    => root,
      require => Exec['agents_flavors_update'],
    }

  }

  # common part
  exec {'adapt_ml2_conf_mechanism_driver':
    command => "sudo crudini --set ${ml2_conf} ml2 mechanism_drivers ovsdpdk",
    path    => ['/usr/bin','/bin'],
    user    => root,
    onlyif  => "test -f ${ml2_conf}",
    require => Package['crudini'],
  }

  exec {'adapt_ml2_conf_security_group':
    command => "sudo crudini --set ${ml2_conf} securitygroup firewall_driver neutron.agent.firewall.NoopFirewallDriver",
    path    => ['/usr/bin','/bin'],
    user    => root,
    onlyif  => "test -f ${ml2_conf}",
    require => Package['crudini'],
  }
}
