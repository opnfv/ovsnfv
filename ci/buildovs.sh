#!/bin/bash
##############################################################################
# Copyright (c) 2015,2016 Red Hat Inc. and others.
# therbert@redhat.com
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -e

echo "==================================="
echo executing $0 $@

# Check to verify that I am being run by Jenkins CI.

if [ -z ${WORKSPACE+1} ]; then
    # We are not being run by Jenkins.
    export WORKSPACE=$HOME/opnfv/ovsnfv
fi


if [ ${OVSTAG} ]; then
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

#
# Build ovs rpm without DPDK from ovs master
#
echo =======Build ovs rpm and ovs kmod rpm without DPDK Test in VM==========
    BuildAndTestOVS.sh -p none -t
#
# Build ovs rpm with DPDK
#
echo =======Build ovs rpm with DPDK Test in VM==========
BuildAndTestOVS.sh -d -p none -t
#
# Build special version of ovs with patches --TODO
#

# Once build is done copy product to artifactory.
# and cleanup


echo "---------------------------------------"
echo "Cleanup temporary dirs"
echo
cd $BUILDDIR

if [ -d $TMPDIR ]
then
    echo rm -rf $TMPDIR
    rm -rf $TMPDIR
fi

# copy artifacts.

if [[ "$JOB_NAME" =~ "daily" ]]; then
    upload_artifacts.sh
fi

if [ -d $TMP_RELEASE_DIR ]; then
    rm -rf $CACHE_RELEASE_DIR
fi

if [ -d $RPMDIR ]; then
    rm -rf $RPMDIR
fi

# Destroy VM if one has been deployed. Also remove any local installation of
# DPDK and OVS
#
sudo ./clean.sh

exit 0
