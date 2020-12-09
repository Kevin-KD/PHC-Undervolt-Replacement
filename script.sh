sudo sh -c "echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
sudo sh -c "echo performance >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
sudo modprobe msr
sudo wrmsr -a 0x199 0x4F1E
