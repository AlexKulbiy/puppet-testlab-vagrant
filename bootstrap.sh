#!/bin/bash
set -exu
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

[agent]
server=master
environment=production
END
) > /etc/puppet/puppet.conf

echo "192.168.33.10 master" >> /etc/hosts

# (cat <<"END"
# path /run                                                                                                                                                                                       
# allow *
# END
# ) > /etc/puppet/auth.conf

echo "Enabling autostart for Puppet..."
cat /etc/default/puppet | sed s/START=no/START=yes/g > /etc/default/puppet.tmp && mv /etc/default/puppet.tmp /etc/default/puppet

echo "Stating Puppet ..."
service puppet start

echo "Installing MCollective..."
apt-get install mcollective-facter-facts mcollective-puppet-agent -y
