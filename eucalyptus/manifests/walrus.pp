class eucalyptus::walrus ($cloud_name = "cloud1", 
					  		$euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     			   	  		$eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url) {
  include eucalyptus::jvm 
  include eucalyptus::walrus_reg
  Class[eucalyptus] -> Class[eucalyptus::walrus]
  if ! defined(Class["eucalyptus"]) {
	class{"eucalyptus": 
  		euca2ools_url => $euca2ools_url,
  		eucalyptus_url => $eucalyptus_url
  	}
  }
  package { 'eucalyptus-walrus':
    ensure => present,
  }
  Package['eucalyptus-walrus'] -> Class[eucalyptus::jvm ] -> Class[eucalyptus::walrus_reg] -> File<<| tag == "${cloud_name}" |>>
  
  class eucalyptus::walrus_reg {
    @@exec { "reg_walrus_${hostname}":
    	command => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync --register-walrus --partition walrus --host $ipaddress --component walrus_$hostname",
    	unless => "/usr/sbin/euca_conf --list-walruses | /bin/grep '\b$ipaddress\b'",
    	tag => "${cloud_name}",
  	}
  }
  File <<|title == "${cloud_name}_euca.p12"|>>
  Package[eucalyptus-walrus] -> Eucalyptus_config<||> -> Service[eucalyptus-cloud]
}
