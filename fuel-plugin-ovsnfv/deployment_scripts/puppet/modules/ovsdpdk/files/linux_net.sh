#!/usr/bin/env bash

# Copyright 2015 Open Platform for NFV Project, Inc. and its contributors
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

# This script is patching /usr/lib/python2.7/dist-packages/nova/network/linux_net.py
# More specifically it's adding '1' as recognized exit code
# it's WA and will work just when _setr_device_mtu will not change dramatically

# step1) get ROW for patching
FILE="/usr/lib/python2.7/dist-packages/nova/network/linux_net.py"

ROW=`grep -n "def _set_device_mtu(dev, mtu=None):" $FILE | cut -d ":" -f 1`

# step2) use sed for patching it

sed -i.bck "$((ROW+8))s/check_exit_code=\[0, 2, 254\]/check_exit_code=\[0, 1, 2, 254\]/" $FILE

diff $FILE $FILE.bck

if [ $? -eq 0 ]; then
  echo "WARNING: linux_net.py not patched, please check if it's really needed"
else
  echo "SUCCESS: linux_net.py patched"
fi
