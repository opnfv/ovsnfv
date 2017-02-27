.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

==========================================
High Priority Traffic Path
==========================================

https://wiki.opnfv.org/display/ovsnfv/OVSFV+Requirement+-+High+Priority+Traffic+Path

Problem description
===================

A network design may need to adequately accommodate multiple classes of traffic, each
class requiring different levels of service in critical network elements.

As a concrete example, a network element managed by a service provider may be
handling voice and elastic data traffic. Voice traffic requires that the end-to-end
latency and jitter is bounded to some numerical limit (in msec) accuracy in order to ensure
sufficient quality-of-service (QoS) for the participants in the voice call.
Elastic data traffic does not impose the same demanding requirements on the network
(there will be essentially no requirement on jitter. For example, when downloading a
large file across the Internet, although the bandwidth requirements may be high there
is usually no requirement that the file arrives within a bounded time interval.

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
will be represented by the value of a particular field in a frame. The class
of service determines the priority treatment which flows in the class will
receive, while maintaining a relative level of priority for other classes and
a default level of treatment for the lowest priority class of service. As
such, each class of service will be associated with a priority. The End User
will associate classes of service and priorities to ingress ports with the
expectation that frames that arrive on these ingress ports will get
scheduled following the specified priorities.

Note: Priority treatment of the classes of service cannot cause any one of
the classes (even the default class) from being transferred at all. In other
words, a strict priority treatment would likely not be successful for serving
all classes eventually, and this is a key consideration.

2. Forward high priority network traffic

A remote network element sends traffic to Open vSwitch. The remote network
element, indicates the class of service to which this flow of traffic belongs
to by modifying a pre-determined but arbitrary field in the frame as specified
in Use Case 1. Some examples include the Differentiated Services Code Point
(DSCP) in an IP packet or the Priority Code Point (PCP) in an Ethernet frame.
The relative priority treatment that frames get processed by Open vSwitch can be guaranteed by the
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

In order to test how effectively the virtual switch handles high priority traffic
types, the following scheme is suggested.::

                   +---------------------------+         Ingress Traffic Parameters
                   |                           |         +-------------------------------------------+
                   |                           |
                   |                           |         Packet Size: The size of the Ethernet frames
                   |                           |
                   |                           |         Tmax: RFC2544 Max. Throughput for traffic of
                   |                    PHY0   <-------+ "Packet Size"
                   |                           |
                   |                           |         Total Offered Rate: The offered rate of both
                   |                           |         traffic classes combined expressed as a % of
                   |                           |         Tmax
                   |                           |
                   |                           |         Ingress Rates are expressed as a percentage
                   |                           |         of Total Offered Rate.
                   |                           |
                   |                           |         Class A:
                   |             OVS           |         Ethernet PCP = 0 (Background)
                   |            (BR0)          |         Ingress Rate      : rate_ingress_a(n) Mfps
                   |                           |
                   |                           |         Class B:
                   |                           |         Ethernet PCP = 7 (Highest)
                   |                           |         Ingress Rate      : rate_ingress_b(n) Mfps
                   |                           |
                   |                           |         Egress Traffic Measurements
                   |                           |         +-------------------------------------------+
                   |                           |         Class A:
                   |                           |         Egress Throughput : rate_egress_a(n) Mfps
                   |                           |         Egress Latency    : max_lat_egrees_a(n) ms
                   |                           |         Egress Jitter     : max_jit_egress_a(n) ms
                   |                    PHY1   +------->
                   |                           |         Class B:
                   |                           |         Egress Throughput : rate_egress_b(n) Mfps
                   |                           |         Egress Latency    : max_lat_egrees_b(n) ms
                   +---------------------------+         Egress Jitter     : max_jit_egress_b(n) ms


Open vSwitch is configured to forward traffic between two ports agnostic to the
traffic type. For example, using the following command:

ovs-ofctl add-flow br0 in_port=0,actions=output:1

The test will be carried out with the functionality to enable high-priority
traffic enabled and disabled in order to guage the change in performance for
both cases.

Two classes of traffic will be generated by a traffic generator. In the example
above, the classes are differentiated using the Ethernet PCP field. However,
another means for differentiating traffic could be used, depending the
prioritization scheme that is developed.

Tests should be performed for each combination of:

* Packet Sizes in (64, 512)
* Total Offered Rate in (80, 120, 150)
* rate_ingress_b(n) / rate_ingress_a(n) in (0.1, 0.2, 0.5)

For each set, the following metrics should be collected for each traffic
class over a specified time period:

Egress Throughput (Mfps)
Maximum Egress Latency (ms)
Maximum Egress Jitter (ms)

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
