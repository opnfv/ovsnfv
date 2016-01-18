=============================
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
