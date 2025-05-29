# Network watchdog scripts for Raspberry Pi

## Overview
Two bash scripts to work around wifi connectivity issues with Raspberry Pi Zero W and Zero 2W.

The first script, `netwatchdog.sh` should be scheduled regularly (e.g. every 10 minutes) to run as root; it will reboot the machine if network connectivity is lost. Use `sudo crontab -e` to create a schedule.

The second script, `bootcheck.sh` should be scheduled to run as a regular user at boot. This script looks for a "sentinel" file left by `netwatchdog.sh` and if found, will send an email to alert that a reboot occurred.

Sending the email requires installation of my "pymail" project, which cannot currently be found on GitHub ;-)

NB: There are two branches in this repo, one for bookworm, and one for bullseye. The bookworm branch uses `nmcli` (Network Manager) to check connectivity. Since Network Manager is not used by bullseye, the bullseye branch uses `wpa_state` (WPA Supplicant) instead.
