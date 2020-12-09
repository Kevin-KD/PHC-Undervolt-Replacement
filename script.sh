#!/bin/bash
# PHC-Undervolt-Replacement by Kevin-KD
# Simple script to undervolt CPU
# Run with root privilege
# Check Github page for more details
# https://github.com/Kevin-KD/PHC-Undervolt-Replacement

# Load msr driver into kernel
modprobe msr

# Get the number of CPU threads
_cpu_list=$(grep processor /proc/cpuinfo | awk '{print $3}')
_num_threads=$(grep -c processor /proc/cpuinfo)

# Set to userspace governor
for i in $_cpu_list
do
	echo userspace >/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

# Calculate load threshold for frequency change
_threshold_1=$(bc <<< 0.2*$_num_threads)
_threshold_2=$(bc <<< 0.4*$_num_threads)
_threshold_3=$(bc <<< 0.6*$_num_threads)
_threshold_4=$(bc <<< 0.8*$_num_threads)
_threshold_5=$(bc <<< 1.0*$_num_threads)

# Infinite loop to modify frequency and voltage
while true
do
	# Find CPU load average
	_load_avg=$(cat /proc/loadavg)
	_load_avg_array=($_load_avg)
	_load_avg_1=${_load_avg_array[0]}
	
	# Modify frequency and voltage based on CPU load
	if [ "`echo "${_load_avg_1} < $_threshold_1" | bc`" -eq 1 ]
	then
		# Set frequency to 0.8 GHz on all cores
		echo 800000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x8811
	elif [ "`echo "${_load_avg_1} < $_threshold_2" | bc`" -eq 1 ]
	then
		echo 1200000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0617
	elif [ "`echo "${_load_avg_1} < $_threshold_3" | bc`" -eq 1 ]
	then
		echo 1600000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x081b
	elif [ "`echo "${_load_avg_1} < $_threshold_4" | bc`" -eq 1 ]
	then
		echo 2000000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0a1e
	elif [ "`echo "${_load_avg_1} < $_threshold_5" | bc`" -eq 1 ]
	then
		echo 2600000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0d22
	else
		echo 2601000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0e29
	fi
	
	# Sleep to reduce script's cpu load
	sleep 0.25
	
done
