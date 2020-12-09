#!/bin/bash
# PHC-Undervolt-Replacement by Kevin-KD
# Simple script to undervolt CPU
# Run with root privilege and nice
# Check Github page for more details
# https://github.com/Kevin-KD/PHC-Undervolt-Replacement

# Load msr driver into kernel
modprobe msr

# Set ondemand governor to ignore nice load
echo -n 1 > /sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load

# Get the number of CPU threads
cpulist = $(grep processor /proc/cpuinfo | awk '{print $3}')

# Infinite loop to modify voltage on the fly
while true
do
	# Modify voltage on every thread
	for i in $cpulist
	do
		# Find current frequency set by ondeamnd governor
		currentFID = $(rdmsr -0 0x198 | cut -b 13-14)
		case $currentFID in
			# If FID is 0e then set VID to 29
			0e)
				wrmsr -p$i 0x199 0x0e29
				;;
			0d)
				wrmsr -p$i 0x199 0x0d22
				;;
			0a)
				wrmsr -p$i 0x199 0x0a1e
				;;
			08)
				wrmsr -p$i 0x199 0x081b
				;;
			06)
				wrmsr -p$i 0x199 0x0617
				;;
			88)
				wrmsr -p$i 0x199 0x8811
				;;
		esac
	done
done
