#!/bin/bash
#===============================================================================
#
#          FILE:  default_fw.sh
#
#         USAGE:  ./default_fw.sh
#
#   DESCRIPTION:  Script to setup default firewall rules. This includes:
#		  1) Create two new user-defined chains to ensure only NEW and ESTABLISHED rules pass through the firewall
# 		  2) Set all IPTABLE chain policies to DROP
#		  3) Top level filtering put on OUTPUT and INPUT chains to match NEW and ESTAB traffic. All else is dropped
#		  4) INBOUND traffic that is new or estab is moved to the NEW_ESTAB_IN Chain for more granular filtering
#                 5) OUTBOUND traffic that is new or estab is moved to the NEW_ESTAB_OUT Chain for more granular filtering
#		  6) REJECT incoming SYN packets to ports that are not hosting any services
#                 7) DROP all TCP packets with SYN and FIN bits set
#                 8) DROP all Telnet packets
#                 9) ACCEPT all TCP packets that belong to an existing connection on allowed ports
#                 10) ACCEPT TCP/UDP packets belonging to allowed ports (Configurable)
#                 11) ACCEPT inbound/outbound SSH
#                 12) Permit outbound HTTP/HTTPS only to bcit.ca
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
	# Ports
	declare -i SSH=22
	declare -i HTTP=80
	declare -i HTTPS=443
	declare -i DNS=53

	# Configurable Allowed Ports (User can change these to whatever they'd like) 
	declare -a ports=(555,600)

#----------------- Broad/Non-Granular Rules for INPUT/OUTPUT Chains ------------------#


	# Create two user chains that will filter only NEW and ESTABLISHED traffic
	iptables -N NEW_ESTAB_IN
	iptables -N NEW_ESTAB_OUT

	# Set policies to default. User chains will default back to their parent if no rules match, which will DROP
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP

	# DROP all tcp packets with SYN and FIN set
	iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	iptables -A OUTPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

	# Filter ALL traffic for NEW or ESTABLISHED packets only. This is a high-level filter to ensure only NEW/ESTAB packets are accepted by the filter. More granular filtering is then done within NEW_ESTAB
	iptables -A INPUT -m conntrack --ctstate NEW,ESTABLISHED -j NEW_ESTAB_IN
	iptables -A OUTPUT -m conntrack --ctstate NEW,ESTABLISHED -j NEW_ESTAB_OUT




#----------------- Granular Rules for User Chains ------------------#


	# REJECT Incoming SYN to high ports
	iptables -A NEW_ESTAB_IN -p tcp --match multiport --dports 1024:65535 --syn -j REJECT


	# REJECT all Telnet packets (Source and Destination to protect acting as telnet client or svr)
	iptables -A NEW_ESTAB_IN -p tcp --dport telnet -j DROP
	iptables -A NEW_ESTAB_IN -p tcp --sport telnet -j DROP
	iptables -A NEW_ESTAB_OUT -p tcp --sport telnet -j DROP
	iptables -A NEW_ESTAB_OUT -p tcp --dport telnet -j DROP


	# ACCEPT inbound & outbound SSH (Source & Destination to protect acting as ssh client or svr)
	iptables -A NEW_ESTAB_IN -p tcp --dport "$SSH" -j ACCEPT
	iptables -A NEW_ESTAB_IN -p tcp --sport "$SSH" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p tcp --dport "$SSH" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p tcp --sport "$SSH" -j ACCEPT


	# ACCEPT DNS Packets
	iptables -A NEW_ESTAB_OUT -p udp --dport "$DNS" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p tcp --dport "$DNS" -j ACCEPT
	iptables -A NEW_ESTAB_IN -p udp --sport "$DNS" -j ACCEPT
	iptables -A NEW_ESTAB_IN -p tcp --sport "$DNS" -j ACCEPT


	# Accept all tcp/udp packets for allowed ports
	iptables -A NEW_ESTAB_IN -p udp --match multiport --sports "${ports[@]}" -j ACCEPT
	iptables -A NEW_ESTAB_IN -p tcp --match multiport --sports "${ports[@]}" -j ACCEPT
	iptables -A NEW_ESTAB_IN -p udp --match multiport --dports "${ports[@]}" -j ACCEPT	
	iptables -A NEW_ESTAB_IN -p tcp --match multiport --dports "${ports[@]}" -j ACCEPT	
	iptables -A NEW_ESTAB_OUT -p tcp --match multiport --sports "${ports[@]}" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p udp --match multiport --sports "${ports[@]}" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p tcp --match multiport --dports "${ports[@]}" -j ACCEPT
	iptables -A NEW_ESTAB_OUT -p udp --match multiport --dports "${ports[@]}" -j ACCEPT


	# RESTRICT HTTP/HTTPS purely to bcit.ca
	iptables -I NEW_ESTAB_OUT -p tcp --match multiport --dports "$HTTP","$HTTPS" -d bcit.ca,142.232.230.11 -j ACCEPT
	iptables -I NEW_ESTAB_IN -p tcp --match multiport --sports "$HTTP","$HTTPS" -s bcit.ca,142.232.230.11 -j ACCEPT		
		
	



}    # ----------  end of function set_default  ----------

function check_user () {
	if [[ $UID -ne 0 ]]; then
		return 1
	fi

}    # ----------  end of function check_user  ----------

main
