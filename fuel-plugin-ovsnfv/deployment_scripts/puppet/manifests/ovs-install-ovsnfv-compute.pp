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

$fuel_settings = parseyaml(file('/etc/astute.yaml'))
$master_ip = $::fuel_settings['master_ip']

$ovs_ifname = $::fuel_settings[fuel-plugin-ovsnfv][fuel-plugin-ovsnfv_text]

if $operatingsystem == 'Ubuntu' {
  class { '::ovsdpdk':
    ovs_bridge_mappings => "default:$ovs_ifname",
    ovs_socket_mem      => '512,512',
    ovs_num_hugepages   => '2048',
    compute             => 'True',
  }
} elsif $operatingsystem == 'CentOS' {
}
