# Copyright 2015 Open Platform for NFV Project, Inc. and its contributors
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

