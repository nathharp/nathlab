#!/bin/bash
default=192.168.0.4
read -p "Enter IP address [$default]: " REPLY
REPLY=${REPLY:-$default}
echo "IP is $REPLY"
