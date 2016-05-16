..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

==========================================
Example Spec - The title of your blueprint
==========================================

Include the URL of OPNFV wiki page description:

https://wiki.opnfv.org/display/ovsnfv/OVSFV+Requirement+-+Example

Introduction paragraph -- why are we doing anything? A single paragraph of
prose that operators can understand. The title and this first paragraph
should be used as the subject line and body of the commit message
respectively.

Some notes about the process:

* The aim of this document is first to define the problem we need to solve,
  and second agree the overall approach to solve that problem.

* This is not intended to be extensive documentation for a new feature.

* You should aim to get your spec approved before writing your code.
  While you are free to write prototypes and code before getting your spec
  approved, its possible that the outcome of the spec review process leads
  you towards a fundamentally different solution than you first envisaged.

* But, API changes are held to a much higher level of scrutiny.
  As soon as an API change merges, we must assume it could be in production
  somewhere, and as such, we then need to support that API change forever.
  To avoid getting that wrong, we do want lots of details about API changes
  upfront.

Some notes about using this template:

* Your spec should be in ReSTructured text, like this template.

* Please wrap text at 79 columns.

* Please do not delete any of the sections in this template.  If you have
  nothing to say for a whole section, just write: None

* For help with syntax, see http://sphinx-doc.org/rest.html

* To test out your formatting, build the docs using sphinx

* If you would like to provide a diagram with your spec, ascii diagrams are
  required.  http://asciiflow.com/ is a very nice tool to assist with making
  ascii diagrams.  The reason for this is that the tool used to review specs is
  based purely on plain text.  Plain text will allow review to proceed without
  having to look at additional files which can not be viewed in gerrit.  It
  will also allow inline feedback on the diagram itself.

Problem description
===================

A detailed description of the problem. What problem is this blueprint
addressing?

Use Cases
---------

What use cases does this address? What impact on actors does this change have?
Ensure you are clear about the actors in each use case: Developer, End User,
Deployer etc.

Proposed change
===============

Here is where you cover the change you propose to make in detail. How do you
propose to solve this problem?

If this is one part of a larger effort make it clear where this piece ends. In
other words, what's the scope of this effort?

At this point, if you would like to just get feedback on the problem and
proposed change, you can stop here and post this for review to get
preliminary feedback. If so please say:
Posting to get preliminary feedback on the scope of this spec.

Alternatives
------------

What other ways could we do this thing? Why aren't we using those? This doesn't
have to be a full literature review, but it should demonstrate that thought has
been put into why the proposed solution is an appropriate one.

OVSDB schema impact
-------------------

Changes which require modifications to the data model often have a wider impact
on the system.  The community often has strong opinions on how the data model
should be evolved, from both a functional and performance perspective. It is
therefore important to capture and gain agreement as early as possible on any
proposed changes to the data model.

Questions which need to be addressed by this section include:

* What new data objects and/or database schema changes is this going to
  require?

User interface impact
---------------------

Each user interface that is either added, changed or removed should have the
following:

* Specification for the user interface

* Example use case including typical examples for both data supplied
  by the caller and the response

Security impact
---------------

Describe any potential security impact on the system.  Some of the items to
consider include:

* Does this change touch sensitive data such as tokens, keys, or user data?

* Does this change alter the interface in a way that may impact security, such as
  a new way to access sensitive information?

* Does this change involve cryptography or hashing?

* Does this change require the use of sudo or any elevated privileges?

* Does this change involve using or parsing user-provided data? This could
  be directly at the API level or indirectly such as changes to a cache layer.

* Can this change enable a resource exhaustion attack, such as allowing a
  single interaction to consume significant server resources?

Other end user impact
---------------------

Aside from the user interfaces, are there other ways a user will interact with this
feature?

Performance Impact
------------------

Describe any potential performance impact on the system, for example
how often will new code be called, and is there a major change to the calling
pattern of existing code.

Examples of things to consider here include:

* Will the change include any locking, and if so what considerations are there
  on holding the lock?

Other deployer impact
---------------------

Discuss things that will affect how you deploy and configure Open vSwitch
that have not already been mentioned, such as:

* What config options are being added? Should they be more generic than
  proposed? Are the default values ones which will work well in
  real deployments?

* Is this a change that takes immediate effect after its merged, or is it
  something that has to be explicitly enabled?

* If this change is a new binary, how would it be deployed?

* Please state anything that those doing continuous deployment, or those
  upgrading from the previous release, need to be aware of. Also describe
  any plans to deprecate configuration values or features.

Developer impact
----------------

Discuss things that will affect other developers working on Open vSwitch,
such as:

Implementation
==============

Assignee(s)
-----------

Who is leading the writing of the code? Or is this a blueprint where you're
throwing it out there to see who picks it up?

If more than one person is working on the implementation, please designate the
primary author and contact.

Primary assignee:
  <email address>

Other contributors:
  <email address>

Work Items
----------

Work items or tasks -- break the feature up into the things that need to be
done to implement it. Those parts might end up being done by different people,
but we're mostly trying to understand the timeline for implementation.


Dependencies
============

* If this requires functionality of another project that is not currently used
  document that fact.

* Does this feature require any new library dependencies or code otherwise not
  included in Open vSwitch? Or does it depend on a specific version of library?


Testing
=======

Please discuss the important scenarios needed to test here, as well as
specific edge cases we should be ensuring work correctly. For each
scenario please specify if this requires specialized hardware.

Please discuss how the change will be tested: Open vSwitch unit tests, VSPERF
performance tests, Yardstick tests, etc.

Is this untestable in gate given current limitations (specific hardware /
software configurations available)? If so, are there mitigation plans (3rd
party testing, gate enhancements, etc).


Documentation Impact
====================

Which audiences are affected most by this change, and which documentation
should be updated because of this change? Don't
repeat details discussed above, but reference them here in the context of
documentation for multiple audiences. If a config option
changes or is deprecated, note here that the documentation needs to be updated
to reflect this specification's change.

References
==========

Please add any useful references here. You are not required to have any
reference. Moreover, this specification should still make sense when your
references are unavailable. Examples of what you could include are:

* Links to mailing list or IRC discussions

* Links to relevant research, if appropriate

* Related specifications as appropriate

* Anything else you feel it is worthwhile to refer to


History
=======

Optional section intended to be used each time the spec
is updated to describe new design, API or any database schema
updated. Useful to let reader understand what's happened along the
time.

.. list-table:: Revisions
   :header-rows: 1

   * - Release Name
     - Description
   * - 2.x
     - Introduced
