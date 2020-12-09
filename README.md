# PHC-Undervolt-Replacement

Since PHC is not getting updated and requires a kernel module to use, I wrote this simple script to control voltage and frequency of the CPU.

The script requires msr-tools package and works on Ubuntu 20.04 with mobile Core 2 Duo Penryn. Other Intel CPUs launched before Core i series should work as well.

Step 1: install msr-tools
sudo apt-get update
sudo apt-get install msr-tools

find available frequency
undervolt and stress test
write fid and vid into script
add script to cron with nice


4F1E in the example script means

4: +0.5 multiplier

F: 15 multiplier

1E: 0.7125 + 30 * 0.0125=1.0875v (on desktop it's 0.825+ VID * 0.0125)

Made with help from

unclewebb and golovkin from http://forum.notebookreview.com/threads/the-throttlestop-guide.531329/

and haarp from https://forums.gentoo.org/viewtopic-t-914154-start-25.html
