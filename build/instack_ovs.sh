#!/bin/bash
##############################################################################
# Copyright (c) 2015 Red Hat Inc. and others.
# therbert@redhat.com
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -e
declare -i CNT

echo "==============================="
echo executing $0 $@
echo path is $PATH

usage() {
    echo run BuildAndTestOVS -h for help
}

while getopts "a:dg:hi:p:tu:v" opt; do
    case "$opt" in
        a)
            kernel_major=${OPTARG}
            ;;
        d)
            DPDK="yes"
            setdpdk="-d"
            ;;
        g)
            TAG=${OPTARG}
            ;;
        h|\?)
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
#
# Default Config options
#
echo ===============================================
echo Default Configuration Options.
echo ===============================================
echo option NOCHECK is set to $NOCHECK
echo build DPDK option is set to $DPDK
echo DPDK Patch URL is set to $DPDK_PATCH
echo DPDK Version is set to $DPDK_VERSION
echo Option for OVS Kernel Module is set to $KMOD
echo ===============================================
if [[ $NOCHECK =~ "yes" ]]; then
    setnocheck="-c"
fi
if [[ $KMOD =~ "yes" ]]; then
    setkmod="-k"
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

export TMP_RELEASE_DIR=$TOPDIR/release
if [ ! -d $TMP_RELEASE_DIR ]; then
    mkdir -p $TMP_RELEASE_DIR
fi

export CACHE_DIR=$TOPDIR/cache
if [ ! -d $CACHE_DIR ]; then
    mkdir -p $CACHE_DIR
fi
export TMPDIR=$TOPDIR/scratch
if [ ! -d $SCRATCH_DIR ]; then
    mkdir -p $SCRATCH_DIR
fi

rdo_images_uri=https://ci.centos.org/artifacts/rdo/images/liberty/delorean/stable

vm_index=4
RDO_RELEASE=liberty
SSH_OPTIONS=(-o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null)
OPNFV_NETWORK_TYPES="admin_network private_network public_network storage_network"

# check for dependancy packages
for i in rpm-build createrepo libguestfs-tools python-docutils bsdtar; do
    if ! rpm -q $i > /dev/null; then
        sudo yum install -y $i
    fi
done

# RDO Manager expects a stack user to exist, this checks for one
# and creates it if you are root
if ! id stack > /dev/null; then
    sudo useradd stack;
    sudo echo 'stack ALL=(root) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/stack
    sudo echo 'Defaults:stack !requiretty' | sudo tee -a /etc/sudoers.d/stack
    sudo chmod 0440 /etc/sudoers.d/stack
    echo 'Added user stack'
fi

# ensure that I can ssh as the stack user
if ! sudo grep "$(cat ~/.ssh/id_rsa.pub)" /home/stack/.ssh/authorized_keys; then
    if ! sudo ls -d /home/stack/.ssh/ ; then
        sudo mkdir /home/stack/.ssh
        sudo chown stack:stack /home/stack/.ssh
        sudo chmod 700 /home/stack/.ssh
    fi
    USER=$(whoami) sudo sh -c "cat ~$USER/.ssh/id_rsa.pub >> /home/stack/.ssh/authorized_keys"
    sudo chown stack:stack /home/stack/.ssh/authorized_keys
fi

# clean up stack user previously build instack disk images
ssh -T ${SSH_OPTIONS[@]} stack@localhost "rm -f instack*.qcow2"

# Yum repo setup for building the undercloud
if ! rpm -q rdo-release > /dev/null && [ "$1" != "-master" ]; then
    sudo yum -y install yum-plugin-priorities
    sudo yum-config-manager --disable openstack-${RDO_RELEASE}
    sudo curl -o /etc/yum.repos.d/delorean.repo http://trunk.rdoproject.org/centos7-liberty/current-passed-ci/delorean.repo
    sudo curl -o /etc/yum.repos.d/delorean-deps.repo http://trunk.rdoproject.org/centos7-liberty/delorean-deps.repo
    sudo rm -f /etc/yum.repos.d/delorean-current.repo
elif [ "$1" == "-master" ]; then
    sudo yum -y install yum-plugin-priorities
    sudo yum-config-manager --disable openstack-${RDO_RELEASE}
    sudo curl -o /etc/yum.repos.d/delorean.repo http://trunk.rdoproject.org/centos7/current-passed-ci/delorean.repo
    sudo curl -o /etc/yum.repos.d/delorean-deps.repo http://trunk.rdoproject.org/centos7-liberty/delorean-deps.repo
    sudo rm -f /etc/yum.repos.d/delorean-current.repo
fi

# ensure the undercloud package is installed so we can build the undercloud
if ! rpm -q instack-undercloud > /dev/null; then
    sudo yum install -y python-tripleoclient
fi

# ensure openvswitch is installed
if ! rpm -q openvswitch > /dev/null; then
    sudo yum install -y openvswitch
fi

# ensure libvirt is installed
if ! rpm -q libvirt-daemon-kvm > /dev/null; then
    sudo yum install -y libvirt-daemon-kvm
fi

# clean this up incase it's there
sudo rm -f /tmp/instack.answers

# ensure that no previous undercloud VMs are running
sudo ../ci/clean.sh
# and rebuild the bare undercloud VMs
ssh -T ${SSH_OPTIONS[@]} stack@localhost <<EOI
    set -e
    NODE_COUNT=5 NODE_CPU=2 NODE_MEM=8192 TESTENV_ARGS="--baremetal-bridge-names 'brbm brbm1 brbm2 brbm3'" instack-virt-setup
EOI

# let dhcp happen so we can get the ip
# just wait instead of checking until we see an address
# because there may be a previous lease that needs
# to be cleaned up
sleep 5

# get the undercloud ip address
UNDERCLOUD=$(grep instack /var/lib/libvirt/dnsmasq/default.leases | awk '{print $3}' | head -n 1)
if [ -z "$UNDERCLOUD" ]; then
  #if not found then dnsmasq may be using leasefile-ro
  instack_mac=$(ssh -T ${SSH_OPTIONS[@]} stack@localhost "virsh domiflist instack" | grep default | \
                grep -Eo "[0-9a-f\]+:[0-9a-f\]+:[0-9a-f\]+:[0-9a-f\]+:[0-9a-f\]+:[0-9a-f\]+")
  UNDERCLOUD=$(arp -e | grep ${instack_mac} | awk {'print $1'})

  if [ -z "$UNDERCLOUD" ]; then
    echo "\n\nNever got IP for Instack. Can Not Continue."
    exit 1
  fi
else
   echo -e "${blue}\rInstack VM has IP $UNDERCLOUD${reset}"
fi

# ensure that we can ssh to the undercloud
CNT=10
while ! ssh -T ${SSH_OPTIONS[@]}  "root@$UNDERCLOUD" "echo ''" > /dev/null && [ $CNT -gt 0 ]; do
    echo -n "."
    sleep 3
    CNT=CNT-1
done
# TODO fail if CNT=0

# yum update undercloud and reboot.
ssh -T ${SSH_OPTIONS[@]} "root@$UNDERCLOUD" <<EOI
    set -e

    echo "----------------------------------------------------------------"
    echo yum update and install pciutils prereqs for DPDK tools and samples.
    echo
    yum -y update
    yum -y install pciutils libvirt
EOI

# reboot VM
ssh -T ${SSH_OPTIONS[@]} stack@localhost <<EOI
    virsh reboot instack
EOI
sleep 30

# yum repo, triple-o package and ssh key setup for the undercloud
echo "Install epel-release on undercloud"
ssh -T ${SSH_OPTIONS[@]} "root@$UNDERCLOUD" <<EOI
    set -e

    if ! rpm -q epel-release > /dev/null; then
        yum install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    fi

    yum -y install yum-plugin-priorities
    curl -o /etc/yum.repos.d/delorean.repo http://trunk.rdoproject.org/centos7-liberty/current-passed-ci/delorean.repo
    curl -o /etc/yum.repos.d/delorean-deps.repo http://trunk.rdoproject.org/centos7-liberty/delorean-deps.repo

    cp /root/.ssh/authorized_keys /home/stack/.ssh/authorized_keys
    chown stack:stack /home/stack/.ssh/authorized_keys
EOI
#
# If using special kernel version, install on undercloud vm.
#
if [ ! -z $kernel_version ]; then
    echo "Install special kernel version $kernel_version on undercloud"
    ssh -T ${SSH_OPTIONS[@]} "root@$UNDERCLOUD" <<EOI
    set -e
    yum -y install gcc ncurses ncurses-devel bc xz rpm-build
    echo wget --quiet http://mirrors.neterra.net/elrepo/kernel/el6/x86_64/RPMS/kernel-ml-$kernel_version-1.el6.elrepo.x86_64.rpm
    wget --quiet http://mirrors.neterra.net/elrepo/kernel/el6/x86_64/RPMS/kernel-ml-$kernel_version-1.el6.elrepo.x86_64.rpm
    echo wget --quiet http://mirrors.neterra.net/elrepo/kernel/el6/x86_64/RPMS/kernel-ml-devel-$kernel_version-1.el6.elrepo.x86_64.rpm
    wget --quiet http://mirrors.neterra.net/elrepo/kernel/el6/x86_64/RPMS/kernel-ml-devel-$kernel_version-1.el6.elrepo.x86_64.rpm
    echo rpm -i kernel-ml-$kernel_version-1.el6.elrepo.x86_64.rpm
    rpm -i kernel-ml-$kernel_version-1.el6.elrepo.x86_64.rpm
    echo rpm -i kernel-ml-devel-$kernel_version-1.el6.elrepo.x86_64.rpm
    rpm -i kernel-ml-devel-$kernel_version-1.el6.elrepo.x86_64.rpm

    echo cd /lib/modules/$kernel_version-1.el6.elrepo.x86_64
    cd /lib/modules/$kernel_version-1.el6.elrepo.x86_64
    echo rm -f build
    rm -f build
    echo ln -s /usr/src/kernels/$kernel_version-1.el6.elrepo.x86_64 build
    ln -s /usr/src/kernels/$kernel_version-1.el6.elrepo.x86_64 build
    #echo rm -f source
    #rm -f source
    #echo ln -s ./build source
    #ln -s ./build source
EOI
else
    #
    # Install latest stable kernel.
    #
    echo "Install devel-kernel and elrepo on undercloud"
    ssh -T ${SSH_OPTIONS[@]} "root@$UNDERCLOUD" <<EOI
        echo Install latest stable kernel
        set -e
        yum install -y kernel kernel-devel
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
EOI
fi

# copy instackenv file for future virt deployments
echo copy instackenv file for future virt deployments
if [ ! -d stack ]; then mkdir stack; fi
scp ${SSH_OPTIONS[@]} stack@$UNDERCLOUD:instackenv.json stack/instackenv.json


#
# If using special kernel version, reboot undercloud vm
#
echo If using special kernel version, reboot undercloud vm
if [ -z $kernel_version ]; then
    ssh -T ${SSH_OPTIONS[@]} stack@localhost <<EOI
        virsh reboot instack
EOI
    sleep 15
fi

#
# Copy build and test scripts to undercloud vm.
# If special kernel is required, build rpm on undercloud vm otherwise build
# it locally.
#
echo Copy build and test scripts to undercloud vm.
echo BUILD_BASE is $BUILD_BASE
scp ${SSH_OPTIONS[@]} $BUILD_BASE/build_ovs_rpm.sh stack@$UNDERCLOUD:
scp ${SSH_OPTIONS[@]} $BUILD_BASE/test_ovs_rpm.sh stack@$UNDERCLOUD:
#
# build dpdk rpm locally.
#
if [[ "$DPDK" =~ "yes" ]]; then
    echo Build DPDK RPMs
    ./build_dpdk_rpm.sh -g $DPDK_VERSION
fi
#
# Build rpm on undercloud if custom kernel module is required otherwise build
# locally.
#
if [ ! -z $kernel_version ]; then
    echo build rpm on undercloud with kernel version $kernel_version
    ssh -T ${SSH_OPTIONS[@]} "stack@$UNDERCLOUD" <<EOI
        ./build_ovs_rpm.sh -a $kernel_major $setnocheck -g $TAG -i $kernel_minor -k -p $OVS_PATCH -u $OVS_REPO_URL
EOI
    scp ${SSH_OPTIONS[@]} stack@UNDERCLOUD:*.rpm $RPMDIR/RPMS/
elif [[ "$DPDK" =~ "yes" ]]; then
    echo Build ovs with DPDK locally
    #
    # Build locally and copy RPMS to undercloud vm for testing
    # and copy RPMS to temporary release dir.
    #
    ./build_ovs_rpm.sh $setnocheck -d -g $TAG -p $OVS_PATCH -u $OVS_REPO_URL
else
    # Build locally and copy RPMS to undercloud vm for testing
    # and copy RPMS to temporary release dir.
    #
    echo build OVS rpm locally
    ./build_ovs_rpm.sh $setnocheck -g $TAG $setkmod -p $OVS_PATCH -u $OVS_REPO_URL
fi
#
# Test rpm on undercloud vm
# TODO: Undercloud VM doesn't support sse3 instruction needed set to run DPDK
#
if [ ! -z $TESTRPM ]; then
    if [ -z $DPDK ]; then
        echo "-----------------------------------------"
        echo Test rpm on undercloud vm
        echo Copy all RPMS to undercloud for testing.
        echo
        scp ${SSH_OPTIONS[@]} $RPMDIR/RPMS/x86_64/* stack@$UNDERCLOUD:
        scp ${SSH_OPTIONS[@]} $RPMDIR/SOURCES/dpdk*.rpm stack@$UNDERCLOUD:
        ssh -T ${SSH_OPTIONS[@]} "stack@$UNDERCLOUD" <<EOI
            ./test_ovs_rpm.sh $setdpdk $setkmod
EOI
    else
        echo "-----------------------------------------"
        echo "TODO: Undercloud VM doesn't support sse3 instruction needed DPDK."
        echo "DPDK is required, therefore test DPDK/OVS RPM in host"
        echo
        ./test_ovs_rpm.sh $setdpdk $setkmod
    fi
fi

#
# If tests pass, copy rpms to release dir
#
echo copy rpms to release dir
echo copy rpms from undercloud back to $TMP_RELEASE_DIR in host
cp $RPMDIR/RPMS/x86_64/* $TMP_RELEASE_DIR

exit 0
