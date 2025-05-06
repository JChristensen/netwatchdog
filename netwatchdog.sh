#!/bin/bash
# Check network connectivity and reboot if not connected.
# This is for those Raspberry Pi Zero W/2W machines that
# occasionally fall off wifi for reasons unknown.
# This script must run as root so it can reboot if needed.
# Schedule it in root's crontab with: $ sudo crontab -e
# When run, this script will write network connectivity status
# to syslog. If the status is not full internet connectivity,
# then a boot will be scheduled in one minute, and the status will
# also be written to a log file in the home directory of UID 1000.
#
# J.Christensen 03May2025

# a persistent log file that we write to before rebooting.
logfile="/home/$(id -nu 1000)/$(basename --suffix=.sh $0).log"

# a sentinel file to signal the bootcheck.sh script to send an email
sentinel="/home/$(id -nu 1000)/net_watch_dog"

# get the connectivity state from Network Manager
conn=$(nmcli networking connectivity)

# make a log message
msg="$(date "+%F %T") Network connectivity: $conn"

# the possible connectivity states are: none, portal, limited, full, unknown.
# anything other than "full" is some sort of issue, so reboot.
if [ $conn != "full" ]; then
    # write the message to our log file, sentinel file, and to syslog
    msg="$msg ... Reboot in one minute."
    echo $msg >>$logfile
    echo $msg >>$sentinel
    logger $msg
    /usr/sbin/shutdown --reboot +1
else
    logger $msg
fi
