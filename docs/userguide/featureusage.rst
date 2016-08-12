.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors

Open vSwitch
============

Open vSwtich (OVS) is a software switch commonly used in OpenStack deployments
to replace Linux bridges as it offers advantages in terms of mobility, hardware
integration and use by network controllers.

Supported OPNFV Installers
--------------------------

Currently not all installers are supported.

Fuel Installer
~~~~~~~~~~~~~~

OVSNFV project supplies a Fuel Plugin to upgrade DPDK enabled Open vSwitch
on an OPNFV to 2.5.90.

Limitations
~~~~~~~~~~~

The same limitations that apply to using Fuel DPDK-enabled interfaces also apply
when using this plugin. Including:

* Fuel9 OVS-DPDK support works only for VLAN segmentation.
* Only interfaces running the private network (and no other network) can be
  supported so each node needs a separate interface dedicated to the private network.
* The nodes with dpdk enabled interfaces will need to have hugepages
  configured and some cores reserved for dpdk.

Bugs
~~~~

