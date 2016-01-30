#!/usr/bin/env  bash

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

# Small script for calculation of cores not suitable for deployment
# of VM's and adaptation of nova.conf accordingly
# nova.conf path should come as first param
# this should be executed when nova is enabled and already configured

source /etc/default/ovs-dpdk

OVS_CORE_MASK=$(echo $OVS_CORE_MASK | sed 's/^0x//')
OVS_PMD_CORE_MASK=$(echo $OVS_PMD_CORE_MASK | sed 's/^0x//')
BAD_CORES=$((`echo $((16#${OVS_CORE_MASK}))` | `echo $((16#${OVS_PMD_CORE_MASK}))`))
TOTAL_CORES=`nproc`
vcpu_pin_set=""

for cpu in $(seq 0 `expr $TOTAL_CORES - 1`);do
    tmp=`echo 2^$cpu | bc`
    if [ $(($tmp & $BAD_CORES)) -eq 0 ]; then
        vcpu_pin_set+=$cpu","
    fi
done
vcpu_pin_set=${vcpu_pin_set::-1}

crudini --set $1 DEFAULT vcpu_pin_set $vcpu_pin_set
