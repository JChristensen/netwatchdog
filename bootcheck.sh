#!/bin/bash
# Script to check for net_watch_dog sentinel file.
# If present, send email notification that a reboot occurred,
# and delete the sentinel file.
# A regular user can schedule this script with cron to run at boot.
# Requires the pymail project to be installed.
#
# J.Christensen 04May2025

# A function to provide similar functionality to "nmcli net conn" on a
# system in that runs wpa_supplicant and not Network Manager.
# This is to allow the netwatchdog scripts to run on a system that does
# not use Network Manager, e.g. bullseye.
# The "wpa_cli status" command returns a multi-line report. We parse out
# the value for "wpa_state" and return that. If wpa_state is not found,
# we return "unknown".
# Where the nmcli command returns "full" to indicate full Internet
# connectivity, this function will return "COMPLETE".
wpaStatus()
{
    stat=$(/usr/sbin/wpa_cli status)
    if [[ $stat =~ wpa_state=([[:alpha:]]*) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "unknown"
    fi
}

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
    # get the connectivity state from wpa_supplicant
    conn=$(wpaStatus)
    # send email only if we are connected
    if [ $conn == "COMPLETED" ]; then
        subj="$(hostname) netwatchdog automated reboot"
        /usr/local/bin/pymail -t $to -s "$subj" <$sentinel
        rm $sentinel
    else
        # still no network, write a message to the log file instead
        msg="$(date "+%F %T") Unable to send email. Network connectivity: $conn"
        echo $msg >>$logfile
    fi
fi
