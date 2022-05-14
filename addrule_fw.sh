#!/bin/bash
#===============================================================================
#
#          FILE:  addrule_fw.sh
# 
#         USAGE:  ./addrule_fw.sh
# 
#   DESCRIPTION:  This script allows the user to interactively create new firewall
#		  rules based on outbound traffic to specific dst IPs and/or Ports. 
#                 This script will use a menu selection where the user selects 
#                 what they want to accomplish. No options are needed to run the 
#                 script 
#
#       OPTIONS:  ---
#  REQUIREMENTS:  1) Script must be given r/x permissions
#                 2) Script must be run with sudo
#          BUGS:  1) If check_port gets a port with numbers at the beginning, followed by letters, an error is produced
#         NOTES:  ---
#        AUTHOR:  Brandon Wittet (), Brandon.wittet@gmail.com
#       COMPANY:  Open Source
#       VERSION:  1.0
#       CREATED:  2022-05-13 02:51:41 PM PDT
#      REVISION:  ---
#===============================================================================


function main () {
	check_args $1
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		echo "Do not specify any options for this script"
		exit 1
	fi

	check_user
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		echo "You must run this program as sudo"
		exit 1
	fi

	menu_selection
	
}    # ----------  end of function main  ----------









# ------------------- Firewall Rules and functions ------------------ #

function port_rule () {
	port=$(check_port)

	printf "Writing rules...\n"
	iptables -I OUTPUT 1 -p tcp --dport "$port" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	iptables -I OUTPUT 1 -p udp --dport "$port" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	sleep 1

	printf "New IPTABLE OUTPUT rules shown below\n"
	iptables -L OUTPUT
	sleep 1

	check_continue
		 
}    # ----------  end of function port_rule  ----------


function ip_rule () {
	ip=$(check_ip)

	printf "Writing rules...\n"
	iptables -I OUTPUT 1 -p tcp -d "$ip" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	iptables -I OUTPUT 1 -p udp -d "$ip" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	sleep 1

	printf "New IPTABLE OUTPUT rules shown below\n"
	iptables -L OUTPUT
	sleep 1

	check_continue
}    # ----------  end of function ip_rule  ----------


function ip_port_rule () {
	ip=$(check_ip)
	port=$(check_port)

	printf "Writing rules...\n"
	iptables -I OUTPUT 1 -p tcp -d "$ip" --dport "$port" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	iptables -I OUTPUT 1 -p udp -d "$ip" --dport "$port" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
	sleep 1

	printf "New IPTABLE OUTPUT rules shown below\n"
	iptables -L OUTPUT
	sleep 1

	check_continue
}    # ----------  end of function ip_port_rule  ----------








# ------------------- Menus and Help Options ------------------ #

function menu_selection () {
	select option in "Port Only" "IP Address Only" "IP and Port" "Help"; do
		case $option in
			"Port Only") port_rule;;
			"IP Address Only") ip_rule;;
			"IP and Port") ip_port_rule;;
		        "Help") print_help
		esac
	done
}    # ----------  end of function menu_selection  ----------



function print_help () {
	printf "This script allows you to create outbound firewall rules depending on the three options shown above, those being Port Only, IP Address Only, and IP and Port\n\nPort Only - Create an ACCEPT iptables rule for the OUTBOUND chain for any destination IP address, but for a specific Port.\n\nIP Address Only - Create an ACCEPT iptables rule for the OUTBOUND chain for any destination port, but for a specific IP Address.\n\nIP and Port - Create an ACCEPT iptables rule for the OUTBOUND chain for a specific destination IP and Port\n"
}    # ----------  end of function print_help  ----------








# -------------- Input Validation/Argument Checks ---------------- #

function check_user () {
	if [[ $UID -ne 0 ]]; then
		return 1
	fi

}    # ----------  end of function check_user  ----------


function check_args () {	
	if [[ ${#@} -ne 0 ]]; then
		return 1
	fi

}    # ----------  end of function check_args  ----------


function check_port () {
	read -p "Please enter a Destination Port: " port
	until (( "$port" >= 0 )) && (( "$port" <= 65535 )) && [[ "$port" =~ ^[0-9]+$ ]]; do
		read -p "Please enter a valid port [0-65535]: " port
	done
	
	printf "$port"
}    # ----------  end of function check_port  ----------


function check_continue () {
	while true; do
		read -p "Do you want to make another rule? [y/n]: " yn
		case "$yn" in
			y|Y|[yY]es) break;;
			n|N|[nN]o) printf "Exting program..."; exit 0;;
			*) printf "Select Y/N\n"
		esac
	done
}    # ----------  end of function check_continue  ----------


function check_ip () {
	read -p "Please enter a Destination IP and Optional Mask (/32 is assumed if not entered): " ip
	until [[ "$ip" =~ ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/([1-3][0-9]|[1-9]))? ]] && [[ "$ip" == "${BASH_REMATCH[0]}" ]]; do
		read -p "Please enter a valid IP e.g. 192.168.0.50/24: " ip
	done

	printf "$ip"
}    # ----------  end of function check_ip  ----------

main $1
