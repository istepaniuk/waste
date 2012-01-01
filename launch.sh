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

#function main ()

trap control_c SIGINT
spawn_pids=""
while [ "$launch_count" -gt "0" ] ; do
	./waste.sh $script_file &
	last_pid=$!
	spawn_pids="$spawn_pids $last_pid"
	let launch_count=$launch_count-1
done

wait
exit 0
