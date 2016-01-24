#!/bin/bash
##############################################################################
# Copyright (c) 2016 Red Hat Inc. and others.
# therbert@redhat.com
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -e
declare -i CNT

echo "==============================="
echo executing $0 $@
echo executing on machine `uname -a`


usage() {
    echo run buildtestovs.sh -h for help
}

while getopts "dg:hp:u:v" opt; do
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

mkdir -p $HOME/rpmbuild/RPMS
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS

RPMDIR=$HOME/rpmbuild

echo " Testing installation of kmod RPM"
if [ ! -z $kmod ]; then
    echo "Install kernel module"
    sudo rpm -ivh $RPMDIR/kmod*.rpm
    echo " Kernel RPM installed."
fi
echo "Testing User Space RPM"
sudo rpm -ivh $RPMDIR/RPMS/x86_64/*.rpm

sudo service openvswitch start

sudo ovs-vsctl show
sudo ovs-vsctl add-br br1
sudo ovs-ofctl dump-flows br1

exit 0
