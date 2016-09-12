.. OPNFV - Open Platform for Network Function Virtualization
.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

========
Abstract
========

This document describes the optional build of the OPNFV Colorado release
of the OVSNFV RPMs for the dependencies and required
system resources are also described.

============
Introduction
============

This document describes how to build the OVSNFV RPMs. These RPMs are incorporated into the
Apex iso artifacts so there is no required action for Apex installation of OPNFV.

This document describes the optional standalone build of the OVSNFV RPMs.

============
Requirements
============


Minimum Software Requirements
=============================

The build host should run Centos 7.0

Setting up OPNFV Gerrit in order to being able to clone the code
----------------------------------------------------------------

- Start setting up OPNFV gerrit by creating a SSH key (unless you
  don't already have one), create one with ssh-keygen

- Add your generated public key in OPNFV Gerrit <https://gerrit.opnfv.org/>
  (this requires a Linux foundation account, create one if you do not
  already have one)

- Select "SSH Public Keys" to the left and then "Add Key" and paste
  your public key in.

Clone the OPNFV code Git repository with your SSH key
-----------------------------------------------------

Clone the code repository:

.. code-block:: bash

    $ git clone ssh://<Linux foundation user>@gerrit.opnfv.org:29418/ovsnfv

Clone the OPNFV code Git repository using HTML
----------------------------------------------

.. code-block:: bash

    $ git clone https://gerrit.opnfv.org:29418/ovsnfv

========
Building
========

Build using build.sh
--------------------

.. code-block:: bash

    $ cd ovsnfv/ci
    $ ./build.sh

