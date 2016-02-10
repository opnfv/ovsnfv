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
    echo $0 -g version -- only 2.2.0 and master supported
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

sudo yum -y install gcc make python-devel openssl-devel autoconf automake rpm-build \
            redhat-rpm-config libtool


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
mkdir -p copr
cd copr
git clone http://copr-dist-git.fedorainfracloud.org/cgit/pmatilai/dpdk/dpdk.git


echo "---------------------"
echo "If building master, clone dpdk repo otherwise fetch snapshot"
echo "Build DPDK RPM version $DPDK_VERSION"
    
if [[ "$DPDK_VERSION" =~ "master" ]]; then
    cd $TMPDIR
    git clone $DPDK_REPO_URL
    cd dpdk
    echo "Use local spec file that allows version to be overridden"
    cp $HOME/dpdk.spec $TMPDIR/dpdk
    cp $HOME/dpdk.spec $RPMDIR/SPECS
    cp $TMPDIR/copr/dpdk/dpdk-snapshot.sh $TMPDIR/dpdk
    cp $TMPDIR/copr/dpdk/*.patch $TMPDIR/copr/dpdk/sources $TMPDIR/copr/dpdk/dpdk-snapshot.sh $RPMDIR/SOURCES
    snapgit=`git log --pretty=oneline -n1|cut -c1-8`
    snapser=`git log --pretty=oneline | wc -l`

    makever=`make showversion`
    basever=`echo ${makever} | cut -d- -f1`

    prefix=dpdk-${basever}-${snapser}.git${snapgit}
    archive=${prefix}.tar.gz
    DPDK_VERSION=$basever

    echo "Creating ${archive}"
    git archive --prefix=${prefix}/ HEAD  | gzip -9 > ${archive}
    cp ${archive} $RPMDIR/SOURCES
    echo rpmbuild -bb --define "_topdir $RPMDIR" --define "ver $DPDK_VERSION" --define "snapver ${snapser}.git${snapgit}"
    rpmbuild -bb --define "_topdir $RPMDIR" --define "ver $DPDK_VERSION" --define "snapver ${snapser}.git${snapgit}" dpdk.spec
else
    echo building RPM for DPDK version $DPDK_VERSION
    echo Get rpm $DPDK_VERSION from upstream
    wget -q http://dpdk.org/browse/dpdk/snapshot/dpdk-$DPDK_VERSION.tar.gz
    cp dpdk-$DPDK_VERSION.tar.gz $RPMDIR/SOURCES
    cp $HOME/dpdk.spec $TMPDIR/copr/dpdk
    cp $HOME/dpdk.spec $RPMDIR/SPECS
    cd $TMPDIR/copr/dpdk
    cp $TMPDIR/copr/dpdk/*.patch $TMPDIR/copr/dpdk/sources $TMPDIR/copr/dpdk/dpdk-snapshot.sh $RPMDIR/SOURCES
    cp $HOME/dpdk.spec $RPMDIR/SPECS
    echo rpmbuild -bb --define "_topdir $RPMDIR" --define "ver $DPDK_VERSION" dpdk.spec
    rpmbuild -bb --define "_topdir $RPMDIR" --define "ver $DPDK_VERSION" dpdk.spec
fi
cp $RPMDIR/RPMS/x86_64/*.rpm $HOME

exit 0
