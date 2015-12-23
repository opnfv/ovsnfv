#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

WORKSPACE=/tmp

TMPDIR=$WORKSPACE/tmp
mkdir -p $TMPDIR

# source the file so we get OPNFV vars
source $WORKSPACE/latest.properties

# echo the info about artifact that is used during the deployment
echo "Using $(echo $OPNFV_ARTIFACT_URL | cut -d'/' -f3) for deployment"

# set BRIDGE
BRIDGE=pxebr

echo "Starting the deployment using fuel. This could take some time..."
echo "--------------------------------------------------------"
echo

cd $WORKSPACE
GIT_SSL_NO_VERIFY=true git clone https://gerrit.opnfv.org/gerrit/fuel fuel
cd fuel

# start the deployment
echo "Issuing deploy command"
sudo $WORKSPACE/fuel/ci/deploy.sh -iso $WORKSPACE/opnfv.iso -dea $POD_CONF_DIR/dea.yaml -dha $POD_CONF_DIR/dha.yaml -s $TMPDIR -b $BRIDGE -nh # -pc /path/to/our/plugins_conf -p /path/to/our/plugins

echo
echo "--------------------------------------------------------"
echo "Done!"

