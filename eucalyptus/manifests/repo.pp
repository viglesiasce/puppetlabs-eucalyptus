# This class sets up the repos for Eucalyptus and dependencies. 
#
# == Parameters
#
# [*version*] The version of Eucalyptus we are installing. Defaults to 3.1.
#
# == Authors
#
# Teyo Tyree <teyo@puppetlabs.com\>
# David Kavanagh <david.kavanagh@eucalyptus.com\>
# Tom Ellis <tom.ellis@eucalyptus.com\>
# Olivier Renault <olivier.renault@eucalyptus.com\>
#
# == Copyright
#
# Copyright 2012 Eucalyptus INC under the Apache 2.0 license
#

class eucalyptus::repo::defaults {
     $euca2ools_url = $operatingsystem ? {
       /(?i-mx:ubuntu|debian)/        => 'http://downloads.eucalyptus.com/software/euca2ools/2.1/ubuntu',
       /(?i-mx:centos|fedora|redhat)/ => "http://downloads.eucalyptus.com/software/euca2ools/2.1/rhel/\$releasever/\$basearch",
     }
     $eucalyptus_url = $operatingsystem ? {
       /(?i-mx:ubuntu|debian)/        => 'http://downloads.eucalyptus.com/software/eucalyptus/3.1/ubuntu',
       /(?i-mx:centos|fedora|redhat)/ => "http://downloads.eucalyptus.com/software/eucalyptus/3.1/rhel/\$releasever/\$basearch",
     }
    }

class eucalyptus::repo(
     $euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     $eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url
    ) inherits eucalyptus::repo::defaults {
  # Check which OS we are installing on
  case $operatingsystem  {
    # there should a way to distinguish 
    redhat, centos : {
      yumrepo { "Eucalyptus-repo":
        name    => "eucalyptus",
        descr   => "Eucalyptus Repository",
        enabled => 1,
        baseurl => $eucalyptus_url,
        gpgkey  => "http://www.eucalyptus.com/sites/all/files/c1240596-eucalyptus-release-key.pub",
      }
      yumrepo { "Euca2ools-repo":
        name    => "euca2ools",
        descr   => "Euca2ools Repository",
        enabled => 1,
        baseurl => $euca2ools_url,
        gpgkey  => "http://www.eucalyptus.com/sites/all/files/c1240596-eucalyptus-release-key.pub",
      }
    }
    ubuntu : {
      apt::source { 'eucalyptus':
  					location   => $eucalyptus_url,
  					repos      => 'main',
  					key        => 'c1240596',
  					key_server => 'pgp.mit.edu',
	  }
      apt::source { 'euca2ools':
  					location   => $euca2ools_url,
  					repos      => 'main',
  					key        => 'c1240596',
  					key_server => 'pgp.mit.edu',
	  }
	  
      exec {"update-repo":
        command => "/usr/bin/apt-get update",
        onlyif => "/usr/bin/test -f /etc/apt/sources.list.d/euca2ools.list",
      }
      Apt::Source<||> -> Exec["update-repo"] -> Package<||> 
    }
  }
}

class eucalyptus::extrarepo {
  case $operatingsystem  {
    centos, redhat : {
      # Install other repository required for Eucalyptus
      # Eucalyptus is keeping a copy of their repository RPM 
      # So we can install their repo package directly from Eucalyptus repo
      $repo_packages = ['elrepo-release', 'epel-release']
        package { $repo_packages:
          ensure  => latest,
          require => Class[eucalyptus::repo],
      }
    }
  }
} 
