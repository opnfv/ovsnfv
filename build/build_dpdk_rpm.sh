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
    DPDK_VERSION=16.11
fi
export REPO_PATH="/etc/yum.repos.d/fdio-release.repo"
if [ ! -f $REPO_PATH ]; then
    echo "-------------------------------------------"
    echo install upstream repo  - Use fd.io nexus repo for now
    echo until dpdk rpm is in epel or Centos NFV SIG
    FDIORELEASE=$(mktemp)
    cat - > $FDIORELEASE <<"_EOF"
[fdio-release]
name=fd.io release branch latest merge
baseurl=https://nexus.fd.io/content/repositories/fd.io.master.centos7/
enabled=1
gpgcheck=0
_EOF
    sudo cp $FDIORELEASE $REPO_PATH
    sudo chmod 644 $REPO_PATH
fi

HOME=`pwd`
TOPDIR=$HOME
TEMPDIR=$TOPDIR/rpms

function install_pre_reqs() {
    echo "----------------------------------------"
    echo Install dependencies for dpdk.
    echo
    sudo yum -y install gcc make python-devel openssl-devel kernel-devel graphviz \
                kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
                libtool python-twisted-core desktop-file-utils groff PyQt4 \
                yum-utils
}

if [ ! -d $TEMPDIR ]; then
    mkdir -p $TEMPDIR
fi


install_pre_reqs

cd $TEMPDIR
echo "---------------------------------"
echo Download DPDK RPMs
yumdownloader dpdk-$DPDK_VERSION
yumdownloader dpdk-devel-$DPDK_VERSION
yumdownloader dpdk-debuginfo-$DPDK_VERSION
yumdownloader dpdk-doc-$DPDK_VERSION
yumdownloader dpdk-examples-$DPDK_VERSION
yumdownloader dpdk-tools-$DPDK_VERSION


echo "-------------------------------"
echo Copy dpdk RPM
echo
cp $TEMPDIR/*.rpm $HOME

exit 0
