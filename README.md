# Network watchdog scripts for Raspberry Pi

## Overview
Two bash scripts to work around wifi connectivity issues with Raspberry Pi Zero W and Zero 2W.

The first script, `netwatchdog.sh` should be scheduled regularly (e.g. every 10 minutes) to run as root; it will reboot the machine if network connectivity is lost. Use `sudo crontab -e` to create a schedule.

The second script, `bootcheck.sh` should be scheduled to run as a regular user at boot. This script looks for a "sentinel" file left by `netwatchdog.sh`, and if found, will send an email to alert that a reboot occurred.

## Customization
The scripts work by testing network connectivity to a given IP address. This might be a router or a DNS server. Change the IP address in both scripts as desired.

Change the email address in the `bootcheck.sh` script as desired.

## Prerequisites
Sending the email requires installation of my "pymail" project, which cannot currently be found on GitHub ;-)

The scripts use the `traceroute` command to test network connectivity. This may need to be installed, e.g. Raspberry Pi OS does not have it installed by default.

## Note
Previously this project had two branches, one for bookworm and one for bullseye, since different commands had to be used to check network status. This is no longer necessary now that the scripts use `traceroute`.
