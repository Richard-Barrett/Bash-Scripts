#!/bin/bash

# ===========================================
# Flush .bash_aliases and put default content
# ===========================================

echo "alias suplab2='sshpass -p 'M1rantis!' ssh sto@172.19.17.7'" > /home/sto/.bash_aliases

# =======================
# Define Script Variables
# =======================

environments=$(/usr/local/bin/dos.py list | egrep -v 'NAME|\-\-')
ssh_password='<insert_passwd>'

# ================================
# DYNAMICALLY GENERATE LAB ALIASES
# ================================

for lab_env in ${environments}; do
	if [[ $(grep -i "mcp" <<< ${lab_env}) ]]; then
		cfg_admin_ip=$(/usr/local/bin/dos.py slave-ip-list ${lab_env} | grep admin | grep -oP '(?<=local,).+?(?=\ ctl01)')
		echo -e "alias ${lab_env}='sshpass -p ${ssh_password} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${cfg_admin_ip}'" >> /home/sto/.bash_aliases
	else
	        fuel_admin_ip=$(/usr/local/bin/dos.py slave-ip-list ${lab_env} | grep admin | grep -oP '(?<=:\ admin,).+?(?=\ slave-01)')
        	echo -e "alias ${lab_env}='sshpass -p ${ssh_password} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${fuel_admin_ip}'" >> /home/sto/.bash_aliases
	fi
done
