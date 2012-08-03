class eucalyptus::nc ($cloud_name = "cloud1") {
  Class[eucalyptus] -> Class[eucalyptus::nc]

  include eucalyptus::conf

  package { 'eucalyptus-nc':
    ensure => present,
  }
  service { 'eucalyptus-nc':
    ensure => running,
    enable => true,
  }
  Package[eucalyptus-nc] -> Eucalyptus_config<||> -> Service[eucalyptus-nc]
  Eucalyptus_config <||> { notify => Service["eucalyptus-nc"] }
  @@exec { "reg_nc_${hostname}":
    command => "/usr/sbin/euca_conf --no-rsync --no-sync --no-scp --register-nodes $ipaddress_br0; exit 0",
    tag => "${cloud_name}_reg_nc",
  }
  File <<|title == "${cloud_name}-cluster1-cc-cert"|>>
  File <<|title == "${cloud_name}-cluster1-nc-cert"|>>
  File <<|title == "${cloud_name}-cluster1-nc-pk"|>>
  File <<|title == "${cloud_name}-cloud-cert"|>>
}
