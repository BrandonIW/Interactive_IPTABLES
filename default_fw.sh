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

}    # ----------  end of function main  ----------


