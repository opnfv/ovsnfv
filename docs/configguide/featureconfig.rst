.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. Copyright (c) 2016 Open Platform for NFV Project, Inc. and its contributors

Installing OVSNFV Fuel Plugin
=============================

* On the Fuel UI, create a new environment.
* In Settings > Userspace OVS support, check "Userspace OVS support".
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
