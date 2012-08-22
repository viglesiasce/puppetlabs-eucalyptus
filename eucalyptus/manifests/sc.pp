class eucalyptus::sc ($cloud_name = "cloud1", $cluster_name= "cluster1", 
					  $euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     			   	  $eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url) {
  include eucalyptus::sc_install, eucalyptus::sc_config, eucalyptus::sc_reg
  
  Class[eucalyptus] -> Class[eucalyptus::sc]
  if ! defined(Class["eucalyptus"]) {
	class{"eucalyptus": 
  		euca2ools_url => $euca2ools_url,
  		eucalyptus_url => $eucalyptus_url
  	}
  }
  class eucalyptus::sc_install {
    package { 'eucalyptus-sc':
      ensure => present,
    }
    include eucalyptus::jvm 
    Package <||> -> Class[eucalyptus::jvm ]
     
  }

  class eucalyptus::sc_config {
    Package[eucalyptus-sc] -> Eucalyptus_config<||> -> Service[eucalyptus-cloud]
    File <<|title == "${cloud_name}_euca.p12"|>>
  }

  class eucalyptus::sc_reg {
    Package <||> -> Class[eucalyptus::sc_reg] -> Class[eucalyptus::sc_config]
    @@exec { "reg_sc_${hostname}":
      command => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync --register-sc --partition ${cluster_name} --host $ipaddress --component sc_$hostname",
      unless => "/usr/sbin/euca_conf --list-scs | /bin/grep '\b$ipaddress\b'",
      tag => "${cloud_name}",
    }
  }

  
}
