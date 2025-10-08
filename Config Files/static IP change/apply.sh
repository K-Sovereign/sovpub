#!/bin/bash

# Copy the netplan configuration file to the appropriate directory
curl -fsSL https://raw.githubusercontent.com/K-Sovereign/sovpub/refs/heads/main/configs/static%20IP%20change/netplan -o /etc/netplan/01-netcfg.yaml

# Apply the new netplan configuration
netplan apply