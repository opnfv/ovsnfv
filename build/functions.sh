#!/bin/bash

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

set -e

usage() {
    echo $0 [-d] [-k]
    echo -d -- Test with DPDK
    echo -k -- Load linux kernel module
}

function delrpm() {
    set +e
    rpm -q $1
    if [ $? -eq 0 ]; then
        sudo rpm -e --allmatches $1
    fi
    set -e
}
function cleanrpms() {
    delrpm openvswitch
    delrpm dpdk-devel
    delrpm dpdk-tools
    delrpm dpdk-examples
    delrpm dpdk
}
function uninstallrpms() {
    cleanrpms
}
