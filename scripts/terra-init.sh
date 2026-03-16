#!/bin/bash

# 0. Update package information and upgrade all installed packages
sudo apt update && sudo apt upgrade -y

# 1. Install utility dependencies
sudo apt install -y gnupg software-properties-common curl

# 2. Download and install the official HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 3. Verify the key's fingerprint
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# 4. Add the official HashiCorp repository to the system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# 5. Update package information again, install Terraform, and remove unused dependencies
sudo apt update && sudo apt install terraform -y && sudo apt autoremove -y

# 6. Verify that the installation was successful
terraform -help