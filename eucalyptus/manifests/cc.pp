class eucalyptus::cc ($cloud_name = "cloud1", $cluster_name = "cluster1", 
					  $euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     			   	  $eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url) {

  include eucalyptus::conf
  Class['eucalyptus'] -> Class[eucalyptus::cc]
  if ! defined(Class["eucalyptus"]) {
	class{"eucalyptus": 
  		euca2ools_url => $euca2ools_url,
  		eucalyptus_url => $eucalyptus_url
  	}
  }
  

  class eucalyptus::cc_install {
    package { 'eucalyptus-cc':
      ensure => present,
    }
    service { 'eucalyptus-cc':
      ensure => running,
      enable => true,
    }
  }

  class eucalyptus::cc_config {
    File <<|title == "${cloud_name}_cloud_cert"|>>
    File <<|title == "${cloud_name}_cloud_pk"|>>
    File <<|title == "${cloud_name}_${cluster_name}_cluster_cert"|>>
    File <<|title == "${cloud_name}_${cluster_name}_cluster_pk"|>>
    File <<|title == "${cloud_name}_${cluster_name}_node_cert"|>>
    File <<|title == "${cloud_name}_${cluster_name}_node_pk"|>>
    Package[eucalyptus-cc] -> Eucalyptus_config<||> -> Service[eucalyptus-cc]
  }

  class eucalyptus::cc_reg {
    Package <||> -> Class[eucalyptus::cc_reg] -> Class[eucalyptus::cc_config]
    @@exec { "reg_cc_${hostname}":
      command => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync --register-cluster --partition $cluster_name --host $ipaddress --component cc_$hostname",
      unless  => "/usr/sbin/euca_conf --list-clusters | /bin/grep -q '\b$ipaddress\b'",
      tag => "${cloud_name}",
    }
    # Register NC's from CC
    Exec <<|tag == "${cloud_name}_${cluster_name}_reg_nc"|>>
  }

  include eucalyptus::cc_install, eucalyptus::cc_config, eucalyptus::cc_reg
}
