## PHC-Undervolt-Replacement
Since PHC is not getting updated and requires a kernel module to use, I wrote this simple script to control voltage and frequency of the CPU.

The script requires msr-tools package and works on Ubuntu 20.04 with mobile Core 2 Duo Penryn. Other Intel CPUs launched before Core i series should work as well.
	
## Setup

Step 1: install msr-tools
```
$ sudo apt-get update
$ sudo apt-get install msr-tools
```

Step 2: find available frequencies
```
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
```
This command will show a list of the available frequencies.
The first one with xxx1000 is the turbo boost frequency.
Convert these frequencies into hexadecimal register value using this formula: 
```
First digit:
4: +0.5 to multiplier
0: +0 to multiplier

Second digit:
0: 0 multiplier
...
9: 9 multiplier
a: 10 multiplier
...
f: 15 multiplier
```
The lowest multiplier may not follow the formula.


## TODO
Automate everything to make it easier to use
Implement overclock

## Credits
Made with help from

unclewebb and golovkin from http://forum.notebookreview.com/threads/the-throttlestop-guide.531329/

and haarp from https://forums.gentoo.org/viewtopic-t-914154-start-25.html



undervolt and stress test

write fid and vid into script

add script to cron with nice

#https://askubuntu.com/questions/587978/can-i-upper-limit-the-cpu-frequency
#https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project

4F1E in the example script means



1E: 0.7125 + 30 * 0.0125=1.0875v (on desktop it's 0.825+ VID * 0.0125)
