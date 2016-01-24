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
        p)
            OVS_PATCH=${OPTARG}
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

sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
       kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
       libtool

VERSION=2.3.90
os_type=rhel6
kernel_version=$(uname -a | awk '{print $3}')

mkdir -p $TMPDIR

cd $TMPDIR

mkdir -p $HOME/rpmbuild/RPMS
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS

RPMDIR=$HOME/rpmbuild


echo "---------------------"
echo "Clone git repo $OVS_REPO_URL and checkout branch or tag $TAG"
echo
git clone $OVS_REPO_URL

cd ovs
echo "--------------------"
echo "Checkout OVS $TAG"
echo
if [[ ! "$TAG" =~ "master" ]]; then
    git checkout $TAG
fi
if [[ ! "$OVS_PATCH" =~ "no" ]]; then
    echo "Apply patches from $OVS_PATCH"
fi
./boot.sh
if [ ! -z $DPDK ]; then
    ./configure --with-dpdk
else
    ./configure --with-linux=/lib/modules/`uname -r`/build
fi
echo "--------------------"
echo "Make OVS $TAG"
echo
make

if [[ "$TAG" =~ "master" ]]; then
    v=$($TMPDIR/ovs/utilities/ovs-vsctl --version | head -1 | cut -d' ' -f4)
    export VERSION=$v
else
    export VERSION=${TAG:1}
fi

echo making RPM for Open vswitch version $VERSION
make dist

echo cp openvswitch-*.tar.gz $HOME/rpmbuild/SOURCES
cp openvswitch-*.tar.gz $HOME/rpmbuild/SOURCES

if [ ! -z $kmod ]; then
    echo "Building kernel module..."
    rpmbuild -bb -D "kversion $kernel_version" -D "kflavors default" --define "_topdir `echo $RPMDIR`" --without check rhel/openvswitch-kmod-${os_type}.spec
echo " Kernel RPM built!"
fi

echo "Building User Space..."
rpmbuild -bb --define "_topdir `echo $RPMDIR`" --without check rhel/openvswitch.spec

cp $RPMDIR/RPMS/x86_64/*.rpm $HOME

exit 0
