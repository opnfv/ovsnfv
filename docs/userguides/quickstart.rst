===========================
Getting Started with OVSNFV
===========================

Fuel Plugin Overview
--------------------

OVSNFV Fuel plugin upgrades Open vSwitch on an OPNFV installation to use
user-space datapath.

As part of the upgrade the following changes are also made:

* change libvirt on compute node to 1.2.12
* change qemu on compute node to 2.2.1
* installs DPDK 2.0.0
* installs OVS 2.1 (specifically git tag 1e77bbe)
* removes existing OVS neutron plugin
* installs new OVS plugin as part of networking_ovs_dpdk OpenStack plugin
  version stable/kilo
* work around _set_device_mtu issue

Requirements
~~~~~~~~~~~~

Currently not all installers are supported.

Limitations
~~~~~~~~~~~

Limitataions
------------

This release should be considered experimental. In particular:

* performance will be addressed specifically in subsequent releases.
* OVS and other components are updated only on compute nodes.
* There may be issues assigning floating and public ip address to VMs.
