#!/bin/bash
set -e

# Ensure prerequisites are installed
sudo apt-get update
sudo apt-get install -y wget git

# Install salt
cd /tmp
wget -O install_salt.sh http://bootstrap.saltstack.com
sudo sh install_salt.sh -P
sudo service salt-minion stop

# Get the data and copy it to the right destinations
git clone https://github.com/maruina/acme-esc
cd acme-esc
sudo cp -R salt /srv
sudo cp -R pillar /srv
sudo mv -f minion /etc/salt/minion

# Let's the magic happens
sudo salt-call state.highstate