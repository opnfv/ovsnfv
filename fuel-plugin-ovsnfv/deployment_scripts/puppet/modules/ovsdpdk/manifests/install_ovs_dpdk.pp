# == Class ovsdpdk::install_ovs_dpdk
#
# Installs ovs-dpdk service together with it's configuration file
# it also deploys qemu-kvm wrapper responsible for enabling some vhostforce
# options and setting huge pages into shared mode
#
class ovsdpdk::install_ovs_dpdk (
  $networking_ovs_dpdk_dir          = $::ovsdpdk::params::networking_ovs_dpdk_dir,
  $plugin_dir                       = $::ovsdpdk::params::plugin_dir,
  $ovs_dir                          = $::ovsdpdk::params::ovs_dir,
  $openvswitch_service_file         = $::ovsdpdk::params::openvswitch_service_file,
  $openvswitch_service_path         = $::ovsdpdk::params::openvswitch_service_path,
  $qemu_kvm                         = $::ovsdpdk::params::qemu_kvm,
) inherits ovsdpdk {
  require ovsdpdk::build_ovs_dpdk

  if $compute == 'True' {
    exec {'create_ovs_dpdk':
      command => "mv /etc/init.d/openvswitch-switch /tmp/openvswitch-switch.bak;\
                  cp ${networking_ovs_dpdk_dir}/devstack/ovs-dpdk/ovs-dpdk-init /etc/init.d/openvswitch-switch;\
                  chmod +x /etc/init.d/openvswitch-switch;\
                  ln -sf /etc/init.d/openvswitch-switch /etc/init.d/ovs-dpdk;\
                  cp /etc/openvswitch/conf.db /etc/openvswitch/conf.db.pre_dpdk",
      user    => root,
      path    => ['/usr/bin','/bin'],
    }

    file {'/etc/default/ovs-dpdk': content => template("${plugin_dir}/files/ovs-dpdk-conf.erb"), mode => '0644' }

    exec {'adapt_conf_file':
      command => "${plugin_dir}/files/tune_params.sh",
      user    => root,
      require => File['/etc/default/ovs-dpdk'],
    }

    package { 'zlib1g-dev':       ensure => 'installed' }
    package { 'libglib2.0-dev':   ensure => 'installed' }
    package { 'libxml2-dev':      ensure => 'installed' }
    package { 'libdevmapper-dev': ensure => 'installed' }
    package { 'libpciaccess-dev': ensure => 'installed' }
    package { 'libnl-dev':        ensure => 'installed' } 
    package { 'pkg-config':       ensure => 'installed' }
    package { 'bison':            ensure => 'installed' }
    package { 'flex':             ensure => 'installed' }
    package { 'libyajl2':         ensure => 'installed' }
    package { 'libyajl-dev':      ensure => 'installed' }
    package { 'python-dev':       ensure => 'installed' }
    package { 'numactl':          ensure => 'installed' }
    package { 'libdbus-1-dev':    ensure => 'installed' }
    package { 'libnuma1':         ensure => 'installed' }
    package { 'libnuma-dev':      ensure => 'installed' }
    package { 'libgnutls26':      ensure => 'installed' }
    package { 'libgnutls-dev':    ensure => 'installed' }

    package { 'bc':               ensure => 'installed' }

    exec {'build qemu':
      command => "true && cd /opt/code/qemu && ./configure --enable-kvm --target-list=x86_64-softmmu && make && make install",
      user    => root,
      path    => ['/usr/bin','/bin'],
      require => [ Package['flex'], Package['bison'], Package['pkg-config'], Package['libnl-dev'],
                   Package['libpciaccess-dev'], Package['libdevmapper-dev'], Package['libxml2-dev'],
                   Package['libglib2.0-dev'], Package['zlib1g-dev'], Package['numactl'], Package['python-dev'],
                   Package['libdbus-1-dev'],Package['bc'],Package['libnuma1'], Package['libnuma-dev'],
                   Package['libgnutls26'], Package['libgnutls-dev']],
      timeout => 0,
    }

    exec {'build libvirt':
      command => "true && cd /opt/code/libvirt && ./configure --prefix=/usr --with-dbus && make && make install",
      user    => root,
      path    => ['/usr/bin','/bin'],
      require => [Exec['build qemu'], Package['libyajl2'], Package['libyajl-dev']],
      timeout => 0,
    }

    exec {'build libvirt-python':
      command => "true && cd /opt/code/libvirt-python && python setup.py build && python setup.py install",
      user    => root,
      path    => ['/usr/bin','/bin'],
      require => Exec['build libvirt'],
      timeout => 0,
    }

    exec { "cp ${qemu_kvm} ${qemu_kvm}.orig":
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${qemu_kvm}",
      require => Exec['build qemu'],
    }

    exec { "cp ${plugin_dir}/files/kvm-wrapper.sh ${qemu_kvm};chmod +x ${qemu_kvm}":
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => "test -f ${qemu_kvm}",
      require => [ Exec["cp ${qemu_kvm} ${qemu_kvm}.orig"], Exec['build qemu'] ],
    }

    exec { 'ln -sf /etc/init.d/libvirtd /etc/init.d/libvirt-bin':
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => 'test -f /etc/init.d/libvirtd',
    }

    # schema convert required as we are not removing original db
    exec { "ovsdb-tool convert /etc/openvswitch/conf.db ${ovs_dir}/vswitchd/vswitch.ovsschema":
      path    => ['/usr/bin','/bin'],
      user    => root,
    }

    # patching of linux_net.py is required for removing error when setting of MTU
    exec { 'patch linux_net':
      command => "cp ${plugin_dir}/files/linux_net.py /usr/lib/python2.7/dist-packages/nova/network/linux_net.py",
      path    => ['/usr/bin','/bin'],
      user    => root,
      onlyif  => 'test -f /usr/lib/python2.7/dist-packages/nova/network/linux_net.py',
    }

  }

  # install mech driver
  exec {'install mech driver':
    command => 'python setup.py install',
    path    => ['/usr/bin','/bin'],
    cwd     => "${networking_ovs_dpdk_dir}",
    user    => root,
  }
}
