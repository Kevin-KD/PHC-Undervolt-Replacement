#!/bin/bash
#
# PHC-Undervolt-Replacement by Kevin-KD
# v1.0.0
# Simple script to undervolt CPU
# Run with root privilege
# Check Github page for more details
# https://github.com/Kevin-KD/PHC-Undervolt-Replacement

# Load msr driver into kernel.
modprobe msr

# Get the number of CPU threads.
num_threads="$(grep -c processor /proc/cpuinfo)"

# Set to userspace governor.
for (( i = 0; i < num_threads ; i++)); do
  echo userspace >/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

prev_total=0
prev_idle=0

while true; do
  # Get the total CPU statistics, discarding the 'cpu ' prefix.
  cpu="$(sed -n 's/^cpu\s//p' /proc/stat)"
  # Just the idle CPU time.
  idle=${cpu[3]}
 
  # Calculate the total CPU time.
  total=0
  for value in "${cpu[@]:0:8}"; do
    total=$(( total + value ))
  done
 
  # Calculate the CPU usage since we last checked.
  diff_idle=$(( idle - prev_idle ))
  diff_total=$(( total - prev_total ))
  diff_usage=$((( 1000 * ( diff_total - diff_idle ) / diff_total + 5) / 10 ))
 
  # Remember the total and idle CPU times for the next check.
  prev_total="${total}"
  prev_idle="${idle}"
  
  # Modify frequency and voltage based on CPU load.
  if (( $diff_usage < 14 )); then
    # Set frequency to 0.6 GHz and voltage to 0.925V on all cores.
    wrmsr -a 0x199 0x8611
  elif (( $diff_usage < 28 )); then
	wrmsr -a 0x199 0x8811
  elif (( $diff_usage < 42 )); then
    wrmsr -a 0x199 0x0617
  elif (( $diff_usage < 56 )); then
    wrmsr -a 0x199 0x081b
  elif (( $diff_usage < 70 )); then
    wrmsr -a 0x199 0x0a1e
  elif (( $diff_usage < 84 )); then
    wrmsr -a 0x199 0x0d22
  else
    wrmsr -a 0x199 0x0e29
  fi

  # Sleep to reduce script's overhead.
  sleep 1
done
