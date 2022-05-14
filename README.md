# Interactive_IPTABLES
Four separate bash scripts to edit iptable rules on a unix system using an interactive cli. 
* ./addrule_fw.sh
- This script will allow the user to create custom stateful rules for outbound packets to specific Ports and/or IP addresses using an interactive cli menu.

* ./reset_fw.sh
- This script will simply reset all firewall rules back to default (Flush and policies set to ACCEPT for all chains).

* ./default_fw.sh
- This script initially sets up the firewall with default configurations. All policies are set to DROP. Outbound http/https connections are successful. Stateful packets part of an existing or new connection are accepted. Telnet is blocked. SSH is accepted. All TCP packets with the SYN and FIN bit set are dropped. 

* ./delrule_fw.sh
- This final script allows the deletion of a specific firewall rules using an interactive cli menu

## Compatability
* Built using Bash shell

# How To
## Usage:
* Ensure that scripts have r/x permissions
* Ensure that scripts are run w/ sudo
* No options are needed for any of the scripts
  
## Options:
* N/A


# Quickstart
1) Download .ZIP File and extract to a directory of your choice
2) Navigate to the directory, or run with absolute path
3) i.e.  ```sudo ./addrule_fw.sh | sudo ./delrule_fw.sh | sudo default_fw.sh | sudo reset_fw.sh```


# Example Output
## Basic Interface
![image](https://user-images.githubusercontent.com/77559638/168447014-24cbec03-0304-42b3-8b68-b27d7a4320b5.png)

![image](https://user-images.githubusercontent.com/77559638/168447036-c8ed9afe-bacd-4307-982f-37c28b06f4a4.png)


