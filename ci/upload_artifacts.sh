#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# log info to console
echo "Uploading the OVS $VERSION RPM artifacts. "
echo "-----------------------------------------"
echo

export RPMFILE_D=openvswitch-debuginfo-$VERSION-1.x86_64.rpm
export RPMFILE=openvswitch-$VERSION-1.x86_64.rpm

# upload artifact and additional files to google storage
echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$RPMFILE_D
gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$RPMFILE_D

echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE gs://$GS_URL/opnfv-$RPMFILE
gsutil cp $TMP_RELEASE_DIR/$RPMFILE gs://$GS_URL/opnfv-$RPMFILE

echo
echo "------------------------------------------------------"
echo "Done!"
echo "Artifacts are available as http://$GS_URL/opnfv-$RPMFILE1"
