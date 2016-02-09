.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors

============
Open vSwitch
============

Open vSwtich (OVS) is a software switch commonly used in OpenStack deployments
to replace Linux bridges as it offers advantages in terms of mobility, hardware
integration and use by network controllers.

================
OPNFV Installers
================

Currently not all installers are supported.

Fuel Installer
--------------

OVSNFV project supplies a Fuel Plugin to upgrades Open vSwitch on an OPNFV
installation to use user-space datapath.

As part of the upgrade the following changes are also made:

* change libvirt on compute node to 1.2.12
* change qemu on compute node to 2.2.1
* installs DPDK 2.0.0
* installs OVS 2.1 (specifically git tag 1e77bbe)
* removes existing OVS neutron plugin
* installs new OVS plugin as part of networking_ovs_dpdk OpenStack plugin
  version stable/kilo
* work around _set_device_mtu issue

Limitations
~~~~~~~~~~~

This release should be considered experimental. In particular:

* performance will be addressed specifically in subsequent releases.
* OVS and other components are updated only on compute nodes.

Bugs
~~~~

* There may be issues assigning floating and public ip address to VMs.

