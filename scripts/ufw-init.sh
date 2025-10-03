#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo to execute it." 
   exit 1
fi

echo "Setting up UFW with SovARTIA SOP configuration..."

# Reset UFW to default settings
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH connections
# ufw allow 27121
ufw limit 27121

# Allow other connections
# ufw allow out 53
ufw allow out 123/udp
ufw allow out 80/udp
ufw allow 445/tcp

# Allow access to SSH
ufw allow from 192.168.50.106 to any port 27121 proto tcp
ufw allow from 192.168.50.48 to any port 27121 proto tcp
ufw allow from 192.168.50.193 to any port 27121 proto tcp

# Deny connections
ufw deny in from 224.0.0.0/4
ufw deny in from 240.0.0.0/5
ufw deny in from 0.0.0.0/8
ufw deny in from 127.0.0.0/8

# Enable logging
ufw logging medium

# Enable UFW
ufw --force enable

# Display UFW status
echo "UFW has been configured with the following rules:"
ufw status verbose
