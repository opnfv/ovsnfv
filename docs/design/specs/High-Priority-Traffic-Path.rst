..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

==========================================
High Priority Traffic Path
==========================================

https://wiki.opnfv.org/display/ovsnfv/OVSFV+Requirement+-+High+Priority+Traffic+Path

Problem description
===================

When designing a network, traffic may belong to different classes requiring 
differentiated level of service by each network element.

As a concrete example, a network element managed by a service provider may be
handling voice and data traffic. Voice traffic requires that the end-to-end
latency and jitter is bounded to some msec accuracy in order to ensure
quality-of-experience (QoE) for the participants in the voice call. Data traffic,
typically, does not impose such performance requirements on the network. For
example, when downloading a large file across the Internet, although the
bandwidth requirements may be high there is usually no requirement that the
file arrives within a bounded time interval.

Depending on the scheduling algorithms running on the network element, 
frames belonging to the data traffic may get transmitted before frames
belonging to the voice traffic introducing unwanted latency or jitter.
Therefore, in order to ensure deterministic latency and jitter characteristics
end-to-end, each network element through which the voice traffic traverses
must ensure that voice traffic is handled deterministically.

Hardware switches have typically been designed to ensure certain classes
of traffic can be scheduled ahead of other classes and are also 
over-provisioned which further ensures deterministic behavior when
handling high priority traffic. However, software switches (which includes
virtual switches such as Open vSwitch) may require modification in order
to achieve this deterministic behavior.

Use Cases
---------

1. Program classes of service 

The End User specifies a number of classes of service. Each class of service
will be represented by the value of a particular field in a frame. The class of
service will determine the order which flows of this type will get handled
with respect to other flows of differing classes of service. As such, each
class of service will be associated with a priority. The End User will 
associate classes of service and priorities to ingress ports with the
expectation that frames that arrive on these ingress ports will get 
scheduled following the specified priorities.

2. Forward high priority network traffic

A remote network element sends traffic to Open vSwitch. The remote network
element, indicates the class of service to which this flow of traffic belongs
to by modifying a pre-determined but arbitrary field in the frame as specified
in Use Case 1. Some examples include the Differentiated Services Code Point
(DSCP) in an IP packet or the Priority Code Point (PCP) in an Ethernet frame.
The order that frames get processed by Open vSwitch can be guaranteed by the
values populated in these fields when the fields are different. If the fields
are the same, ordering is not deterministic.

For example: Packet A is sent with a DSCP value of 0 and packet B is sent
with a value of 46; 0 has a lower priority than 46. Packet A arrives 
before packet B. If Open vSwitch has been configured as such, Packet
B will be transmitted before Packet A.

Proposed change
===============

TBD

Alternatives
------------

TBD

OVSDB schema impact
-------------------

TBD

User interface impact
---------------------

TBD

Security impact
---------------

TBD

Other end user impact
---------------------

TBD

Performance Impact
------------------

TBD

Other deployer impact
---------------------

TBD

Developer impact
----------------

TBD

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

TBD

Dependencies
============

TBD

Testing
=======

TBD

Documentation Impact
====================

TBD

References
==========

Please add any useful references here. You are not required to have any
reference. Moreover, this specification should still make sense when your
references are unavailable. Examples of what you could include are:

* Links to mailing list or IRC discussions

- http://lists.opnfv.org/pipermail/opnfv-tech-discuss/2015-December/007193.html
- http://ircbot.wl.linuxfoundation.org/meetings/opnfv-ovsnfv/2016/opnfv-ovsnfv.2016-03-07-13.01.html

* Links to relevant research, if appropriate

- https://wiki.opnfv.org/download/attachments/5046510/qos_mechanisms.pdf?version=1&modificationDate=1459187636000&api=v2

Notes from discussion at QoS breakout at ONS March 2015
- http://people.redhat.com/therbert/OPNFVatONS_0315/QoSBreakoutSession1.jpg

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
   * - Colorado
     - Introduced
