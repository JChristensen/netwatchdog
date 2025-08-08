#!/bin/bash
# Script to check for net_watch_dog sentinel file.
# If present, send email notification that a reboot occurred,
# and delete the sentinel file.
# A regular user can schedule this script with cron to run at boot.
# Requires the pymail project to be installed.
#
# J.Christensen 04May2025

# a function to check whether we have network connectivity, using traceroute.
# $1 is the ip to check.
# returns either "OK" or "FAIL".
netStatus()
{
    # do the traceroute, capture the results in a variable
    tr1=$(traceroute -n $1)
    # remove the first line which will always contain the target ip
    tr2=$(echo "$tr1" | tail -n +2)
    # check the traceroute results for the target ip.
    # if not present, then we failed to reach it.
    regex="[[:space:]]+$ip[[:space:]]+"
    if [[ $tr2 =~ $regex ]]; then
        echo "OK"
    else
        echo "FAIL"
    fi
}

#---- MAIN SCRIPT ----#

# email recipient
to="christensen.jack.a@gmail.com"

# the ip address to test with traceroute
ip="192.168.1.1"

# the path to the log files
logpath="/home/$(id -nu 1000)"

# the name of this script, less the .sh suffix
scriptname=$(basename --suffix=.sh $0)

# wait a bit to allow time for other cron tasks that run on reboot
sleep 120

# a persistent log file that we write to before rebooting.
logfile="$logpath/$scriptname.log"

# the sentinel file that signals this script to send an email
sentinel="$logpath/net_watch_dog"

# check to see if it exists, if so, send email and delete it.
if [ -e "$sentinel" ]; then
    # get network status
    conn=$(netStatus "$ip")
    # send email only if we are connected
    if [ $conn == "OK" ]; then
        subj="$(hostname) netwatchdog automated reboot"
        /usr/local/bin/pymail -t $to -s "$subj" <$sentinel
        rm $sentinel
    else
        # still no network, write a message to the log file instead
        msg="$(date "+%F %T") Unable to send email, no network connectivity."
        echo $msg >>$logfile
        # remove the sentinel file anyway, lest it cause confusion with a future boot
        rm $sentinel
    fi
fi
