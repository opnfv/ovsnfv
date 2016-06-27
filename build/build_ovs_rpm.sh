#!/bin/bash

# Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

set -e

echo "==============================="
echo executing $0 $@
echo executing on machine `uname -a`

usage() {
    echo run BuildAndTestOVS -h for help
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

while getopts "cdg:hkp:u:v" opt; do
    case "$opt" in
        c)
            setnocheck="--without check"
            ;;
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

echo "---------------------------------------"
echo Clean out old working dir
echo
if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi

function install_pre_reqs() {
    echo "----------------------------------------"
    echo Install pre-reqs.
    echo
    sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
                kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
                libtool python-twisted-core desktop-file-utils groff PyQt4
}

VERSION=2.3.90
os_type=fedora
kernel_version=$(uname -a | awk '{print $3}')

RPMDIR=$HOME/rpmbuild

echo "---------------------------------------"
echo Clean out old reminents of old rpms and rpm _topdir.
echo

rm openvswitch*.rpm || true
if [  -d $RPMDIR ]; then
    rm -rf $RPMDIR
fi

echo "---------------------------------------"
echo Create new rpm _topdir.
echo
mkdir -p $HOME/rpmbuild/RPMS
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS


mkdir -p $TMPDIR

cd $TMPDIR

if [ ! -z $DPDK ]; then
    echo "----------------------------------"
    echo "Build OVS for dpdk. Use Fedora copr repo"
    echo
    echo "----------------------------------"
    echo "Clone Fedora copr repo and copy files."
    echo
    git clone https://github.com/tfherbert/ovs-snap.git
    cd ovs-snap
    git checkout $COPR_OVS_VERSION
    echo "-----------------------------------"
    cp $TMPDIR/ovs-snap/openvswitch.spec $RPMDIR/SPECS
    cp $TMPDIR/ovs-snap/* $RPMDIR/SOURCES
    snapgit=`grep "define snapver" $TMPDIR/ovs-snap/openvswitch.spec | cut -c26-33`
    echo "-----------------------------------------------"
    echo remove any old installed ovs and dpdk rpms.
    echo
    cleanrpms

    if [ -z $DPDK_VERSION ]; then
        DPDK_VERSION=16.04.0
    fi
    echo "-------------------------------------------"
    echo "Install dpdk and dpdk development rpms for version $DPDK_VERSION"
    echo
    sudo rpm -ivh $HOME/dpdk-${DPDK_VERSION:0:1}*.rpm
    sudo rpm -ivh $HOME/dpdk-devel*.rpm
    echo "----------------------------------------"
    echo "Copy DPDK RPM to SOURCES"
    echo
    cp $HOME/*.rpm $RPMDIR/SOURCES
    echo "--------------------------------------------"
    echo "Get commit from $snapgit User Space OVS version $TAG"
    echo
    cd $TMPDIR
    git clone $OVS_REPO_URL
    cd $TMPDIR/ovs
    git checkout $snapgit
    echo "--------------------------------------------"
    echo "Creating snapshot, $archive with name same as in spec file."
    echo
    snapser=`git log --pretty=oneline | wc -l`
    basever=`grep AC_INIT configure.ac | cut -d' ' -f2 | cut -d, -f1`
    prefix=openvswitch-${basever}
    archive=${prefix}-${snapser}.git${snapgit}.tar.gz
    git archive --prefix=${prefix}-${snapser}.git${snapgit}/ HEAD  | gzip -9 > $RPMDIR/SOURCES/${archive}
    cd $TMPDIR/ovs-snap
    echo "--------------------------------------------"
    echo "Build openvswitch RPM"
    echo
    rpmbuild -bb --define "_topdir `echo $RPMDIR`" $setnocheck openvswitch.spec
else
    echo "-------------------------------------------------"
    echo "Build OVS without DPDK:"
    echo "Use spec files for $os_type in OVS distribution."
    echo
    if [[ "$TAG" =~ "master" ]]; then
        git clone $OVS_REPO_URL
        cd ovs

        if [[ ! "$OVS_PATCH" =~ "no" ]]; then
            echo "Apply patches from $OVS_PATCH"
        fi
        basever=`grep AC_INIT configure.ac | cut -d' ' -f2 | cut -d, -f1`
        export VERSION=$basever

        echo "--------------------------------------------"
        echo making distribution tarball for Open vswitch version $VERSION
        echo
        ./boot.sh
        ./configure
        make dist

        echo cp openvswitch-*.tar.gz $HOME/rpmbuild/SOURCES
        cp openvswitch-*.tar.gz $HOME/rpmbuild/SOURCES
    else
        export VERSION=${TAG}
        echo "---------------------------------------------"
        echo "Get openvswith-${VERSION}.tar.gz"
        echo
        curl --silent --output $HOME/rpmbuild/SOURCES/openvswitch-${VERSION}.tar.gz http://openvswitch.org/releases/openvswitch-${VERSION}.tar.gz
    fi

fi
#
# This section is for building OVS kernel module.
#
if [ ! -z $kmod ]; then
    cd $TMPDIR/ovs
    echo "--------------------------------------------"
    echo making distribution tarball for Open vswitch version $VERSION
    echo
    ./boot.sh
    ./configure
    make dist
    echo "--------------------------------------------"
    echo Copy distribution tarball to $HOME/rpmbuild/SOURCES
    echo
    cp openvswitch-*.tar.gz $HOME/rpmbuild/SOURCES
    echo "--------------------------------------------"
    echo "Building openvswitch kernel module RPM"
    echo
    rpmbuild -bb -D "kversion $kernel_version" -D "kflavors default" --define "_topdir `echo $RPMDIR`" $setnocheck rhel/openvswitch-kmod-${os_type}.spec
fi

cp $RPMDIR/RPMS/x86_64/*.rpm $HOME

exit 0
