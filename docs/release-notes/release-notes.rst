=============================================================
OPNFV Release Notes for the Colorado release of OVS for OPNFV
=============================================================


.. contents:: Table of Contents
   :backlinks: none


Abstract
========

This document provides the release notes for Colorado release of
OVSNFV for OPNFV.

Version history
===============


+-------------+-----------+------------------+----------------------+
| **Date**    | **Ver.**  | **Authors**      |    **Comment**       |
|             |           |                  |                      |
+-------------+-----------+------------------+----------------------+

Summary
=======

The Colorado release of OVSNFV will provide RPMs for DPDK and OVS with DPDK.
Also for the Colorado release an RPM of an interim release of OVS and the
OVS kernel module with NSH patches.

- Documentation is built by Jenkins
- .rpm packages are built by Jenkins

Release Data
============

+--------------------------------------+--------------------------------------+
| **Project**                          | ovsnfv                               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/tag**                         | ovsnfv/colorado.1.0                  |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | colorado.1.0                         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | 2016-09-14                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Colorado release               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Version change
--------------

Module version changes
~~~~~~~~~~~~~~~~~~~~~~
This is the first tracked version of OVSNFV for the Colorado release.

- Open vSwitch 2.5.90

- DPDK 16.04

Unsupported Experimental OVS with NSH
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Experimental** Open vSwitch 2.5.90 with NSH
- **Experimental** Open vSwitch 2.5.90 with NSH Kernel Module
- OVS commit7d433ae57ebb90cd68e8fa948a096f619ac4e2d8

For more information see:

- https://github.com/yyang13/ovs_nsh_patches.git/README

Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~

This is the first tracked version of Colorado release of OVSNFV.
The following documentation is provided with this release:

- OVSNFV Build instructions of the RPMs for the Colorado release
  ver. 1.0.0

Feature additions
~~~~~~~~~~~~~~~~~

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA: OVSNFV-1                       | Setup OVS/DPDK RPM                   |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA: OVSNFV-27                      | A deployment with Apex using         |
|                                      | OVS/DPDK passes all relevant         |
|                                      | functest tests.                      |
+--------------------------------------+--------------------------------------+
| JIRA: OVSNFV-29                      | Apex consume ovsnfv generated RPM    |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Bug corrections
~~~~~~~~~~~~~~~

**JIRA TICKETS:**

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
|                                      |                                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~
build.sh - Builds the RPM artifacts

Artifacts produced by OVSNFV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Artifacts for this release consist of RPMs.
The RPM file names are all prefixed
with ovs4opnfv-e8acab14-
RPMs are uploaded into the OPNFV artifactory in the opnfv artifactory in the
ovsnfv/colorado directory.

- DPDK 16.04

  -  ovs4opnfv-e8acab14-dpdk-16.04.0-1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-dpdk-debuginfo-16.04.0-1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-dpdk-devel-16.04.0-1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-dpdk-examples-16.04.0-1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-dpdk-tools-16.04.0-1.el7.centos.x86_64.rpm

- OVS with DPDK

  -  ovs4opnfv-e8acab14-openvswitch-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-debuginfo-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-devel-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-ovn-central-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-ovn-common-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-ovn-docker-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-ovn-host-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-openvswitch-ovn-vtep-2.5.90-0.12032.gitc61e93d6.1.el7.centos.x86_64.rpm

EXPERIMENTAL artifacts produced by OVS for NFV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-debuginfo-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-devel-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-kmod-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-ovn-central-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-ovn-common-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-ovn-docker-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-ovn-host-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm
  -  ovs4opnfv-e8acab14-EXPERIMENTAL-openvswitch-ovn-vtep-2.5.90-0.11975.NSH7d433ae5.1.el7.centos.x86_64.rpm


Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~
- RPM build instructions for the Colorado release version 1.0.0
- OVSNFV Release Notes for the Colorado release version 1.0.0
- Configuration Guide for OVSNFV
- Supported Scenario Description and Documentation

Known Limitations, Issues and Workarounds
=========================================

Known issues
------------

**JIRA TICKETS:**

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
|                                      |                                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Workarounds
-----------
**-**


Test Result
===========

The Colorado release of OVS/DPDK RPM deployed with the Apex deployment
toolchain has undergone QA test runs with the following results:

+--------------------------------------+--------------------------------------+
| **TEST-SUITE**                       | **Results:**                         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **-**                                | **-**                                |
+--------------------------------------+--------------------------------------+


References
==========

For more information on the OPNFV Colorado release, please see:

http://wiki.opnfv.org/releases/Colorado

:Author: Thomas F Herbert (therbert@redhat.com)
:Version: 1.0.0
