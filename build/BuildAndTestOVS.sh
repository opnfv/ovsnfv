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
echo executing $0 $@
echo

usage() {
    echo "$0 -a <kernel major> -d -g <OVS TAG> -h\
             -i <kernel minor> -p <patch url> -t -u <OVS URL> -v <verbose\
    -a <kernel major> -- Specify major release if special kernel is required\
    The default kernel is Centos 7.2 kernel after upgrade.\
    -d <dpdk>         -- Specify dpdk build.\
                    The default is to build ovs for linux kernel data path.\
    -g <OVS TAG>      -- OVS release tag or branch to build such as 2.4.\
                    The default is master.\
    -h print this message\
    -i <kernel minor> -- Specify minor release if special kernel is required.\
                    The default kernel is Centos 7.2 kernel after upgrade.\
    -p <patch url>    -- Specify url to patches if required for ovs rpm.\
    -t                -- Test rpm.\
    -u <OVS URL>      -- path to OVS repo if using fork for patch.\
                    The default is https://github.com/openvswitch/ovs.git\
    -v                -- Set verbose mode."
}

while getopts "a:dg:hi:p:tu:v" opt; do
    case "$opt" in
        a)
            kernel_major=${OPTARG}
            ;;
        d)
            DPDK="yes"
            ;;
        g)
            TAG=${OPTARG}
            ;;
        h)
            usage
            exit 1
            ;;
        i)
            kernel_minor=${OPTARG}
            ;;
        p)
            OVS_PATCH=${OPTARG}
            ;;
        t)
            TESTRPM="yes"
            ;;
        u)
            OVS_REPO_URL=${OPTARG}
            ;;
        v)
            verbose="yes"
            ;;
    esac
done

if [ -z $TAG ]; then
    TAG=master
fi

if [ -z $OVS_REPO_URL ]; then
    OVS_REPO_URL=https://github.com/openvswitch/ovs.git
fi

if [ ! -z $kernel_major ] && [ ! -z $kernel_minor ]; then
    kernel_version=$kernel_major.$kernel_minor
    echo ===================
    echo Will install kernel version: major is $kernel_major and minor is $kernel_minor
    echo ===================
else
    echo Will use default kernel in ovs test vm
fi

if [ ! -z $DPDK ]; then
    setbuilddpdk="-d"
fi

if [ -z ${WORKSPACE+1} ]; then
    # We are not being run by Jenkins.
    export WORKSPACE=$HOME/opnfv/ovsnfv
    mkdir -p opnfv
    cd opnfv
    git clone https://git.opnfv.org/ovsnfv
fi

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


mkdir -p $RPMDIR/RPMS
mkdir -p $RPMDIR/SOURCES
mkdir -p $RPMDIR/SPECS
mkdir -p $RPMDIR/SRPMS


if [ ! -z $TESTRPM ]; then
    # Spawn VM to do the testing.
    if [ ! -z $kernel_version ]; then
        instack_ovs.sh -a $kernel_major -g $TAG -i $kernel_minor -p $OVS_PATCH -t -u $OVS_REPO_URL
    else
        instack_ovs.sh $setbuilddpdk -g $TAG -p $OVS_PATCH -t -u $OVS_REPO_URL
    fi
else
    # Run build locally.
    build_ovs_rpm.sh $setbuilddpdk -g $TAG -p $OVS_PATCH -u $OVS_REPO_URL
    cp $HOME/rpmbuild/RPMS/* $TMP_RELEASE_DIR
fi

exit 0
