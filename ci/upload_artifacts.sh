#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# log info to console
echo "Uploading the OVS $VERSION RPM artifacts. "
echo "-----------------------------------------"
echo

export RPMFILE_D=openvswitch-debuginfo-$VERSION-1.x86_64.rpm
export RPMFILE1=openvswitch-$VERSION-1.x86_64.rpm

# upload artifact and additional files to google storage
echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$RPMFILE_D > gsutil.iso.log 2>&1
gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$RPMFILE_D > gsutil.iso.log 2>&1

echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE1 gs://$GS_URL/opnfv-$RPMFILE1 > gsutil.iso.log 2>&1
gsutil cp $TMP_RELEASE_DIR/$RPMFILE1 gs://$GS_URL/opnfv-$RPMFILE1 > gsutil.iso.log 2>&1

#
#if [[ ! "$JOB_NAME" =~ (verify|merge) ]]; then
#    gsutil cp $WORKSPACE/opnfv.properties gs://$GS_URL/latest.properties > gsutil.latest.log 2>&1
#elif [[ "$JOB_NAME" =~ "merge" ]]; then
#    echo "Uploaded Fuel ISO for a merged change"
#fi

echo
echo "------------------------------------------------------"
echo "Done!"
echo "Artifact is available as http://$GS_URL/opnfv-$RPMFILE"
