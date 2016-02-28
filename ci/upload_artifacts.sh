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
echo "Uploading the OVS and DPDK RPM artifacts. "
echo "-----------------------------------------"
echo

cd $TMP_RELEASE_DIR
for i in `ls *.rpm`
do
    echo copying $i to gs://$GS_URL/ovs4opnfv
    gsutil cp $TMP_RELEASE_DIR/$i gs://$GS_URL/ovs4opnfv-$i
    echo
done

echo
echo "------------------------------------------------------"
echo "Done!"
echo "Artifacts are available in http://$GS_URL/ovs4opnfv/*.rpm"
