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

# wait a bit to allow time for other cron tasks that run on reboot,
sleep 120

# the sentinel file
sentinel="/home/$(id -nu 1000)/net_watch_dog"

# check to see if it exists, if so, send email and delete it.
if [ -e "$sentinel" ]; then
    subj="$(hostname) netwatchdog automated reboot"
    /usr/local/bin/pymail -t $to -s "$subj" <$sentinel
    rm $sentinel
fi
