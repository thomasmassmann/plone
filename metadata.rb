name             'plone'
maintainer       'Propertyshelf, Inc.'
maintainer_email 'development@propertyshelf.com'
license          'Apache 2.0'
description      'Installs/Configures plone'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ debian ubuntu }.each do |os|
  supports os
end

%w{ python }.each do |cb|
  depends cb
end

recipe "plone", "Installs a Plone CMS with ZEO Server, ZEO Client(s) and Load Balancer."
recipe "plone::zeo", "Installs the Plone ZEO Server."
recipe "plone::app", "Installs the Plone ZEO Client."
