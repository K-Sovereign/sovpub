#!/bin/bash

# This script sets a static IP address on a Debian-based system using /etc/network/interfaces.
# Modify the variables below to suit your network configuration.

# Ensure the script is run as root

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi
# Variables - edit these as needed
INTERFACE="eth0"
STATIC_IP="192.168.1.100"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS="8.8.8.8 8.8.4.4"


# Backup current interfaces file
cp /etc/network/interfaces /etc/network/interfaces.bak

# Write new configuration
bash -c "cat > /etc/network/interfaces" <<EOL
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $INTERFACE
iface $INTERFACE inet static
    address $STATIC_IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS
EOL

echo "Network configuration updated. Please restart networking or reboot for changes to take effect."