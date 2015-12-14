#!/bin/bash
##############################################################################
# Copyright (c) 2015 Red Hat Inc. and others.
# therbert@redhat.com
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

export BUILD_BASE=../build

if [ ! -d $BUILD_BASE ]
then
    mkdir $BUILD_BASE
fi

cd $BUILD_BASE
export TOPDIR=`pwd`

# build variables

export RELEASE_DIR=$TOPDIR/release
export CACHE_DIR=$TOPDIR/cache
export TMPDIR=$TOPDIR/scratch
export RPMDIR=$TOPDIR/rpmbuild

echo "Hello OVSNFV community!"

echo "Build OVS RPM from 2.5.90 master branch!"

mkdir -p $RPMDIR/BUILD
mkdir -p $RPMDIR/RPMS
mkdir -p $RPMDIR/SOURCES
mkdir -p $RPMDIR/SPECS
mkdir -p $RPMDIR/SRPMS

if [ ! -d $RELEASE_DIR ]
then
    mkdir -p $RELEASE_DIR
fi

# build prerequisites

#yum install gcc make python-devel openssl-devel kernel-devel graphviz \
#kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
#libtool

if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi

mkdir $TMPDIR

cd $TMPDIR

git clone https://github.com/openvswitch/ovs.git

cd ovs
./boot.sh
./configure
make dist

cd $TMPDIR/ovs
cp openvswitch-2.5.90.tar.gz $TOPDIR/rpmbuild/SOURCES
cp openvswitch-2.5.90.tar.gz $TMPDIR

cd $TMPDIR
tar -xzf openvswitch-2.5.90.tar.gz

cd $TMPDIR/openvswitch-2.5.90
rpmbuild -bb --define "_topdir `echo $RPMDIR`" --without check rhel/openvswitch.spec
#rpmbuild -bb --define "_topdir `echo $RPMDIR`" rhel/openvswitch.spec

# copy product.

echo cp $RPMDIR/RPMS/*.rpm $RELEASE_DIR
cp $RPMDIR/RPMS/x86_64/*.rpm $RELEASE_DIR

# cleanup

if [ -d $TMPDIR ]
then
    echo rm -rf $TMPDIR
    rm -rf $TMPDIR
fi

exit 0
