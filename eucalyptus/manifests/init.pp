# This is the baseclass for Eucalyptus installs. This class sets up the yum repos
# for Eucalyptus and dependencies. 
#
# == Parameters
#
# [*version*] The version of Eucalyptus we are installing. Defaults to 3.1.
#
# == Examples
#
# class { eucalyptus: version => '3.1' }  
#
#
# == Authors
#
# Teyo Tyree <teyo@puppetlabs.com\>
# David Kavanagh <david.kavanagh@eucalyptus.com\>
# Tom Ellis <tom.ellis@eucalyptus.com\>
#
# == Copyright
#
# Copyright 2012 Eucalyptus INC under the Apache 2.0 license
#
class eucalyptus ( $euca2ools_url  = $eucalyptus::repo::defaults::euca2ools_url,
     			   $eucalyptus_url = $eucalyptus::repo::defaults::eucalyptus_url)
{
  include eucalyptus::extrarepo
  include eucalyptus::security
  class{"eucalyptus::repo": 
  		euca2ools_url => $euca2ools_url,
  		eucalyptus_url => $eucalyptus_url
  }
}

