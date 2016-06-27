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

echo "==============================="
echo "Requires sudo privileges"
echo executing $0 $@
echo executing on machine `uname -a`


usage() {
    echo $0 [-d] [-k]
    -d -- Test with DPDK
    -k -- Load linux kernel module
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

while getopts "dg:hkp:u:v" opt; do
    case "$opt" in
        d)
            DPDK="yes"
            ;;
        g)
            TAG=${OPTARG}
            ;;
        h|\?)
            usage
            exit 1
            ;;
        k)
            kmod="yes"
            ;;
        u)
            OVS_REPO_URL=${OPTARG}
            ;;
        v)
            verbose="yes"
            ;;
    esac
done

HOME=`pwd`
TOPDIR=$HOME
TMPDIR=$TOPDIR/ovsrpm

if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi

mkdir -p $TMPDIR

cd $TMPDIR

mkdir -p $HOME/rpmbuild/RPMS/x86_64
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS

RPMDIR=$HOME/rpmbuild
cp $HOME/*.rpm $RPMDIR/RPMS/x86_64

function stopovs() {
    set +e
    /bin/systemctl is-active openvswitch.service
    if [ $? -eq 0 ]; then
        sudo /bin/systemctl stop openvswitch.service
    fi
    set -e
}

echo "-----------------------------------"
echo "Clean old dpdk and ovs installations"
echo
stopovs
cleanrpms

if [ ! -z $DPDK ]; then
    if [ -z $DPDK_VERSION ]; then
        DPDK_VERSION=16.04.0
    fi
    echo "-----------------------------------"
    echo "Install DPDK RPMs for version $DPDK_VERSION"
    echo
    sudo rpm -ivh $RPMDIR/RPMS/x86_64/dpdk-${DPDK_VERSION:0:1}*.rpm
    sudo rpm -ivh $RPMDIR/RPMS/x86_64/dpdk-tools-${DPDK_VERSION:0:1}*.rpm
    sudo rpm -ivh $RPMDIR/RPMS/x86_64/dpdk-examples-${DPDK_VERSION:0:1}*.rpm
fi

if [ ! -z $kmod ]; then
    echo "-----------------------------------"
    echo "Test installation of kmod RPM"
    echo
    sudo rpm -ivh $RPMDIR/RPMS/x86_64/openvswitch-kmod*.rpm
fi
echo "-----------------------------------"
echo "Test installation of user space RPM"
echo
sudo rpm -ivh $RPMDIR/RPMS/x86_64/openvswitch-2*.rpm

echo "-----------------------------------"
echo "Start openvswitch service."
echo
sudo service openvswitch start

sudo ovs-vsctl show
sudo ovs-vsctl add-br brtest
sudo ovs-ofctl dump-flows brtest
sudo ovs-vsctl del-br brtest
sudo service openvswitch stop
uninstallrpms

exit 0
