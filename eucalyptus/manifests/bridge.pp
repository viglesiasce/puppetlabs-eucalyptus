class eucalyptus::bridge ($bridge_name = "br0", $physical_interface = "eth0") {
	case $operatingsystem  {
    # there should a way to distinguish 
    	ubuntu : {
    		service { 'networking':
      					provider => 'upstart', 
    		}
    		file { "/etc/network/interfaces":
  					owner => root,
  					group => root,
 					mode => 644,
 					
 					content => template("eucalyptus/ubuntu_bridge_dhcp.erb")
				}
			File["/etc/network/interfaces"] ~> Service['networking']
    	}
    
	}

}