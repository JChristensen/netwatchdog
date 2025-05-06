#!/bin/bash
# Script to check for net.watch.dog sentinel file.
# If present, send email notification that a reboot occurred,
# and delete the sentinel file.
# A regular user can schedule this script with cron to run at boot.
# Requires the pymail project to be installed.
#
# J.Christensen 04May2025

# email recipient
to="christensen.jack.a@gmail.com"

# wait a bit to allow time for other cron tasks that run on reboot
sleep 120

# a persistent log file that we write to before rebooting.
logfile="/home/$(id -nu 1000)/$(basename --suffix=.sh $0).log"

# a sentinel file to signal the bootcheck.sh script to send an email
sentinel="/home/$(id -nu 1000)/net_watch_dog"

# check to see if it exists, if so, send email and delete it.
if [ -e "$sentinel" ]; then
    # get the connectivity state from Network Manager
    conn=$(nmcli networking connectivity)
    # send email only if we are connected
    if [ $conn == "full" ]; then
        subj="$(hostname) netwatchdog automated reboot"
        /usr/local/bin/pymail -t $to -s "$subj" <$sentinel
        rm $sentinel
    else
        # still no network, write a message to the log file instead
        msg="$(date "+%F %T") Unable to send email. Network connectivity: $conn"
        echo $msg >>$logfile
    fi
fi
