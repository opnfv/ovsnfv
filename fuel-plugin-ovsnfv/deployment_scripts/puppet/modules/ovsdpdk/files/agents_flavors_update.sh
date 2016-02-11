#!/usr/bin/env bash

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

set -x

# access openstack cli
source /root/openrc

sleep 10
neutron agent-list

# Force update of vswitch agents
for i in `neutron agent-list | grep "Open vSwitch agent" | awk {'print $2'}`; do
  neutron agent-update $i
done

sleep 10
neutron agent-list

# grep id and remove dead agent on all compute nodes
for i in `nova host-list | grep compute | awk {'print $2'}`; do
  dead_agent_id=`neutron agent-list | grep $i | grep xxx | grep "Open vSwitch agent" | awk {'print $2'}`
  neutron agent-delete $dead_agent_id
done

# modify flavors
for i in `nova flavor-list | grep m1 | awk {'print $4'}`; do
  nova flavor-key $i set "hw:mem_page_size=large"
done

set +x
