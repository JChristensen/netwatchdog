#!/bin/bash
# Check network connectivity and reboot if not connected.
# This is for those Raspberry Pi Zero W/2W machines that
# occasionally disconnect from wifi for reasons unknown.
# This script must run as root so it can reboot if needed.
# Schedule it in root's crontab with: $ sudo crontab -e
# Traceroute is used to check connectivity to a known node
# on the network (e.g. a router or a DNS server.)
# NB: traceroute may need to be installed using the package manager,
# as it is not installed by default on all distros.
# This script writes a status message to syslog each time it runs.
# If traceroute fails, then a boot will be scheduled in one minute,
# and the status will also be written to a log file in the
# home directory of UID 1000.
#
# J.Christensen 03May2025

# the ip address to test with traceroute
ip="192.168.1.1"

# the path to the log files
logpath="/home/$(id -nu 1000)"

# the name of this script, less the .sh suffix
scriptname=$(basename --suffix=.sh $0)

# a persistent log file that we write to before rebooting.
logfile="$logpath/$scriptname.log"

# a sentinel file to signal the bootcheck.sh script to send an email
sentinel="$logpath/net_watch_dog"

# log video core info to syslog
vc="$scriptname vcinfo: $(vcgencmd measure_temp) $(vcgencmd get_throttled) $(vcgencmd measure_volts)"
logger $vc

# do the traceroute, capture the results in a variable
tr1=$(traceroute -n $ip)

# remove the first line which will always contain the target ip
tr2=$(echo "$tr1" | tail -n +2)

# get just the last line for the log message
trlast=$(echo "$tr1" | tail -1)

# make a log message and timestamp
msg="$scriptname trace: $trlast"
ts=$(date "+%F %T")

# check the traceroute results for the target ip.
# if not present, then we failed to reach it, so schedule a reboot.
regex="[[:space:]]+$ip[[:space:]]+"
if [[ $tr2 =~ $regex ]]; then
    msg="$msg (OK)"
    logger $msg
else
    # write the message to our log file, sentinel file, and to syslog
    msg="$msg (FAIL) ... Reboot in one minute."
    logger $msg
    /usr/sbin/shutdown --reboot +1
    echo "$ts $msg" >>$logfile
    echo "$ts $msg" >>$sentinel
fi
