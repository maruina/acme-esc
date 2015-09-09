#!/bin/bash
set -e

# Ensure prerequisites are installed
apt-get update
apt-get install -y wget git

# Install salt
cd /opt
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -P
service salt-minion stop

# Get the data
git clone 