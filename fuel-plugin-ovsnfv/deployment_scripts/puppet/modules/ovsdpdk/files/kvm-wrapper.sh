#!/usr/bin/env bash

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

VIRTIO_OPTIONS="csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
VHOST_FORCE="vhostforce"
SHARE="share=on"
add_mem=False
i=0
while [ $# -gt 0 ]; do
     case "$1" in

     -device)
        args[i]="$1"
        (( i++ ))
        shift
        if [[ $1 =~ "vhost-user" ]]
        then
                args[i]=${1},${VHOST_FORCE}
                (( i++))
                shift

        fi
        ;;
    -object)
        args[i]="$1"
        (( i++ ))
        shift
        if [[ $1 =~ "memory-backend-file" ]]
        then
                args[i]=${1},${SHARE}
                (( i++))
                shift

        fi
        ;;

     *)
         args[i]="$1"
         (( i++ ))
         shift ;;
     esac
done
echo "qemu ${args[@]}"  > /tmp/qemu.orig
if [ -e /usr/local/bin/qemu-system-x86_64 ]; then
    exec /usr/local/bin/qemu-system-x86_64  "${args[@]}"
elif [ -e /usr/libexec/qemu-kvm.orig ]; then
    exec /usr/libexec/qemu-kvm.orig  "${args[@]}"
fi
