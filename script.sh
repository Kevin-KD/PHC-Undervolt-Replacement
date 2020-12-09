#!/bin/bash

modprobe msr

echo -n 1 > /sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load

cpulist = $(grep processor /proc/cpuinfo | awk '{print $3}')

while true
do
	for i in $cpulist
	do
		currentFID = $(rdmsr -0 0x198 | cut -b 13-14) 
		case $currentFID in
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
