# == Class: ovsdpdk::uninstall_ovs
#
# Provides uninstallation of openvswitch package (if present) together with removing of kernel module
#
class ovsdpdk::uninstall_ovs (
  $openvswitch_service_name = $::ovsdpdk::params::openvswitch_service_name,
  $openvswitch_agent        = $::ovsdpdk::params::openvswitch_agent,
  $install_packages         = $::ovsdpdk::params::install_packages,
) inherits ovsdpdk {

  #Due to dependencies to other packages, we won't purge vanilla OVS
  #package { $remove_packages: ensure => 'purged' }

  if $compute == 'True' {
    exec { "/usr/sbin/service ${openvswitch_service_name} stop":
      user   => root,
      path   => ["/usr/bin", "/bin", "/sbin"],
    }

    exec { "/usr/sbin/service ${openvswitch_agent} stop":
      user   => root,
      path   => ["/usr/bin", "/bin", "/sbin"],
    }

    exec { '/sbin/modprobe -r openvswitch':
      onlyif  => "/bin/grep -q '^openvswitch' '/proc/modules'",
      user    => root,
      require => Exec["/usr/sbin/service ${openvswitch_service_name} stop"],
    }
  }

  if $controller == 'True' {
    exec { '/usr/sbin/service neutron-server stop':
      user   => root,
      path   => ["/usr/bin", "/bin", "/sbin"],
      onlyif => "ps aux | grep -vws grep | grep -ws neutron-server",
    }
  }

  package { $install_packages: ensure => 'installed' }

}

