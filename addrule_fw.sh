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
#          BUGS:  ---
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
	read -p "Please enter a Destination Port: " port
	until (([[ "$port" -le 65535 ]] && [[ "$port" -ge 0 ]]; do
		read -p "Please enter a valid port [0-65535]: " port
	done

		 
}    # ----------  end of function port_rule  ----------


function ip_rule () {
	echo "test"
}    # ----------  end of function ip_rule  ----------


function ip_port_rule ()
{
	pass
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




main $1


