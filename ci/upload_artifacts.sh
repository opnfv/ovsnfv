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
echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$DATE-$RPMFILE_D
gsutil cp $TMP_RELEASE_DIR/$RPMFILE_D gs://$GS_URL/opnfv-$DATE-$RPMFILE_D

echo gsutil cp $TMP_RELEASE_DIR/$RPMFILE gs://$GS_URL/opnfv-$DATE-$RPMFILE
gsutil cp $TMP_RELEASE_DIR/$RPMFILE gs://$GS_URL/opnfv-$DATE-$RPMFILE

echo
echo "------------------------------------------------------"
echo "Done!"
echo "Artifacts are available as http://$GS_URL/opnfv-$DATE-$RPMFILE"
