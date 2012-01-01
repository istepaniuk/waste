#!/bin/bash

# params
script_file=$1
launch_count=$2


function cleanup {
	kill -9 $spawn_pids
	wait
}
 
function control_c {
	echo -en "\n*** Interrupted ***\n"
	cleanup
	exit 1
}

function precache_dns {
	ping 192.168.10.22 -c1 -w 1
	ping "$target_hostname"
	return 0
}

#function main ()

trap control_c SIGINT
precache_dns
spawn_pids=""
while [ "$launch_count" -gt "0" ] ; do
	echo -n "Launching PID: "
	./execute_sim_script.sh $script_file &
	last_pid=$!
	echo $last_pid
	spawn_pids="$spawn_pids $last_pid"
	let launch_count=$launch_count-1
done

wait
exit 0
