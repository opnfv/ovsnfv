#!/bin/bash

DIR=`pwd`
echo "Hello OVSNFV community!"

echo "Build ovs RPM for Linux kernel data plane from master branch of OVS."

$DIR/buildovs.sh

exit 0
