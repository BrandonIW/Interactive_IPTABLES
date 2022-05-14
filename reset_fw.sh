#!/bin/bash
#===============================================================================
#
#          FILE:  reset_fw.sh
# 
#         USAGE:  ./reset_fw.sh 
# 
#   DESCRIPTION:  This script simply resets all IPTABLE rules back to ACCEPT 
#                 for all chains. 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  1) Must have sudo privledges 
#		  2) Script must have r/x permissions
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Brandon Wittet (), Brandon.wittet@gmail.com
#       COMPANY:  Open Source
#       VERSION:  1.0
#       CREATED:  2022-05-13 02:53:20 PM PDT
#      REVISION:  ---
#===============================================================================

function main () {
	check_user
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		echo "You must run this program with sudo"
		exit 1
	fi

	printf "Resetting Firewall Rules...\n"; sleep 1
	iptables -F; echo
	iptables -P INPUT ACCEPT; iptables -P OUTPUT ACCEPT; iptables -P FORWARD ACCEPT
	printf "Tables reset. New tables:\n"
	iptables -L

}    # ----------  end of function main  ----------



function check_user () {
	if [[ $UID -ne 0 ]]; then
		return 1
	fi

}    # ----------  end of function check_user  ----------
main

