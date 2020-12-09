# PHC-Undervolt-Replacement
Since PHC is not getting updated and requires a kernel module to use, I wrote this simple script to control voltage and frequency of the CPU.

The script requires msr-tools package and works on Ubuntu 20.04 with mobile Core 2 Duo Penryn. Other Intel CPUs launched before Core i series should work as well.
	
## Setup

### Step 1: install msr-tools
```
$ sudo apt-get update
$ sudo apt-get install msr-tools
```

### Step 2: find available frequencies
```
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
```
This command will show a list of the available frequencies.

The first one with xxx1000 is the turbo boost frequency.

My Core 2 Duo T9500 gives the following result.
```
2601000 2600000 2000000 1600000 1200000 800000
```
2601000 is the single core Intel Dynamic Acceleration which boosts extra 0.2 GHz when only one core is used.

2.6+0.2 = 2.8 GHz

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
For my CPU, the frequency register values from highest to lowest are:
```
0e 0d 0a 08 06
```
The lowest multiplier may not follow the formula.

We can set the frequency to a static value and find out the register value.

For example, the following commands set frequency scaling governor to userspace and set frequency to 0.8 GHz for a dual core CPU with two threads. 
```
$ sudo sh -c "echo userspace >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
$ sudo sh -c "echo userspace >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
$ sudo sh -c "echo 800000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"
```
We can then find out the register value for 0.8 GHz using the following command.
```
$ sudo rdmsr -0 -a 0x198 | cut -b 13-14
```
For my CPU, the register value for 0.8 GHz is 88.

### Step 3: undervolt and stress test

In order to find the default voltage, use the same method as step 2 to set cpu frequency.
Use the following command to find out the register value for the voltage.
```
$ sudo rdmsr -0 -a 0x198 | cut -b 15-16
```
You can convert these hexadecimal register value into voltage using this formula: 
```
Suppose the value is 1e.
1e in hexadecimal is 16 x 1 + 14 = 30 in decimal.
You can find many online tools to do the conversion.
The voltage is 0.7125 + 30 x 0.0125 = 1.0875v on mobile CPU.
The voltage is 0.825 + 30 x 0.0125 = 1.2v on desktop CPU.
```
For my CPU, the voltage register values from highest to lowest are:
```
29 22 1e 1b 17 11
```

### Step 4: modify the script

### Step 5: add script to root crontab

## TODO
Automate everything to make it easier to undervolt using script like this https://bbs.archlinux.org/viewtopic.php?pid=1141702#p1141702.

Implement overclock.

Implement dual IDA.

Improve load tracking algorithm.

## Credits
Made with help from

unclewebb and golovkin from http://forum.notebookreview.com/threads/the-throttlestop-guide.531329/

and haarp from https://forums.gentoo.org/viewtopic-t-914154-start-25.html

and Doug Smythies from https://askubuntu.com/questions/587978/can-i-upper-limit-the-cpu-frequency
