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

# == Class: ovsdpdk::build_ovs_dpdk
#
# It executes build of OVS with DPDK support from configured shell script
#
class ovsdpdk::build_ovs_dpdk (
  $plugin_dir =  $::ovsdpdk::params::plugin_dir,
) inherits ovsdpdk {
  require ovsdpdk::uninstall_ovs

  file {"${plugin_dir}/files/build_ovs_dpdk.sh":
    content => template("${plugin_dir}/files/build_ovs_dpdk.erb"),
    mode    => '0775',
  }

  exec {"${plugin_dir}/files/build_ovs_dpdk.sh":
    require => File["${plugin_dir}/files/build_ovs_dpdk.sh"],
    timeout => 0,
  }
}

