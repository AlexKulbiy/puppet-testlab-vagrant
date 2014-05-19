#!/bin/bash
set -exu
# Enable truly non interactive apt-get installs
export DEBIAN_FRONTEND=noninteractive

RELEASE=`lsb_release -cs`

echo "Adding Puppetlabs repository..."
wget -O /tmp/puppetlabs-release-${RELEASE}.deb http://apt.puppetlabs.com/puppetlabs-release-${RELEASE}.deb
dpkg -i /tmp/puppetlabs-release-${RELEASE}.deb

echo "Updating APT repositories..."
apt-get update && apt-get upgrade -y

echo "Installing puppet and facter..."
apt-get install puppet facter -y

echo "Wrinting puppet conf..."
(cat <<"END"
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

END
) > /etc/puppet/puppet.conf

echo "Installing MCollective..."
apt-get install activemq mcollective mcollective-client mcollective-facter-facts mcollective-puppet-client -y

echo "Downloading and installing ActiveMQ configuration..."
wget -O /etc/activemq/instances-available/main/activemq.xml https://raw.github.com/puppetlabs/marionette-collective/master/ext/activemq/examples/single-broker/activemq.xml
ln -s ../instances-available/main /etc/activemq/instances-enabled/main
service activemq restart
