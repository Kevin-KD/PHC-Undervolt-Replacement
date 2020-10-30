# PHC-Undervolt-Replacement

Since PHC is not getting updated and requires a kernel module, I made this simple script to control voltage and frequency of the CPU.

The script requires msr-tools package and works on Ubuntu 20.04 with mobile Core 2 Duo Penryn. Other Intel CPUs launched before Core i series should work as well.

4F1E in the example script means

4: +0.5 multiplier

F: 15 multiplier

1E: 0.7125 + 30 * 0.0125=1.0875v (on desktop it's 0.825+ VID * 0.0125)

Made with help from

unclewebb and golovkin from http://forum.notebookreview.com/threads/the-throttlestop-guide.531329/

and haarp from https://forums.gentoo.org/viewtopic-t-914154-start-25.html

TODO:
Currently the script sets a fixed voltage and frequency. Dynamic voltage and frequency control could be implemented by monitoring the register value written by the system and then modify the voltage. This way, voltage offset can be set independently for each frequency.
