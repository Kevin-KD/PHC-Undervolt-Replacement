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

# Set to userspace governor
for i in $_cpu_list
do
	echo userspace >/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

# Infinite loop to modify frequency and voltage
while true
do
	# Find CPU load average
	_load_avg=$(cat /proc/loadavg)
	_load_avg_array=($_load_avg)
	_load_avg_1=${_load_avg[0]}
	
	# Modify frequency and voltage based on CPU load
	if [ "`echo "${_load_avg_1} < 0.2" | bc`" -eq 1 ]
	then
		# Set frequency to 0.8 GHz on all cores
		echo 800000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x8811
	elif [ "`echo "${_load_avg_1} < 0.4" | bc`" -eq 1 ]
	then
		echo 1200000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0617
	elif [ "`echo "${_load_avg_1} < 0.6" | bc`" -eq 1 ]
	then
		echo 1600000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x081b
	elif [ "`echo "${_load_avg_1} < 0.8" | bc`" -eq 1 ]
	then
		echo 2000000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0a1e
	elif [ "`echo "${_load_avg_1} < 1.0" | bc`" -eq 1 ]
	then
		echo 2600000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0d22
	else
		echo 2601000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
		wrmsr -a 0x199 0x0e29
	fi
done
