%global _hardened_build 1

# option to build without dpdk
%bcond_without dpdk
%define dpdk_ver 2.2.0

%define ver 2.5.90
%define rel 1
%define snapver 11975.NSH7d433ae5

%define srcver %{ver}%{?snapver:-%{snapver}}

# If wants to run tests while building, specify the '--with check'
# option. For example:
# rpmbuild -bb --with check openvswitch.spec

Name: openvswitch
Version: %{ver}
Release: %{?snapver:0.%{snapver}.}%{rel}%{?dist}
Summary: Open vSwitch daemon/database/utilities

# Nearly all of openvswitch is ASL 2.0.  The bugtool is LGPLv2+, and the
# lib/sflow*.[ch] files are SISSL
# datapath/ is GPLv2 (although not built into any of the binary packages)
# python/compat is Python (although not built into any of the binary packages)
License: ASL 2.0 and LGPLv2+ and SISSL
URL: http://openvswitch.org
#Source0: http://openvswitch.org/releases/%{name}-%{version}%{?snap_gitsha}.tar.gz
Source0: %{name}-%{srcver}.tar.gz

# Add vxLan gpe NSH
Patch1: 0001-ovs-vxlan-gpe-vxlan-extension-to-support-vxlan-gpe-t.patch
Patch2: 0002-ovs-nsh-support-push-and-pop-actions-for-vxlan-gpe-a.patch
Patch3: 0003-Add-userspace-dataplane-nsh-support-and-remove-push_.patch
Patch4: 0004-Fix-too-large-stack-frame-size.patch
Patch5: 0005-Ethernet-header-must-be-kept-in-VxLAN-gpe-eth-NSH-fo.patch
Patch6: 0006-Fix-VxLAN-gpe-Eth-NSH-issues.patch

ExcludeArch: ppc


BuildRequires: autoconf automake libtool
BuildRequires: systemd-units openssl openssl-devel
BuildRequires: python python-twisted-core python-zope-interface PyQt4
BuildRequires: desktop-file-utils python-six
BuildRequires: groff graphviz

%if %{with dpdk}
BuildRequires: dpdk-devel >= %{dpdk_ver}
BuildRequires: autoconf automake
Provides: %{name}-dpdk = %{version}-%{release}
%endif

Requires: openssl iproute module-init-tools

Requires(post): systemd-units
Requires(preun): systemd-units
Requires(postun): systemd-units
Obsoletes: openvswitch-controller <= 0:2.1.0-1

%bcond_with check

%description
Open vSwitch provides standard network bridging functions and
support for the OpenFlow protocol for remote per-flow control of
traffic.

%package -n python-openvswitch
Summary: Open vSwitch python bindings
License: ASL 2.0
BuildArch: noarch
Requires: python

%description -n python-openvswitch
Python bindings for the Open vSwitch database

%package test
Summary: Open vSwitch testing utilities
License: ASL 2.0
BuildArch: noarch
Requires: python-openvswitch = %{version}-%{release}
Requires: python python-twisted-core python-twisted-web

%description test
Utilities that are useful to diagnose performance and connectivity
issues in Open vSwitch setup.

%package devel
Summary: Open vSwitch OpenFlow development package (library, headers)
License: ASL 2.0
Provides: openvswitch-static = %{version}-%{release}

%description devel
This provides static library, libopenswitch.a and the openvswitch header
files needed to build an external application.

%package ovn-central
Summary: Open vSwitch - Open Virtual Network support
License: ASL 2.0
Requires: openvswitch openvswitch-ovn-common

%description ovn-central
OVN, the Open Virtual Network, is a system to support virtual network
abstraction.  OVN complements the existing capabilities of OVS to add
native support for virtual network abstractions, such as virtual L2 and L3
overlays and security groups.

%package ovn-host
Summary: Open vSwitch - Open Virtual Network support
License: ASL 2.0
Requires: openvswitch openvswitch-ovn-common

%description ovn-host
OVN, the Open Virtual Network, is a system to support virtual network
abstraction.  OVN complements the existing capabilities of OVS to add
native support for virtual network abstractions, such as virtual L2 and L3
overlays and security groups.

%package ovn-vtep
Summary: Open vSwitch - Open Virtual Network support
License: ASL 2.0
Requires: openvswitch openvswitch-ovn-common

%description ovn-vtep
OVN vtep controller
%package ovn-common
Summary: Open vSwitch - Open Virtual Network support
License: ASL 2.0
Requires: openvswitch

%description ovn-common
Utilities that are use to diagnose and manage the OVN components.

%package ovn-docker
Summary: Open vSwitch - Open Virtual Network support
License: ASL 2.0
Requires: openvswitch openvswitch-ovn-common python-openvswitch

%description ovn-docker
Docker network plugins for OVN.

%prep
%setup -q -n %{name}-%{srcver}
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1

%build
%if %{with dpdk}
unset RTE_SDK
. /etc/profile.d/dpdk-sdk-%{_arch}.sh
%endif

autoreconf -i
%configure \
	--enable-ssl \
%if %{with dpdk}
	--with-dpdk=${RTE_SDK}/${RTE_TARGET} \
%endif
	--with-pkidir=%{_sharedstatedir}/openvswitch/pki \

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

install -d -m 0755 $RPM_BUILD_ROOT%{_sysconfdir}/openvswitch

install -p -D -m 0644 \
        rhel/usr_share_openvswitch_scripts_systemd_sysconfig.template \
        $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/openvswitch
for service in openvswitch openvswitch-nonetwork \
		ovn-controller ovn-controller-vtep ovn-northd; do
        install -p -D -m 0644 \
                        rhel/usr_lib_systemd_system_${service}.service \
                        $RPM_BUILD_ROOT%{_unitdir}/${service}.service
done

install -m 0755 rhel/etc_init.d_openvswitch \
        $RPM_BUILD_ROOT%{_datadir}/openvswitch/scripts/openvswitch.init

install -p -D -m 0644 rhel/etc_logrotate.d_openvswitch \
        $RPM_BUILD_ROOT/%{_sysconfdir}/logrotate.d/openvswitch

install -m 0644 vswitchd/vswitch.ovsschema \
        $RPM_BUILD_ROOT/%{_datadir}/openvswitch/vswitch.ovsschema

install -d -m 0755 $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/network-scripts/
install -p -m 0755 rhel/etc_sysconfig_network-scripts_ifdown-ovs \
        $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/network-scripts/ifdown-ovs
install -p -m 0755 rhel/etc_sysconfig_network-scripts_ifup-ovs \
        $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/network-scripts/ifup-ovs

install -d -m 0755 $RPM_BUILD_ROOT%{python_sitelib}
mv $RPM_BUILD_ROOT/%{_datadir}/openvswitch/python/* \
   $RPM_BUILD_ROOT%{python_sitelib}
rmdir $RPM_BUILD_ROOT/%{_datadir}/openvswitch/python/

install -d -m 0755 $RPM_BUILD_ROOT/%{_sharedstatedir}/openvswitch

install -d -m 0755 $RPM_BUILD_ROOT%{_includedir}/openvswitch
install -p -D -m 0644 include/openvswitch/*.h \
        -t $RPM_BUILD_ROOT%{_includedir}/openvswitch
install -p -D -m 0644 config.h \
        -t $RPM_BUILD_ROOT%{_includedir}/openvswitch

install -d -m 0755 $RPM_BUILD_ROOT%{_includedir}/openvswitch/lib
install -p -D -m 0644 lib/*.h \
        -t $RPM_BUILD_ROOT%{_includedir}/openvswitch/lib

install -d -m 0755 $RPM_BUILD_ROOT%{_includedir}/openflow
install -p -D -m 0644 include/openflow/*.h \
        -t $RPM_BUILD_ROOT%{_includedir}/openflow

touch $RPM_BUILD_ROOT%{_sysconfdir}/openvswitch/conf.db
touch $RPM_BUILD_ROOT%{_sysconfdir}/openvswitch/system-id.conf

# remove non-packaged files from the buildroot
rm -f %{buildroot}%{_bindir}/ovs-benchmark
rm -f %{buildroot}%{_bindir}/ovs-parse-backtrace
rm -f %{buildroot}%{_bindir}/ovs-pcap
rm -f %{buildroot}%{_bindir}/ovs-tcpundump
rm -f %{buildroot}%{_sbindir}/ovs-vlan-bug-workaround
rm -f %{buildroot}%{_mandir}/man1/ovs-benchmark.1
rm -f %{buildroot}%{_mandir}/man1/ovs-pcap.1
rm -f %{buildroot}%{_mandir}/man1/ovs-tcpundump.1
rm -f %{buildroot}%{_mandir}/man8/ovs-vlan-bug-workaround.8
rm -f %{buildroot}%{_datadir}/openvswitch/scripts/ovs-save

%check
%if %{with check}
    if make check TESTSUITEFLAGS='%{_smp_mflags}' ||
       make check TESTSUITEFLAGS='--recheck'; then :;
    else
        cat tests/testsuite.log
        exit 1
    fi
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%preun
%if 0%{?systemd_preun:1}
    %systemd_preun %{name}.service
%else
    if [ $1 -eq 0 ] ; then
    # Package removal, not upgrade
        /bin/systemctl --no-reload disable %{name}.service >/dev/null 2>&1 || :
        /bin/systemctl stop %{name}.service >/dev/null 2>&1 || :
    fi
%endif

%preun ovn-central
%if 0%{?systemd_preun:1}
    %systemd_preun ovn-northd.service
%else
    if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        /bin/systemctl --no-reload disable ovn-northd.service >/dev/null 2>&1 || :
        /bin/systemctl stop ovn-northd.service >/dev/null 2>&1 || :
    fi
%endif

%preun ovn-host
%if 0%{?systemd_preun:1}
    %systemd_preun ovn-controller.service
%else
    if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        /bin/systemctl --no-reload disable ovn-controller.service >/dev/null 2>&1 || :
        /bin/systemctl stop ovn-controller.service >/dev/null 2>&1 || :
    fi
%endif

%preun ovn-vtep
%if 0%{?systemd_preun:1}
    %systemd_preun ovn-controller-vtep.service
%else
    if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        /bin/systemctl --no-reload disable ovn-controller-vtep.service >/dev/null 2>&1 || :
        /bin/systemctl stop ovn-controller-vtep.service >/dev/null 2>&1 || :
    fi
%endif

%post
%if 0%{?systemd_post:1}
    %systemd_post %{name}.service
%else
    # Package install, not upgrade
    if [ $1 -eq 1 ]; then
        /bin/systemctl daemon-reload >dev/null || :
    fi
%endif

%post ovn-central
%if 0%{?systemd_post:1}
    %systemd_post ovn-northd.service
%else
    # Package install, not upgrade
    if [ $1 -eq 1 ]; then
        /bin/systemctl daemon-reload >dev/null || :
    fi
%endif

%post ovn-host
%if 0%{?systemd_post:1}
    %systemd_post ovn-controller.service
%else
    # Package install, not upgrade
    if [ $1 -eq 1 ]; then
        /bin/systemctl daemon-reload >dev/null || :
    fi
%endif

%post ovn-vtep
%if 0%{?systemd_post:1}
    %systemd_post ovn-controller-vtep.service
%else
    # Package install, not upgrade
    if [ $1 -eq 1 ]; then
        /bin/systemctl daemon-reload >dev/null || :
    fi
%endif

%postun
%if 0%{?systemd_postun_with_restart:1}
    %systemd_postun_with_restart %{name}.service
%else
    /bin/systemctl daemon-reload >/dev/null 2>&1 || :
    if [ "$1" -ge "1" ] ; then
    # Package upgrade, not uninstall
        /bin/systemctl try-restart %{name}.service >/dev/null 2>&1 || :
    fi
%endif

%postun ovn-central
%if 0%{?systemd_postun_with_restart:1}
    %systemd_postun_with_restart ovn-northd.service
%else
    /bin/systemctl daemon-reload >/dev/null 2>&1 || :
    if [ "$1" -ge "1" ] ; then
    # Package upgrade, not uninstall
        /bin/systemctl try-restart ovn-northd.service >/dev/null 2>&1 || :
    fi
%endif

%postun ovn-host
%if 0%{?systemd_postun_with_restart:1}
    %systemd_postun_with_restart ovn-controller.service
%else
    /bin/systemctl daemon-reload >/dev/null 2>&1 || :
    if [ "$1" -ge "1" ] ; then
        # Package upgrade, not uninstall
        /bin/systemctl try-restart ovn-controller.service >/dev/null 2>&1 || :
    fi
%endif

%postun ovn-vtep
%if 0%{?systemd_postun_with_restart:1}
    %systemd_postun_with_restart ovn-controller-vtep.service
%else
    /bin/systemctl daemon-reload >/dev/null 2>&1 || :
    if [ "$1" -ge "1" ] ; then
        # Package upgrade, not uninstall
        /bin/systemctl try-restart ovn-controller-vtep.service >/dev/null 2>&1 || :
    fi
%endif

%files -n python-openvswitch
%{python_sitelib}/ovs
%doc COPYING

%files test
%{_bindir}/ovs-test
%{_bindir}/ovs-vlan-test
%{_bindir}/ovs-l3ping
%{_mandir}/man8/ovs-test.8*
%{_mandir}/man8/ovs-vlan-test.8*
%{_mandir}/man8/ovs-l3ping.8*
%{python_sitelib}/ovstest

%files devel
%{_libdir}/*.a
%{_libdir}/*.la
%{_includedir}/openvswitch/*
%{_includedir}/openflow/*
%{_libdir}/pkgconfig/*.pc

%files
%defattr(-,root,root)
%dir %{_sysconfdir}/openvswitch
%config %ghost %{_sysconfdir}/openvswitch/conf.db
%config %ghost %{_sysconfdir}/openvswitch/system-id.conf
%config(noreplace) %{_sysconfdir}/sysconfig/openvswitch
%config(noreplace) %{_sysconfdir}/logrotate.d/openvswitch
%{_unitdir}/openvswitch.service
%{_unitdir}/openvswitch-nonetwork.service
%{_datadir}/openvswitch/scripts/openvswitch.init
%{_sysconfdir}/sysconfig/network-scripts/ifup-ovs
%{_sysconfdir}/sysconfig/network-scripts/ifdown-ovs
%{_datadir}/openvswitch/bugtool-plugins/
%{_datadir}/openvswitch/scripts/ovs-bugtool-*
%{_datadir}/openvswitch/scripts/ovs-check-dead-ifs
%{_datadir}/openvswitch/scripts/ovs-lib
%{_datadir}/openvswitch/scripts/ovs-vtep
%{_datadir}/openvswitch/scripts/ovs-ctl
%config %{_datadir}/openvswitch/vswitch.ovsschema
%config %{_datadir}/openvswitch/vtep.ovsschema
%{_sysconfdir}/bash_completion.d/*.bash
%{_bindir}/ovs-appctl
%{_bindir}/ovs-docker
%{_bindir}/ovs-dpctl
%{_bindir}/ovs-dpctl-top
%{_bindir}/ovs-ofctl
%{_bindir}/ovs-vsctl
%{_bindir}/ovsdb-client
%{_bindir}/ovsdb-tool
%{_bindir}/ovs-testcontroller
%{_bindir}/ovs-pki
%{_bindir}/vtep-ctl
%{_sbindir}/ovs-bugtool
%{_sbindir}/ovs-vswitchd
%{_sbindir}/ovsdb-server
%{_mandir}/man1/ovsdb-client.1*
%{_mandir}/man1/ovsdb-server.1*
%{_mandir}/man1/ovsdb-tool.1*
%{_mandir}/man5/ovs-vswitchd.conf.db.5*
%{_mandir}/man5/vtep.5*
%{_mandir}/man8/vtep-ctl.8*
%{_mandir}/man8/ovs-appctl.8*
%{_mandir}/man8/ovs-bugtool.8*
%{_mandir}/man8/ovs-ctl.8*
%{_mandir}/man8/ovs-dpctl.8*
%{_mandir}/man8/ovs-dpctl-top.8*
%{_mandir}/man8/ovs-ofctl.8*
%{_mandir}/man8/ovs-pki.8*
%{_mandir}/man8/ovs-vsctl.8*
%{_mandir}/man8/ovs-vswitchd.8*
%{_mandir}/man8/ovs-parse-backtrace.8*
%{_mandir}/man8/ovs-testcontroller.8*
%doc COPYING DESIGN.md INSTALL.SSL.md NOTICE README.md WHY-OVS.md
%doc FAQ.md NEWS INSTALL.DPDK.md rhel/README.RHEL
/var/lib/openvswitch
/var/log/openvswitch
%ghost %attr(755,root,root) %{_rundir}/openvswitch

%files ovn-docker
%{_bindir}/ovn-docker-overlay-driver
%{_bindir}/ovn-docker-underlay-driver

%files ovn-common
%{_bindir}/ovn-nbctl
%{_bindir}/ovn-sbctl
%{_datadir}/openvswitch/scripts/ovn-ctl
%{_datadir}/openvswitch/scripts/ovn-bugtool-nbctl-show
%{_datadir}/openvswitch/scripts/ovn-bugtool-sbctl-lflow-list
%{_datadir}/openvswitch/scripts/ovn-bugtool-sbctl-show
%{_mandir}/man8/ovn-ctl.8*
%{_mandir}/man8/ovn-nbctl.8*
%{_mandir}/man7/ovn-architecture.7*
%{_mandir}/man8/ovn-sbctl.8*
%{_mandir}/man5/ovn-nb.5*
%{_mandir}/man5/ovn-sb.5*

%files ovn-central
%{_bindir}/ovn-northd
%{_mandir}/man8/ovn-northd.8*
%config %{_datadir}/openvswitch/ovn-nb.ovsschema
%config %{_datadir}/openvswitch/ovn-sb.ovsschema
%{_unitdir}/ovn-northd.service

%files ovn-host
%{_bindir}/ovn-controller
%{_mandir}/man8/ovn-controller.8*
%{_unitdir}/ovn-controller.service

%files ovn-vtep
%{_bindir}/ovn-controller-vtep
%{_mandir}/man8/ovn-controller-vtep.8*
%{_unitdir}/ovn-controller-vtep.service

%changelog
* Mon Apr 04 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11974.gitc4623bb8.1
- New snapshot

* Tue Mar 29 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11929.git1cef5fff.1
- new snapshot
- sync up ovn packaging with upstream (split to many pieces)
- remove trigger for ancient ovs versions

* Wed Mar 23 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11888.git8d679ccd.1
- New snapshot

* Mon Mar 14 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11842.git0bac7164.1
- New snapshot

* Fri Mar 11 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11838.git5fec03b1.1
- New snapshot

* Thu Mar 10 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11831.gitb00b4a81.1
- New snapshot

* Mon Mar 07 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11810.git6019cb63.1
- New snapshot

* Wed Feb 24 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11762.git1589ee5a.1
- New snapshot

* Mon Feb 22 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11731.gitc6bd5e91.1
- New snapshot

* Thu Feb 11 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11686.git7b383a56.1
- New snapshot

* Tue Feb 02 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11590.gitfa47c114.1
- New snapshot
- Buildrequires python-six

* Mon Feb 01 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.90-0.11587.git9167fc1a.1
- New 2.5.90 based snapshot

* Fri Jan 29 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11397.git46a88d99.1
- New snapshot, vhost-user multiqueue support upstreamed

* Tue Jan 26 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11389.git23121bb7.1
- New snapshot

* Wed Jan 13 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11375.git976b4413.1
- New snapshot

* Mon Jan 04 2016 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11351.git98b94d1e.1
- New year, new snapshot
- Drop upstreamed dpdk ports patch

* Wed Dec 16 2015 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11316.gitfe10b446.1
- New snapshot

* Mon Dec 14 2015 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11312.git4bcb548d.1
- New snapshot

* Fri Dec 11 2015 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11304.git176752aa.1
- New snapshot

* Mon Dec 07 2015 Panu Matilainen <pmatilai@redhat.com> - 2.5.0-0.11284.git3e8cc1b4.1
- New snapshot, switch to 2.5 branch
- Buildrequire dpdk >= 2.2 for multiqueue

* Mon Nov 30 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11222.gite696de79.1
- New snapshot

* Thu Nov 26 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11201.gitff882f96.1
- New snapshot

* Wed Nov 25 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11162.gitefee3309.1
- New snapshot
- Remove unpackaged files from buildroot instead of %exclude'ing,
  the latter leaves artifacts into -debuginfo packages (#1281913)

* Fri Nov 20 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11141.git89108874.1
- New snapshot

* Fri Nov 13 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11130.git3e2493e1.3
- Except that on RHEL-7 and older Fedoras -Wl,--as-needed causes build
  failures :( Back to local linker script, without all the pmds.

* Fri Nov 13 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11130.git3e2493e1.2
- Erm, no patches are needed for linkage sanity, just use -Wl,--as-needed

* Fri Nov 13 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11130.git3e2493e1.1
- New snapshot
- Drop no longer needed build hacks now that DPDK can automatically load drivers

* Thu Nov 05 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11104.git994fcc5a.2
- Rebuild against dpdk 2.2.0-rc1

* Thu Nov 05 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11104.git994fcc5a.1
- New snapshot

* Tue Oct 27 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11080.git2a33a3c2.1
- New snapshot
- Add vhost-user multiqueue support (rfc patch v2)

* Thu Oct 22 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-11065.gite2229be9.1
- New snapshot
- Update (and sort) drivers list to match current upstream

* Mon Sep 28 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-10916.gita2cf7524.1
- New snapshot
- Rename internal linker script to libdpdk.so to match upstream dpdk naming

* Wed Aug 12 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-10701.gitb883db24.1
- New snapshot

* Fri Jun 26 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-10461.gite3a4416a.1
- New snapshot

* Tue Jun 23 2015 Panu Matilainen <pmatilai@redhat.com> - 2.4.90-10415.git0eb48fe1.1
- Update 2.4.90 based snapshot
- New -ovn subpackage (copy-pasted from upstream spec)
- Adjust linker script for librte_pmd_virtio_uio -> librte_pmd_virtio change

* Mon Jun 15 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10260.git7d1ced01.1
- New snapshot, vhost-user upstreamed now

* Fri Jun 05 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10215.git3bcc10c0.2
- Update to vhost-user patch v8

* Thu Jun 04 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10215.git3bcc10c0.1
- New snapshot

* Mon May 25 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10151.git8f19f0a7.1
- New snapshot
- Update/rebase to vhost-user patch v7

* Fri May 22 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10140.git048963aa.1
- New snapshot
- Update to vhost-user patch v6

* Wed May 20 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10130.git8aaa125d.2
- Use DPDK NIC defaults (should improve performance)

* Tue May 19 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10130.git8aaa125d.1
- New snapshot
- Update to vhost-user patch v5 which is likely to be upstreamed
- Drop vhost-cuse support from spec

* Wed May 13 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10120.git9899125a.2
- vhost-user patch v4, defaulting to OVS rundir for sockets

* Wed May 13 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10120.git9899125a.1
- New snapshot
- Drop perf patch option, too many patches to carry about
- Drop rx burst size patch, its now upstreamed

* Fri May 08 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10098.git543342a4.4
- Include virtio driver in linker script to support OVS in a VM guest

* Thu May 07 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10098.git543342a4.3
- Add build option for userspace datapath performance improvement patch series

* Tue May 05 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10098.git543342a4.2
- DPDK port configuration via network-scripts, take I

* Thu Apr 30 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10098.git543342a4.1
- Update to new snapshot with official DPDK 2.0 support
- Update to vhost-user RFC v3 with socket directory specification support

* Fri Apr 24 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10031.gitf097013a.4
- Update DPDK 2.0 patch to what has been submitted upstream
- Update vhost-user patch to current public RFC patch

* Tue Apr 21 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10031.gitf097013a.3
- Handle vhost-user/cuse selection automatically based on the copr repo name

* Fri Apr 17 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10031.gitf097013a.2
- Use a custom dpdk linker script to avoid excessive lib dependencies

* Thu Apr 16 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-10031.gitf097013a.1
- New snapshot, including pmd statistics
2
* Thu Apr 09 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9961.gitb3cceba0.2
- Use smaller rx burst size to supposedly improve vhost performance

* Thu Apr 02 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9961.gitb3cceba0.1
- New snapshot
- Switch to vhost-user now that it actually works (with updated patch)
- Only buildrequire fuse-devel with vhost-cuse

* Wed Apr 01 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9960.git508624b6.1
- New snapshot

* Thu Mar 26 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9950.git4e5e44e3.1
- New snapshot
- Add dependency for dpdk vhost-user/cuse support

* Thu Mar 26 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9928.gitda79ce2b.3
- Rebuild for dropped IVSHMEM in dpdk

* Wed Mar 25 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9928.gitda79ce2b.2
- Make vhost-user conditional, disabled by default for now 

* Wed Mar 25 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9928.gitda79ce2b.1
- New snapshot, 1GB hugepages no longer required
- Rebase vhost-user patch again

* Tue Mar 24 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9908.git2c9907cd.3
- Yesterdays vhost-user patch was very broken...

* Mon Mar 23 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9908.git2c9907cd.2
- Add vhost-user support (disables vhost-cuse)

* Mon Mar 23 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9908.git2c9907cd.1
- New snapshot

* Fri Mar 20 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9902.git58397e6c
- New snapshot
- Vhost-cuse upstreamed, drop patch
- Drop problematic kernel require entirely

* Thu Mar 19 2015 Panu Matilainen <pmatilai@redhat.com> - 2.3.90-9900.gitb6b0e049
- New snapshot
- Fixup kernel dependency version on EL7

* Tue Mar 10 2015 Panu Matilainen 2.3.90-9868.git973edd6e.1
- New snapshot
- Include snapshot script in src.rpm

* Thu Mar 05 2015 Panu Matilainen 2.3.90-9862.git7cc398cb.2
- New snapshot style requires automake and libtool on build
- Add explicit -msse4.1 to get it to build on rhel-7

* Thu Mar 05 2015 Panu Matilainen 2.3.90-9862.git7cc398cb.1
- Change snapshot style for easier automation
- New snapshot with DPDK >= 1.8 support upstream
- New version of vhost-cuse patch, rebase to match current upstream

* Wed Mar 04 2015 Panu Matilainen 2.3.90-9.git20150218
- Fix build with recent DPDK snapshots

* Fri Feb 20 2015 Panu Matilainen 2.3.90-8.git20150218
- Support passing arbitrary DPDK options via /etc/sysconfig/openvswitch

* Thu Feb 19 2015 Panu Matilainen 2.3.90-7.git20150218
- Build-require automake + autoconf due to vhost-cuse touching makefiles

* Thu Feb 19 2015 Panu Matilainen 2.3.90-6.git20150218
- Add vhost-cuse patch 
- Comment patch origins

* Wed Feb 18 2015 Panu Matilainen 2.3.90-5.git20150218
- OVS snapshot of the day

* Wed Feb 18 2015 2015 Panu Matilainen 2.3.90-4.git20150202
- Update to latest (hopefully final) dpdk-support patch fron Intel

* Thu Feb 5 2015 Panu Matilainen 2.3.90-3.git20150202
- Another rebuild for versioning change

* Tue Feb 3 2015 Panu Matilainen 2.3.90-2.git20150202
- Rebuild with library versioned dpdk 

* Tue Feb 3 2015 Panu Matilainen 2.3.90-1.git20150202
- OVS snapshot of the day
- Add patch to make it build with DPDK 1.8

* Mon Jan 12 2015 Panu Matilainen 2.3.90-1.git20150112
- Update to 2.3.90-git0f3358ea
- Build with dpdk 1.7.1

* Fri Dec 19 2014 Panu Matilainen 2.3.90-0.git20141219.1
- Update to 2.3.90-git5af43325
- Build with DPDK

* Fri Nov 07 2014 Flavio Leitner - 2.3.0-3.git20141107
- updated to 2.3.0-git39ebb203

* Thu Oct 23 2014 Flavio Leitner - 2.3.0-2
- fixed to own conf.db and system-id.conf in /etc/openvswitch.
  (#1132707)

* Tue Aug 19 2014 Flavio Leitner - 2.3.0-1
- updated to 2.3.0

* Sun Aug 17 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.1.2-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Thu Jun 12 2014 Flavio Leitner - 2.1.2-4
- moved README.RHEL to be in the standard doc dir.
- added FAQ and NEWS files to the doc list.
- excluded PPC arch

* Thu Jun 12 2014 Flavio Leitner - 2.1.2-3
- removed ovsdbmonitor packaging

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.1.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue Mar 25 2014 Flavio Leitner - 2.1.2-1
- updated to 2.1.2

* Tue Mar 25 2014 Flavio Leitner - 2.1.0-1
- updated to 2.1.0
- obsoleted openvswitch-controller package
- requires kernel 3.15.0-0 or newer
  (kernel commit 4f647e0a3c37b8d5086214128614a136064110c3
   openvswitch: fix a possible deadlock and lockdep warning)
- ovs-lib: allow non-root users to check service status
  (upstream commit 691e47554dd03dd6492e00bab5bd6d215f5cbd4f)
- rhel: Add Patch Port support to initscripts
  (upstream commit e2bcc8ef49f5e51f48983b87ab1010f0f9ab1454)

* Mon Jan 27 2014 Flavio Leitner - 2.0.1-1
- updated to 2.0.1

* Mon Jan 27 2014 Flavio Leitner - 2.0.0-6
- create a -devel package
  (from Chris Wright <chrisw@redhat.com>)

* Wed Jan 15 2014 Flavio Leitner <fbl@redhat.com> - 2.0.0-5
- Enable DHCP support for internal ports
  (upstream commit 490db96efaf89c63656b192d5ca287b0908a6c77)

* Wed Jan 15 2014 Flavio Leitner <fbl@redhat.com> - 2.0.0-4
- disabled ovsdbmonitor packaging
  (upstream has removed the component)

* Wed Jan 15 2014 Flavio Leitner <fbl@redhat.com> - 2.0.0-3
- fedora package: fix systemd ordering and deps.
  (upstream commit b49c106ef00438b1c59876dad90d00e8d6e7b627)

* Wed Jan 15 2014 Flavio Leitner <fbl@redhat.com> - 2.0.0-2
- util: use gcc builtins to better check array sizes
  (upstream commit 878f1972909b33f27b32ad2ded208eb465b98a9b)

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 2.0.0-1
- updated to 2.0.0 (#1023184)

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-8
- applied upstream commit 7b75828bf5654c494a53fa57be90713c625085e2
  rhel: Option to create tunnel through ifcfg scripts.

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-7
- applied upstream commit 32aa46891af5e173144d672e15fec7c305f9a4f3
  rhel: Set STP of a bridge during bridge creation.

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-6
- applied upstream commit 5b56f96aaad4a55a26576e0610fb49bde448dabe
  rhel: Prevent duplicate ifup calls.

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-5
- applied upstream commit 79416011612541d103a1d396d888bb8c84eb1da4
  rhel: Return an exit value of 0 for ifup-ovs.

* Mon Oct 28 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-4
- applied upstream commit 2517bad92eec7e5625bc8b248db22fdeaa5fcde9
  Added RHEL ovs-ifup STP option handling

* Tue Oct 1 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-3
- don't use /var/lock/subsys with systemd (#1006412)

* Thu Sep 19 2013 Flavio Leitner <fbl@redhat.com> - 1.11.0-2
- ovsdbmonitor package is optional

* Thu Aug 29 2013 Thomas Graf <tgraf@redhat.com> - 1.11.0-1
- Update to 1.11.0

* Tue Aug 13 2013 Flavio Leitner <fbl@redhat.com> - 1.10.0-7
- Fixed openvswitch-nonetwork to start openvswitch.service (#996804)

* Sat Aug 03 2013 Petr Pisar <ppisar@redhat.com> - 1.10.0-6
- Perl 5.18 rebuild

* Tue Jul 23 2013 Thomas Graf <tgraf@redhat.com> - 1.10.0-5
- Typo

* Tue Jul 23 2013 Thomas Graf <tgraf@redhat.com> - 1.10.0-4
- Spec file fixes
- Maintain local copy of sysconfig.template

* Thu Jul 18 2013 Petr Pisar <ppisar@redhat.com> - 1.10.0-3
- Perl 5.18 rebuild

* Mon Jul 01 2013 Thomas Graf <tgraf@redhat.com> - 1.10.0-2
- Enable PIE (#955181)
- Provide native systemd unit files (#818754)

* Thu May 02 2013 Thomas Graf <tgraf@redhat.com> - 1.10.0-1
- Update to 1.10.0 (#958814)

* Thu Feb 28 2013 Thomas Graf <tgraf@redhat.com> - 1.9.0-1
- Update to 1.9.0 (#916537)

* Tue Feb 12 2013 Thomas Graf <tgraf@redhat.com> - 1.7.3-8
- Fix systemd service dependency loop (#818754)

* Fri Jan 25 2013 Thomas Graf <tgraf@redhat.com> - 1.7.3-7
- Auto-start openvswitch service on ifup/ifdown (#818754)
- Add OVSREQUIRES to allow defining OpenFlow interface dependencies

* Thu Jan 24 2013 Thomas Graf <tgraf@redhat.com> - 1.7.3-6
- Update to Open vSwitch 1.7.3

* Tue Nov 20 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1-6
- Increase max fd limit to support 256 bridges (#873072)

* Thu Nov  1 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1-5
- Don't create world writable pki/*/incomming directory (#845351)

* Thu Oct 25 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1-4
- Don't add iptables accept rule for -p GRE as GRE tunneling is unsupported

* Tue Oct 16 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1-3
- require systemd instead of systemd-units to use macro helpers (#850258)

* Tue Oct  9 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1-2
- make ovs-vsctl timeout if daemon is not running (#858722)

* Mon Sep 10 2012 Thomas Graf <tgraf@redhat.com> - 1.7.1.-1
- Update to 1.7.1

* Fri Sep  7 2012 Thomas Graf <tgraf@redhat.com> - 1.7.0.-3
- add controller package containing ovs-controller

* Thu Aug 23 2012 Tomas Hozza <thozza@redhat.com> - 1.7.0-2
- fixed SPEC file so it comply with new systemd-rpm macros guidelines (#850258)

* Fri Aug 17 2012 Tomas Hozza <thozza@redhat.com> - 1.7.0-1
- Update to 1.7.0
- Fixed openvswitch-configure-ovskmod-var-autoconfd.patch because
  openvswitch kernel module name changed in 1.7.0
- Removed Source8: ovsdbmonitor-move-to-its-own-data-directory.patch
- Patches merged:
  - ovsdbmonitor-move-to-its-own-data-directory-automaked.patch
  - openvswitch-rhel-initscripts-resync.patch

* Fri Jul 20 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.0-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Thu Mar 15 2012 Chris Wright <chrisw@redhat.com> - 1.4.0-5
- fix ovs network initscripts DHCP address acquisition (#803843)

* Tue Mar  6 2012 Chris Wright <chrisw@redhat.com> - 1.4.0-4
- make BuildRequires openssl explicit (needed on f18/rawhide now)

* Tue Mar  6 2012 Chris Wright <chrisw@redhat.com> - 1.4.0-3
- use glob to catch compressed manpages

* Thu Mar  1 2012 Chris Wright <chrisw@redhat.com> - 1.4.0-2
- Update License comment, use consitent macros as per review comments bz799171

* Wed Feb 29 2012 Chris Wright <chrisw@redhat.com> - 1.4.0-1
- Initial package for Fedora
