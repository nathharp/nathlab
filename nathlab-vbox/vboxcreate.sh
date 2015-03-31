#!/bin/bash

# the objective of this script is to automate the creation of VMs under virtualbox.  Although this could be done under Vagrant, I want to have a bit more control over what is being done!

# example prompt with default
default=192.168.0.4
read -p "Enter IP address [$default]: " REPLY
REPLY=${REPLY:-$default}
echo "IP is $REPLY"
