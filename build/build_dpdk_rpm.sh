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
echo executing on machine `uname -a`

usage() {
    echo run BuildAndTestOVS -h for complete help on options on ovsnfv scripts.
}

while getopts "g:hp:u:v" opt; do
    case "$opt" in
        g)
            DPDK_VERSION=${OPTARG}
            ;;
        h|\?)
            usage
            exit 1
            ;;
        p)
            DPDK_PATCH=${OPTARG}
            ;;
        u)
            DPDK_REPO_URL=${OPTARG}
            ;;
        v)
            verbose="yes"
            ;;
    esac
done

if [ -z $DPDK_REPO_URL ]; then
    DPDK_REPO_URL=http://dpdk.org/git/dpdk
fi
if [ -z $DPDK_VERSION ]; then
    DPDK_VERSION=2.2.0
fi

HOME=`pwd`
TOPDIR=$HOME
TMPDIR=$TOPDIR/rpms

if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi

function install_pre_reqs() {
    echo "----------------------------------------"
    echo Install dependencies for dpdk.
    echo
    sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
                kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
                libtool python-twisted-core desktop-file-utils groff PyQt4
}

mkdir -p $TMPDIR

cd $TMPDIR

mkdir -p $HOME/rpmbuild/RPMS
mkdir -p $HOME/rpmbuild/SOURCES
mkdir -p $HOME/rpmbuild/SPECS
mkdir -p $HOME/rpmbuild/SRPMS

RPMDIR=$HOME/rpmbuild

#
# Use Fedora copr spec file
#
echo "---------------------"
echo "Get copr distribution git"
mkdir -p copr
cd copr
git clone https://github.com/tfherbert/dpdk-snap.git
cd dpdk-snap
git checkout $COPR_DPDK_VERSION

echo "---------------------"
echo "Build DPDK RPM version $DPDK_VERSION"
echo
cd $TMPDIR
git clone $DPDK_REPO_URL
cd dpdk
if [[ "$DPDK_VERSION" =~ "master" ]]; then
    git checkout master
    snapgit=`git log --pretty=oneline -n1|cut -c1-8`
else
    git checkout v$DPDK_VERSION
    snapgit=`grep "define snapver" $TMPDIR/copr/dpdk-snap/dpdk.spec | cut -c25-33`
fi

cp $TMPDIR/copr/dpdk-snap/dpdk.spec $TMPDIR/dpdk
cp $TMPDIR/copr/dpdk-snap/dpdk.spec $RPMDIR/SPECS
cp $TMPDIR/copr/dpdk-snap/*.patch $TMPDIR/copr/dpdk-snap/sources $TMPDIR/copr/dpdk-snap/dpdk-snapshot.sh $RPMDIR/SOURCES
snapser=`git log --pretty=oneline | wc -l`

makever=`make showversion`
basever=`echo ${makever} | cut -d- -f1`
prefix=dpdk-${basever:0:5}

archive=${prefix}.tar.gz
DPDK_VERSION=$basever

echo "-------------------------------"
echo "Creating ${archive}"
echo
git archive --prefix=${prefix}/ HEAD  | gzip -9 > ${archive}
cp ${archive} $RPMDIR/SOURCES/
echo "-------------------------------"
echo building RPM for DPDK version $DPDK_VERSION
echo
rpmbuild -bb --define "_topdir $RPMDIR" dpdk.spec

echo "-------------------------------"
echo Delete all rpms from $HOME
echo
set +e
rm $HOME/*.rpm
set -e

echo "-------------------------------"
echo Copy dpdk RPM
echo
cp $RPMDIR/RPMS/x86_64/*.rpm $HOME

exit 0
