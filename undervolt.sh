#!/bin/bash
#
# PHC-Undervolt-Replacement by Kevin-KD
# v1.0.0
# Simple script to undervolt CPU
# Run with root privilege
# Check Github page for more details
# https://github.com/Kevin-KD/PHC-Undervolt-Replacement

# Load msr driver into kernel
modprobe msr

# Get the number of CPU threads
num_threads=$(grep -c processor /proc/cpuinfo)

# Set to userspace governor
for ((i = 0; i < num_threads ;i++)); do
  echo userspace >/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

PREV_TOTAL=0
PREV_IDLE=0

# Infinite loop to modify frequency and voltage
while true; do
  # Get the total CPU statistics, discarding the 'cpu ' prefix.
  CPU=($(sed -n 's/^cpu\s//p' /proc/stat))
  IDLE=${CPU[3]} # Just the idle CPU time.
 
  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]:0:8}"; do
    TOTAL=$((TOTAL+VALUE))
  done
 
  # Calculate the CPU usage since we last checked.
  DIFF_IDLE=$((IDLE-PREV_IDLE))
  DIFF_TOTAL=$((TOTAL-PREV_TOTAL))
  DIFF_USAGE=$(((1000*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL+5)/10))
 
  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
  
  # Modify frequency and voltage based on CPU load
  if [ "`echo "${DIFF_USAGE} < 16" | bc`" -eq 1 ]; then
    # Set frequency to 0.8 GHz on all cores
    wrmsr -a 0x199 0x8811
  elif [ "`echo "${DIFF_USAGE} < 32" | bc`" -eq 1 ]; then
    wrmsr -a 0x199 0x0617
  elif [ "`echo "${DIFF_USAGE} < 48" | bc`" -eq 1 ]; then
    wrmsr -a 0x199 0x081b
  elif [ "`echo "${DIFF_USAGE} < 64" | bc`" -eq 1 ]; then
    wrmsr -a 0x199 0x0a1e
  elif [ "`echo "${DIFF_USAGE} < 80" | bc`" -eq 1 ]; then
    wrmsr -a 0x199 0x0d22
  else
    wrmsr -a 0x199 0x0e29
  fi

# Sleep to reduce script's overhead
sleep 1
done
