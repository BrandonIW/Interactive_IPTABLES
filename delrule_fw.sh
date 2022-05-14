#!/bin/bash
#===============================================================================
#
#          FILE:  delrule_fw.sh
# 
#         USAGE:  ./delrule_fw.sh 
# 
#   DESCRIPTION:  This script allows you to interactively select an IPTABLE rule
#                 to remove. No options are required for this script, simply run
#                 it with sudo
#       OPTIONS:  ---
#  REQUIREMENTS:  1) Must be run as sudo
#                 2) Ensure script has r/x permissions
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Brandon Wittet (), Brandon.wittet@gmail.com
#       COMPANY:  Open Source
#       VERSION:  1.0
#       CREATED:  2022-05-13 04:02:01 PM PDT
#      REVISION:  ---
#===============================================================================

function main () {
	check_args $1
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		printf "Do not specify any options for this script\n"
		exit 1
	fi

	check_user
	return_val=$?
	if [[ "$return_val" -eq 1 ]]; then
		printf "You must run this program with sudo\n"
		exit 1
	fi

	menu_selection

}    # ----------  end of function main  ----------







# ---------------------- Firewall Rules and Functions ----------------------#

function delete_rule () {
	printf "Select the chain you want to delete a rule from: \n"
	select option in "INPUT" "OUTPUT" "FORWARD" "Exit"; do
		case $option in
			"INPUT") input_chain_delete;;
			"FORWARD") forward_chain_delete;;
			"OUTPUT") output_chain_delete;;
			"Exit") printf "Exiting program..."; exit 0 
		esac
	done	

}    # ----------  end of function delete_rule  ----------


function forward_chain_delete () {
	check_if_rules "FORWARD"
	return_val=$?
	
	if [[ "$return_val" -eq 1 ]]; then
		printf "There are no iptable rules in this chain. Select another chain, or exit program\n"
		return 0
	fi
	
	                                                                                                             
        IFS=$'\n'                                                                                                    
        rules=($(iptables -L FORWARD --line-numbers | awk '/^[0-9]/'))                                                 	     num_rules="${#rules[@]}"                                                                                    
                                                                                                                     
                                                                                                                     
        printf "Select the number associated with the rule you want to delete: \n"                                  
        iptables -L FORWARD --line-numbers | awk '/^num/'                                                                                                                                                        
                                                                                                                     
        select option in "${rules[@]}"; do                                                                           
                num_select=$(echo $option | cut -d ' ' -f 1)                                                         
                if [[ "${num_select:=0}" -ge 1 && "${num_select:=0}" -le "$num_rules" ]]; then                       
                        iptables -D FORWARD "$num_select"                                                              
                        printf "Rule deleted. New FORWARD Chain:\n"                                                                          iptables -L FORWARD 
			rules=($(iptables -L FORWARD --line-numbers | awk '/^[0-9]/'))                                                       num_rules="${#rules[@]}"                                                                     
                                                                                                                     
                        check_continue                                                                               
                        return                                                                                       
                else                                                                                                 
                        printf "Invalid rule selected. Try again\n"                                                  
                fi                                                                                                   
        done                                                                     
}    # ----------  end of function forward_chain_delete  ----------



function input_chain_delete () {
	check_if_rules "INPUT"
	return_val=$?
	
	if [[ "$return_val" -eq 1 ]]; then
		printf "There are no iptable rules in this chain. Select another chain, or exit program\n"
		return 0
	fi


	IFS=$'\n'
	rules=($(iptables -L INPUT --line-numbers | awk '/^[0-9]/'))
	num_rules="${#rules[@]}"


	printf "Select the number associated with the rule you want to delete: \n"	
        iptables -L INPUT --line-numbers | awk '/^num/'
	
	
	select option in "${rules[@]}"; do
		num_select=$(echo $option | cut -d ' ' -f 1)
		if [[ "${num_select:=0}" -ge 1 && "${num_select:=0}" -le "$num_rules" ]]; then
			iptables -D INPUT "$num_select"
			printf "Rule deleted. New INPUT Chain:\n"
			iptables -L INPUT

			rules=($(iptables -L INPUT --line-numbers | awk '/^[0-9]/'))                                                 	     num_rules="${#rules[@]}"
			
			check_continue 
			return 
		else
			printf "Invalid rule selected. Try again\n"
		fi 
	done

}    # ----------  end of function input_chain_delete  ----------



function output_chain_delete () {
	check_if_rules "OUTPUT"
	return_val=$?

	if [[ "$return_val" -eq 1 ]]; then
		printf "There are no iptable rules in this chain. Select another chain, or exit program\n"
		return 0
	fi
	
	
        IFS=$'\n'                                                                                                    
        rules=($(iptables -L OUTPUT --line-numbers | awk '/^[0-9]/'))                                                        num_rules="${#rules[@]}"                                                                                                                                                                                                  
        printf "Select the number associated with the rule you want to delete: \n"                                   
        iptables -L OUTPUT --line-numbers | awk '/^num/'                                                             
                                                                                                                     
        select option in "${rules[@]}"; do                                                                           
                num_select=$(echo $option | cut -d ' ' -f 1)                                                         
                if [[ "${num_select:=0}" -ge 1 && "${num_select:=0}" -le "$num_rules" ]]; then                       
                        iptables -D OUTPUT "$num_select"                                                             
                        printf "Rule deleted. New OUTPUT Chain:\n"
			iptables -L OUTPUT                                                                            
                        rules=($(iptables -L OUTPUT --line-numbers | awk '/^[0-9]/'))                                                        num_rules="${#rules[@]}"                                                                                           
                        check_continue                                                                               
                        return                                                                                       
                else                                                                                                 
                        printf "Invalid rule selected. Try again\n"                                                  
                fi                                                                                                   
        done                                                                     	

}    # ----------  end of function input_chain_delete  ----------







# ---------------------- Menus and Help Options ---------------------#

function menu_selection () {
	select option in "Delete a Firewall Rule" "Help"; do
		case $option in
			"Delete a Firewall Rule") delete_rule;;
			"Help") print_help
		esac
	done

}    # ----------  end of function menu_selection  ----------
		

function print_help () {
	printf "This script allows you to interactively choose the firewall rule you wish to delete by selecting the line number that the firewall rule is associated with.\nSelect the Delete a Firewall Rule option, and you will be shown the line numbers associated with each firewall rule. Select the line number associated with the rule you wish to delete and hit Enter\n"

}    # ----------  end of function print_help  ----------







# ---------------------- Input Validation/Argument Checks -----------------# 

function check_continue () {
	while true; do
		read -p "Do you want to delete another rule? [y/n]: " yn
		case "$yn" in
			y|Y|[yY]es) break;;
			n|N|[nN]o) printf "Exiting program..."; exit 0;;
			*) printf "Select Y/N\n"
		esac
	done

}    # ----------  end of function check_continue  ----------


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


function check_if_rules () {
	if [[ -z $(sudo iptables -L "$1" --line-numbers | awk '/^[0-9]/') ]]; then
		return 1
	fi

}    # ----------  end of function check_if_rules  ----------

main $1
