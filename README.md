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
e in hexadecimal is 14.
1e in hexadecimal is 16 x 1 + 14 = 30 in decimal.
You can find many online tools to do the conversion.
The voltage is 0.7125 + 30 x 0.0125 = 1.0875 V on mobile CPU.
The voltage is 0.825 + 30 x 0.0125 = 1.2 V on desktop CPU.
```
For my CPU, the default voltage register values from highest to lowest are:
```
29 22 1e 1b 17 11
```
Set a static frequency and desired voltage using the following commands:
```
$ sudo sh -c "echo 2601000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"
$ sudo wrmsr -a 0x199 0x0e28
```
**STOP!**

**Make sure your have adequate cooling for your CPU and VRM before running Prime95.**

**Inadequate cooling may cause permanent CPU or VRM damage.**

**For laptops, you can open up the bottom case and use a fan to blow directly at the heatsink.**

Download Prime95 from https://www.mersenne.org/download/, extract, and run it.
```
$ wget https://www.mersenne.org/ftp_root/gimps/p95v303b6.linux64.tar.gz
$ tar -xf p95v303b6.linux64.tar.gz
$ ./mprime
```
Remember to check for latest version number and change the commands accordingly.

Choose N for Join Gimps.

Prime95 sets number of torture threads to the maximum by default so just press enter.

Choose 1 for type of torture test because smallest FFTs stresses CPU the most.

Press enter for the other questions.

For maximum stability, you should run the stress test for hours.

If you don't have time, run at least few minutes for _**minimum**_ stability.

If your computer hangs, shuts down or Prime95 finds error, increase the voltage.

When you launch Prime95 for the second time, choose Options/Torture Test.

Find the minimum voltage needed to run Prime95 for hours at a specific frequency.

Repeat the same operation on every available frequency.

Beaware that some OEMs will throttle the CPU using BIOS options or hidden options like clock modulation.

Stress testing at a throttled frequency is meaningless.

You can check realtime CPU frequency using the following command
```
$ watch -n 1 cat /proc/cpuinfo
```
The minimum stable voltage is also related to CPU temperature.

Stable at a certain voltage with external cooler or low ambient temperature in winter can be unstable without external cooler or high ambient temperature in summer. 

For my T9500, the undervolt result is this:
Frequency | 0.8 GHz (88) | 1.2 GHz (06) | 1.6 GHz (08) | 2.0 GHz (0a) | 2.6 GHz (0d) | 2.8 GHz IDA (0e)
------------ | ------------- | ------------- | ------------- | ------------- | ------------- | -------------
Default Voltage | 0.925 V (11) | 1 V (17) | 1.05 V (1b) | 1.0875 V (1e) | 1.1375 V (22) | 1.225 V (29)
Undervault | 0.925 V (11) | 0.925 V (11) | 0.925 V (11) | 0.925 V (11) | 1.1125 V (20) | 1.125 V (21)

I haven't found a way to set voltage lower than 0.925 V (11).

According to https://www.cpu-world.com/CPUs/Core_2/Intel-Core%202%20Duo%20Mobile%20T9500%20FF80576GG0646M.html, the lowest voltage from factory is 0.75 V.

CPU doesn't respond to any voltage register lower than 11.
### Step 4: modify the script
The example in script.sh has 5 thresholds and 6 frequency+voltage combinations.

If your CPU has more combinations, modify the script accordingly.

Modify the frequency and voltage in the if statements to your own value.

If your CPU has multiple frequencies that are stable at the same voltage like mine, you can simplify the if statement to use only the highest frequency at that voltage.

The power and heat is mostly related to voltage, not frequency.

The default sleep time of 0.25 second results in 1% CPU utilization on 0.8 GHz T9500.

Decrease that value can reduce transition time between frequencies but at the cost of higher overhead.
### Step 5: add script to root crontab

## TODO
Automate everything to make it easier to undervolt using script like this https://bbs.archlinux.org/viewtopic.php?pid=1141702#p1141702.

Implement overclock.

Implement dual IDA.

Implement SLFM6.

Improve load tracking algorithm using instantaneous load.

Override voltage floor.

## Credits
Made with help from

unclewebb and golovkin from http://forum.notebookreview.com/threads/the-throttlestop-guide.531329/

and haarp from https://forums.gentoo.org/viewtopic-t-914154-start-25.html
