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
echo "executing $0 $@"
echo "executing on machine `uname -a`"

usage() {
    echo "run BuildAndTestOVS -h for help"
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
TEMPDIR=$TOPDIR/ovsrpm

BUILDDIR=$HOME
BUILD_BASE=$BUILDDIR

source $BUILDDIR/functions.sh

echo "---------------------------------------"
echo "Clean out old working dir."
echo
if [ -d $TEMPDIR ]
then
    rm -rf $TEMPDIR
fi

function install_pre_reqs() {
    echo "----------------------------------------"
    echo "Install pre-reqs."
    echo
    sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
                kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
                libtool python-twisted-core desktop-file-utils groff PyQt4 \
                selinux-policy-devel libpcap libpcap-devel
}
function apply_nsh_patches() {
    echo "-------------------------------------------"
    echo "Clone NSH patch and copy patch files."
    echo
    cd $TEMPDIR
    if [ -e ovs_nsh_patches ]; then
        rm -rf ovs_nsh_patches
    fi
    git clone https://github.com/yyang13/ovs_nsh_patches.git
    cp $TEMPDIR/ovs_nsh_patches/*.patch $RPMDIR/SOURCES
    cd $TEMPDIR
    if [ -e buildovsnsh ]; then
        rm -rf buildovsnsh
    fi
    git clone https://github.com/tfherbert/buildovsnsh.git
    cp buildovsnsh/*.spec $BUILDDIR
}

VERSION=2.3.90
os_type=fedora
kernel_version=$(uname -a | awk '{print $3}')

RPMDIR=$HOME/rpmbuild

echo "---------------------------------------"
echo "Clean out old reminents of old rpms and rpm _topdir."
echo

rm openvswitch*.rpm || true
if [  -d $RPMDIR ]; then
    rm -rf $RPMDIR
fi

echo "---------------------------------------"
echo "Create new rpm _topdir."
echo
mkdir -p $HOME/rpmbuild/RPMS
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS


mkdir -p $TEMPDIR

install_pre_reqs

cd $TEMPDIR

if [ ! -z $DPDK ]; then
    cleanrpms

    if [ -z $DPDK_VERSION ]; then
        DPDK_VERSION=16.11
    fi
    echo "-------------------------------------------"
    echo "Install dpdk and dpdk development rpms for version $DPDK_VERSION"
    echo
    sudo rpm -ivh $HOME/dpdk-${DPDK_VERSION}*.rpm
    sudo rpm -ivh $HOME/dpdk-devel*.rpm
    echo "----------------------------------------"
    echo "Copy DPDK RPM to SOURCES"
    echo
    cp $HOME/*.rpm $RPMDIR/SOURCES
    cd $TEMPDIR
    git clone $OVS_REPO_URL
    cd $TEMPDIR/ovs
    git checkout v$OVSTAG
    echo "----------------------------------------------------"
    echo "Build openvswitch RPM for version $OVSTAG"
    echo
    echo "--------------------------------------------"
    ./boot.sh
    ./configure
    make rpm-fedora RPMBUILD_OPT="--with dpdk --without check"
else
    echo "-------------------------------------------------"
    echo "Build OVS without DPDK:"
    echo "Use spec files for $os_type in OVS distribution."
    echo
    echo "-------------------------------------------"
    echo "Remove old rpms."
    echo
    cleanrpms
    cd $TEMPDIR
    git clone $OVS_REPO_URL
    cd $TEMPDIR/ovs
    git checkout $OVS_FORK_COMMIT_FOR_NSH
    echo "--------------------------------------------"
    echo "Get commit from $snapgit User Space OVS version $TAG"
    echo
    snapgit=`git log --pretty=oneline -n1|cut -c1-8`
    snapser=`git log --pretty=oneline | wc -l`
    basever=`grep AC_INIT configure.ac | cut -d' ' -f2 | cut -d, -f1`
    prefix=openvswitch-${basever}
    snapver=${snapser}.NSH${snapgit}
    archive=${prefix}-${snapser}.NSH${snapgit}.tar.gz

    if [ ! -z $OVS_PATCH ]; then
        echo "-------------------------------------------"
        echo "Apply OVS patches."
        echo
        apply_nsh_patches
    fi

    echo "----------------------------------"
    echo "Create dist name and rpm name. Put $snapver into spec file"
    echo
    cd $BUILD_BASE
    sed -i "s/%define snapver.*/%define snapver ${snapver}/" openvswitch.spec
    echo "----------------------------------"
    echo "Copy spec file."
    echo
    cp $BUILD_BASE/openvswitch.spec $RPMDIR/SPECS
    cp $BUILD_BASE/openvswitch.spec $RPMDIR/SOURCES
    echo "--------------------------------------------"
    echo "Creating snapshot, $archive with name same as in spec file."
    echo
    cd $TEMPDIR/ovs
    git archive --prefix=${prefix}-${snapser}.NSH${snapgit}/ HEAD  | gzip -9 > $RPMDIR/SOURCES/${archive}
    echo "--------------------------------------------"
    echo "Build openvswitch RPM"
    echo
    cd $BUILD_BASE
    rpmbuild -bb -vv --without dpdk --define "_topdir `echo $RPMDIR`" $setnocheck openvswitch.spec
fi
#
# This section is for building OVS kernel module.
#
if [ ! -z $kmod ]; then
    echo "--------------------------------------------"
    echo Build Open vswitch kernel module
    echo
    cd $TEMPDIR
    if [ -e ovs ]; then
        rm -rf ovs
    fi
    git clone $OVS_REPO_URL
    cd $TEMPDIR/ovs
    git checkout $OVS_FORK_COMMIT_FOR_NSH
    echo "--------------------------------------------"
    echo "Get commit from $snapgit User Space OVS version $TAG"
    echo
    snapgit=`git log --pretty=oneline -n1|cut -c1-8`
    snapser=`git log --pretty=oneline | wc -l`
    basever=`grep AC_INIT configure.ac | cut -d' ' -f2 | cut -d, -f1`
    prefix=openvswitch-kmod-${basever}
    snapver=${snapser}.NSH${snapgit}
    archive=${prefix}-${snapser}.NSH${snapgit}.tar.gz

    if [ ! -z $OVS_PATCH ]; then
        echo "-------------------------------------------"
        echo "Apply OVS patches."
        echo
        apply_nsh_patches
    fi
    echo "----------------------------------"
    echo "Create dist name and rpm name. Put $snapver into spec file"
    echo
    cd $BUILD_BASE
    sed -i "s/%define snapver.*/%define snapver ${snapver}/" openvswitch-kmod.spec
    echo "----------------------------------"
    echo "Copy spec file."
    echo
    cp $BUILD_BASE/openvswitch-kmod.spec $RPMDIR/SPECS
    cp $BUILD_BASE/openvswitch-kmod.spec $RPMDIR/SOURCES
    echo "-------------------------------------------"
    echo "Apply nsh patches."
    echo
    apply_nsh_patches
    echo "--------------------------------------------"
    echo "Creating snapshot, $archive with name same as in spec file."
    echo
    cd $TEMPDIR/ovs
    git archive --prefix=${prefix}-${snapser}.NSH${snapgit}/ HEAD  | gzip -9 > $RPMDIR/SOURCES/${archive}
    echo "--------------------------------------------"
    echo "Building openvswitch kernel module RPM"
    echo
    cd $BUILD_BASE
    rpmbuild -bb -vv -D "kversion $kernel_version" -D "kflavors default" --define "_topdir `echo $RPMDIR`" $setnocheck openvswitch-kmod.spec
fi

cp $RPMDIR/RPMS/x86_64/*.rpm $HOME || true
cp $TEMPDIR/ovs/rpm/rpmbuild/RPMS/x86_64/*.rpm $HOME || true

exit 0
