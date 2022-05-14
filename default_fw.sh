#!/bin/bash
#===============================================================================
#
#          FILE:  default_fw.sh
# 
#         USAGE:  ./default_fw.sh 
# 
#   DESCRIPTION:  Script to setup default firewall rules. This includes:
# 		  1) Set all IPTABLE chain policies to DROP 
#		  2) REJECT incoming SYN packets to ports that are not hosting any services
#                 3) DROP all TCP packets with SYN and FIN bits set
#                 4) DROP all Telnet packets
#                 5) ACCEPT all TCP packets that belong to an existing connection on allowed ports
#                 6) ACCEPT TCP/UDP packets belonging to allowed ports (Configurable) 
#                 7) ACCEPT inbound/outbound SSH 
#                 8) Permit outbound HTTP/HTTPS
#                 9) Only new and established traffic can pass through the firewall
#                 10)  
#
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Brandon Wittet (), Brandon.wittet@gmail.com
#       COMPANY:  Open Source
#       VERSION:  1.0
#       CREATED:  2022-05-13 02:43:10 PM PDT
#      REVISION:  ---
#===============================================================================


function main () {
	check_user
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		printf "You must run this program with sudo\n"
		exit 1
	fi
	printf "Setting default rules...\n"; sleep 1
	set_default
	printf "Default rules set\n\n"
	iptables -L
}    # ----------  end of function main  ----------



function set_default () {
	# Allowed ports
	declare -i SSH=22
	declare -i HTTP=80
	declare -i HTTPS=443
	declare -i DNS=53
	
	# Set policies to default
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP

	# REJECT Incoming SYN
	iptables -A INPUT -p tcp --syn -j REJECT

	# DROP all tcp packets with SYN and FIN set
#	iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
#	iptables -A OUTPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
#	iptables -A FORWARD -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

	# REJECT all Telnet packets
#	iptables -A INPUT -p tcp --dport 23 -j REJECT
#	iptables -A OUTPUT -p tcp --sport 23 -j REJECT

	# Allow tcp traffic across existing session for allowed ports
#	iptables -I INPUT 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT
#	iptables -I OUTPUT 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT
#	iptables -I FORWARD 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT

	# Allow in/outbound tcp/udp traffic on allowed ports 
#	iptables -I INPUT 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT
#	iptables -I OUTPUT 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT
#	iptables -I FORWARD 1 -p tcp --match multiport --dports "$SSH","$HTTP","$HTTPS","$DNS" -m conntrack --ctstate ESTABLISHED -j ACCEPT

	




}    # ----------  end of function set_default  ----------

function check_user () {
	if [[ $UID -ne 0 ]]; then
		return 1
	fi

}    # ----------  end of function check_user  ----------

main
