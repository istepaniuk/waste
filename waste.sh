#!/bin/bash

[[ -r "$1" ]] || { echo "Usage: $0 simulation_script_file.sim"; exit 1 ; }

script_file=$1

source config

# params
sim_script_file=$1

# constants
tmp_path="/dev/shm"
wget_out="$tmp_path/$0.$$.status"
wget_response="$tmp_path/$0.$$.response"
wget_opts="-o $wget_out -O $wget_response -T $timeout -t 1 --progress=dot "
time_opts="--format %e"
timer="/usr/bin/time"
bc="/usr/bin/bc"
tp_rst=$(tput sgr0)
tp_red=$(tput setaf 1)
tp_grn=$(tput setaf 2)

# dependency checks
[[ -x "$timer" ]] || { echo "We need GNU time to be installed ($timer)"; exit 1 ; }
[[ -x "$bc" ]] || { echo "We need GNU bc to be installed ($bc)"; exit 1 ; }

# global vars
total_cumulative_waiting_time_ms=15
last_elapsed_ms=0
last_elapsed_secs=0

function update_elapsed_time {
	echo $last_elapsed_secs |grep "exited with non-zero status" > /dev/null
	if [ "$?" == "0" ] ; then
		last_elapsed_secs=$timeout
		echo WGET_ERROR $last_elapsed_secs > $wget_response
		echo $(cat $wget_out)
	fi
	elapsed_ms=$(echo "$last_elapsed_secs * 1000"| $bc)
	rounded_elapsed_ms=$(printf %0.f $elapsed_ms)
	last_elapsed_ms=$rounded_elapsed_ms
	let total_cumulative_waiting_time_ms=$total_cumulative_waiting_time_ms+$rounded_elapsed_ms 
}

function do_get {
	# params
	url=$(echo $1|sed s/\"//g)

	rm -f $wget_response
	last_elapsed_secs=$($timer $time_opts wget $wget_opts "$base_url$url"  2>&1)
	update_elapsed_time
	command_result=$last_elapsed_ms
}

function do_post {
	# params
	url=$(echo $1|sed s/\"//g)
	post_data=$(echo $2|sed  s/\"//g)

	rm -f $wget_response
	last_elapsed_secs=$($timer $time_opts wget $wget_opts "$base_url$url" --post-data="$post_data" 2>&1)
	update_elapsed_time
	command_result=$last_elapsed_ms
}

function run_expect {
	# params
	command=$1
	arguments=$2
	
	echo "$(cat $wget_response)" | ./matchers/$command $arguments
	if [ "$?" == "0" ] ; then
		command_result="${tp_grn}PASSED${tp_rst}"
	else
		command_result="${tp_red}FAILED${tp_rst}"
	fi
}

function execute_line {
	# params
	line_number=$1
	command=$2
	argument1=$3
	argument2=$4

	# is it a comment?
	if [ "${command:0:1}" == "#" ] ; then
		return 0
	fi
		
	case $command in
		WAIT)
			sleep $argument1
			return 0
		;;
		GET)
			do_get $argument1 $argument2
		;;
		POST)

			do_post $argument1 $argument2
		;;
		EXPECT)
			run_expect $argument1 $argument2
		;;
		*)
			return 1
		;;		
	esac
	
	echo -e $$:$command-$line_number: $command_result
}

function excecute_every_line_in_script {
	script_file=$1
	line_number=0
	while read line; do
		execute_line $line_number $line
		let line_number=$line_number+1
	done < <(cat $script_file)
}

# function main ()
excecute_every_line_in_script "$sim_script_file"
echo $$:CUMULATIVE: $total_cumulative_waiting_time_ms
exit 0
