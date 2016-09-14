.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors

Installing OVSNFV Fuel Plugin
=============================

* On the Fuel UI, create a new environment.
* Assign nodes as normal.
* In Settings > Compute, ensure KVM is selected which is required to enable DPDK on nodes' interfaces.
* On the compute nodes' interface settings enable DPDK on the interface running the
  private network.
* *Do not enable DPDK on the control nodes.*
* In Settings > Other
    * Enable "Install Openvswitch with NSH/DPDK"
    * Enable "Install DPDK"
    * Disable "Install NSH"
* In Nodes, for each compute node:
    * Reserve some memory for DPDK hugepages - typically 128-512MB per NUMA node.
    * Reserve some memory for Nova hugepages - typically 70-90% of total memory.
    * Pin DPDK cores - typically 2.
* Continue with environment configuration and deployment as normal.


Upgrading the plugin
--------------------

From time to time new versions of the plugin may become available.

The plugin cannot be upgraded if an active environment is using the plugin.

In order to upgrade the plugin:

* Copy the updated plugin file to the fuel-master.
* On the Fuel UI, reset the environment.
* On the Fuel CLI "fuel plugins --update <fuel-plugin-file>"
* On the Fuel UI, re-deploy the environment.
