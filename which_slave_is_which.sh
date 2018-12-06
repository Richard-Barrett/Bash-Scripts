#!/bin/bash

### DEFINE VARS
environment=${1}
password='r00tme'

### FUNCTION TO PRINT USAGE
print_usage() {
        if [[ ! "${environment}" ]]; then
                echo -e "Usage: which_slave_is_which.sh [environment_name]"
                exit 1
        fi
}

### HELPER FUNCTION TO GET NODE NAMES AND MACS FROM FUEL
get_fuel_node_macs() {
	# local vars only for this function
        local fuel_master=$(\
		/usr/local/bin/dos.py \
		slave-ip-list ${environment} |
		grep admin |
		grep -oP '(?<=:\ admin,).+?(?=\ slave-01)' \
	)
        local node_ids=$(\
		sshpass -p ${password} \
		ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${fuel_master} \
		"fuel node | egrep -v '\-\-|status' | cut -d\| -f1" \
	)
	# run loop and provide clean output of nodes to macs
        for node_id in ${node_ids}; do
                sshpass -p ${password} \
                        ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${fuel_master} \
                        "fuel node --node-id ${node_id}| egrep -v '\-\-|status' | cut -d\| -f3,6"
        done
}

### USE get_fuel_node_macs FUNCTION AND DUMP VIRSH XML, MATCH MACS TO SLAVES, AND OUTPUT WHICH SLAVE IS WHICH NODE
determine_slave_nodes() {
	# run get_fuel_node_macs and read output into while loop
        get_fuel_node_macs | while read entry; do
                mac=$(cut -d\| -f2 <<< ${entry})
                node=$(cut -d\| -f1 <<< ${entry})
                for slave in slave-0{1..5}; do
                        if [[ `virsh dumpxml "${environment}_${slave}" | grep -o ${mac}` ]]; then
                                echo -e "${slave} = ${node}"
                                continue
                        fi
                done
        done
}

### EXECUTION AREA
# did we get an environment?
print_usage

# execute main function
determine_slave_nodes
