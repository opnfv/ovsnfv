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
    require => File[$dest],
  }

  exec { "wget ovs":
    command => "rm -rf ovs.tgz $ovs_dir && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/ovs.tgz && tar xf ovs.tgz && mv ovs $ovs_dir",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => File[$dest],
  }

  exec { "wget networking_ovs_dpdk":
    command => "rm -rf networking-ovs-dpdk.tgz $networking_ovs_dpdk_dir && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/networking-ovs-dpdk.tgz && tar xf networking-ovs-dpdk.tgz && mv networking-ovs-dpdk $networking_ovs_dpdk_dir",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => File[$dest],
  }

  exec { "wget qemu":
    command => "rm -rf qemu-2.2.1.tar.bz2 /opt/code/qemu && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/qemu-2.2.1.tar.bz2 && tar xf qemu-2.2.1.tar.bz2 && mv qemu-2.2.1 /opt/code/qemu",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => File[$dest],
  }

  exec { "wget libvirt":
    command => "rm -rf libvirt-1.2.12.tar.gz /opt/code/libvirt && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/libvirt-1.2.12.tar.gz && tar xf libvirt-1.2.12.tar.gz && mv libvirt-1.2.12 /opt/code/libvirt",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => File[$dest],
  }

  exec { "wget libvirt-python":
    command => "rm -rf libvirt-python-1.2.12.tar.gz /opt/code/libvirt-python && wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/libvirt-python-1.2.12.tar.gz && tar xf libvirt-python-1.2.12.tar.gz && mv libvirt-python-1.2.12 /opt/code/libvirt-python",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => File[$dest],
  }

  exec { "install pbr":
    command => "wget http://$master_ip:8080/plugins/fuel-plugin-ovsnfv-0.0/repositories/ubuntu/pbr-1.8.1-py2.py3-none-any.whl && pip install pbr-1.8.1-py2.py3-none-any.whl",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    require => Package['python-pip'],
  }
}
