#!/bin/bash
##############################################################################
# Copyright (c) 2015 Red Hat Inc. and others.
# therbert@redhat.com
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# Check to verify that I am being run by Jenkins CI.

if [ -z ${WORKSPACE+1} ]; then
    # We are not being run by Jenkins.
    export WORKSPACE=$HOME/opnfv/ovsnfv
fi


if [ -z ${OVSTAG+1} ]; then
    export TAG=master
else
    export TAG=$OVSTAG
fi

export DATE=`date +%Y-%m-%d`

export BUILD_BASE=$WORKSPACE/build



if [ ! -d $BUILD_BASE ]
then
    mkdir -p $BUILD_BASE
fi

if [ ! -f $BUILD_BASE/config ]; then
    touch $BUILD_BASE/config
fi

export PATH=$PATH:$WORKSPACE/ci:$BUILD_BASE

source $BUILD_BASE/config

cd $BUILD_BASE
export TOPDIR=$BUILD_BASE

# build variables

export TMP_RELEASE_DIR=$TOPDIR/release
export CACHE_DIR=$TOPDIR/cache
export TMPDIR=$TOPDIR/scratch
export RPMDIR=$TOPDIR/rpmbuild

echo "--------------------------------------------------"
echo "Build OVS RPM from upstream git $TAG"
echo

mkdir -p $RPMDIR/RPMS
mkdir -p $RPMDIR/SOURCES
mkdir -p $RPMDIR/SPECS
mkdir -p $RPMDIR/SRPMS

if [ ! -d $TMP_RELEASE_DIR ]
then
    mkdir -p $TMP_RELEASE_DIR
fi

# Centos build server should support the following build prerequisites

# yum install gcc make python-devel openssl-devel kernel-devel graphviz \
# kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
# libtool

if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi

mkdir $TMPDIR

cd $TMPDIR

echo "---------------------"
echo "Clone git repo $TAG"
echo
git clone https://github.com/openvswitch/ovs.git

cd ovs
echo "--------------------"
echo "Checkout OVS $TAG"
echo
if [[ ! "$TAG" =~ "master" ]]; then
    git checkout $TAG
fi
./boot.sh
./configure
echo "--------------------"
echo "Make OVS $TAG"
echo
make
#
# Get version for master
#
echo "--------------------"
echo "Get OVS version for $TAG"
echo
if [[ "$TAG" =~ "master" ]]; then
    v=$($TMPDIR/ovs/utilities/ovs-vsctl --version | head -1 | cut -d' ' -f4)
    export VERSION=$v
else
    export VERSION=${TAG:1}
fi

echo "--------------------"
echo "OVS version is $VERSION"
echo
echo "--------------------"
echo "Make OVS distribution $TAG"
echo

make dist

cd $TMPDIR/ovs

cp openvswitch-$VERSION.tar.gz $TOPDIR/rpmbuild/SOURCES
cp openvswitch-$VERSION.tar.gz $TMPDIR

cd $TMPDIR
tar -xzf openvswitch-$VERSION.tar.gz

cd $TMPDIR/openvswitch-$VERSION


echo "--------------------"
echo "Build OVS RPM"
echo

if [ ! -z ${NOCHECK+1} ]; then
    # Build RPM without checks
    #
    rpmbuild -bb --define "_topdir `echo $RPMDIR`" --without check rhel/openvswitch.spec
else
    rpmbuild -bb --define "_topdir `echo $RPMDIR`" rhel/openvswitch.spec
fi

# Once build is done copy product to artifactory.

echo "---------------------------------------"
echo "Copy RPM into $TMP_RELEASE_DIR"
echo
cp $RPMDIR/RPMS/x86_64/*.rpm $TMP_RELEASE_DIR

# cleanup

echo "---------------------------------------"
echo "Cleanup $TMP_RELEASE_DIR"
echo
cd $BUILDDIR

if [ -d $TMPDIR ]
then
    echo rm -rf $TMPDIR
    rm -rf $TMPDIR
fi

# copy artifacts.

if [ "$JOB_NAME" == "daily" ]; then
    upload_artifacts.sh
fi

exit 0
