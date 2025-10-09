
# Purpose of This Folder

This folder provides scripts and drop-in replacements for stock system files related to static IP configuration on Ubuntu systems. Both **netplan** and the traditional **/etc/network/interfaces** file are supported.

## How to Use

1. **Edit Variables:**
	- Before using any script or configuration file, open it and edit the variables at the top to match your network environment (such as interface name, IP address, gateway, etc.).
	- Choose the appropriate folder for your system (netplan or legacy).

2. **Deploy to Target System:**
	- You can easily update files on your target system by using `curl` to download the script or configuration file directly. For example:
	  ```sh
	  curl -O https://your-repo-url/path/to/script.sh
	  ```
	- Then run or move the file as needed for your system.

3. **Apply Changes:**
	- Follow any instructions in the script or comments to apply the changes (e.g., restart networking services or reboot).

---

**Note:**
- These files are intended as drop-in replacements for default system files. Always back up your original files before replacing them.
- Review and test scripts in a safe environment before deploying to production systems.

