class eucalyptus::clc ($cloud_name = "cloud1", 
					   $euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     			   	   $eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url) {
  include eucalyptus::conf
  include eucalyptus::clc_install
  include eucalyptus::clc_config
  include eucalyptus::clc_reg
  Class[eucalyptus] -> Class[eucalyptus::clc]
  if ! defined(Class["eucalyptus"]) {
	class{"eucalyptus": 
  		euca2ools_url => $euca2ools_url,
  		eucalyptus_url => $eucalyptus_url
  	}
  }
  
  class eucalyptus::clc_install {
    package { 'eucalyptus-cloud':
      ensure => present,
    }
    include eucalyptus::jvm
    Package['eucalyptus-cloud'] -> Class[eucalyptus::jvm ]
    
  }
  class eucalyptus::clc_config {
    Package['eucalyptus-cloud'] -> Exec['init-db'] ->  Service['eucalyptus-cloud'] -> Class[eucalyptus::clc_reg] -> File <<| tag == "${cloud_name}" |>>
    
    exec { 'init-db':
      command => "/usr/sbin/euca_conf --initialize",
      creates => "/var/lib/eucalyptus/db/data",
      timeout => "0",
    }

    # Cloud-wide
    @@file { "${cloud_name}-cloud-cert":
      path => '/var/lib/eucalyptus/keys/cloud-cert.pem',
#      content => "$eucakeys_cloud_cert",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    @@file { "${cloud_name}-cloud-pk":
      path => '/var/lib/eucalyptus/keys/cloud-pk.pem',
#      content => "$eucakeys_cloud_pk",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    @@file { "${cloud_name}-euca.p12":
      path => '/var/lib/eucalyptus/keys/euca.p12',
#      content => "$eucakeys_euca_p12",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    
    Eucalyptus_config <||>
  }
  class eucalyptus::clc_reg {
    Service['eucalyptus-cloud'] -> Class[eucalyptus::clc_reg] 
    Exec <<|tag == "$cloud_name"|>>
  }
  
   
  
}
