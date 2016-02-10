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
declare -i CNT

echo "==============================="
echo executing $0 $@
echo executing on machine `uname -a`

usage() {
    echo run BuildAndTestOVS -h for help
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

echo "----------------------------------------"
echo Install pre-reqs.
echo
sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
       kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
       libtool python-twisted-core desktop-file-utils groff

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
    echo "Build OVS for dpdk from Fedora copr repo"
    echo "Copy patches and other files."
    echo
    git clone http://copr-dist-git.fedorainfracloud.org/cgit/pmatilai/dpdk/openvswitch.git
    cp $TMPDIR/openvswitch/openvswitch.spec $RPMDIR/SPECS
    cp $TMPDIR/openvswitch/* $RPMDIR/SOURCES
    echo "-------------------------------------------"
    echo "Remove old dpdk development rpm"
    echo
    sudo rpm -e --allmatches dpdk-devel || true
    echo "-------------------------------------------"
    echo "Install dpdk development rpm"
    echo
    sudo rpm -ivh $HOME/dpdk-devel*.rpm
    echo "----------------------------------------"
    echo "Copy DPDK RPM to SOURCES"
    echo
    cp $HOME/*.rpm $RPMDIR/SOURCES
else
    echo "Build OVS RPMs using spec files for $os_type in OVS distribution."
fi

if [ -z $DPDK ]; then
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

    if [ ! -z $kmod ]; then
        echo "Building kernel module RPM"
        rpmbuild -bb -D "kversion $kernel_version" -D "kflavors default" --define "_topdir `echo $RPMDIR`" $setnocheck rhel/openvswitch-kmod-${os_type}.spec
    fi
    echo " Kernel RPM built!"
    echo "--------------------------------------------"
    echo "Building User Space RPM from spec file in OVS"
    echo
    rpmbuild -bb --define "_topdir `echo $RPMDIR`" $setnocheck rhel/openvswitch.spec
else
    echo "--------------------------------------------"
    echo "Building User Space OVS with DPDK RPM with files from Fedora copr"
    echo
    if [[ "$TAG" =~ "master" ]]; then
        cd $TMPDIR
        git clone $OVS_REPO_URL
        cd ovs
        echo "--------------------------------------------"
        echo "Use ovs-opnfv spec file"
        cp $HOME/openvswitch.spec $TMPDIR/openvswitch
        cp $HOME/openvswitch.spec $RPMDIR/SPECS
        cp $HOME/openvswitch.spec $RPMDIR/SOURCES
        cp $TMPDIR/openvswitch/openvswitch.spec .
        snapgit=`git log --pretty=oneline -n1|cut -c1-8`
        snapser=`git log --pretty=oneline | wc -l`
        basever=`grep AC_INIT configure.ac | cut -d' ' -f2 | cut -d, -f1`
        prefix=openvswitch-${basever}-${snapser}.git${snapgit}
        archive=$prefix.tar.gz
        echo "--------------------------------------------"
        echo "Creating archive, $archive"
        echo
        git archive --prefix=${prefix}/ HEAD  | gzip -9 > $RPMDIR/SOURCES/${archive}
    fi
    cd $TMPDIR/openvswitch
    rpmbuild -bb --define "ver $basever" --define "snapver $snapser.git$snapgit" --define "_topdir `echo $RPMDIR`" $setnocheck openvswitch.spec
fi

cp $RPMDIR/RPMS/x86_64/*.rpm $HOME

exit 0
