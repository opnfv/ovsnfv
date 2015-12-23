#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

FUEL_LATEST_PROPERTIES=http://artifacts.opnfv.org/fuel/latest.properties
# get the latest.properties file in order to get info regarding latest fuel artifact
echo "Downloading $FUEL_LATEST_PROPERTIES"
curl -s -o $WORKSPACE/latest.properties $FUEL_LATEST_PROPERTIES 

# check if we got the file
[[ -f $WORKSPACE/latest.properties ]] || exit 1

# source the file so we get OPNFV vars
source $WORKSPACE/latest.properties

# log info to console
echo "Downloading the fuel artifact using URL http://$OPNFV_ARTIFACT_URL"
echo "This could take some time..."
echo "--------------------------------------------------------"
echo

# download the file
curl -s -o $WORKSPACE/opnfv.iso http://$OPNFV_ARTIFACT_URL > gsutil.iso.log 2>&1

# list the file
ls -al $WORKSPACE/opnfv.iso

echo
echo "--------------------------------------------------------"
echo "Done!"

