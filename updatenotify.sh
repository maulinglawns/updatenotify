#!/bin/bash
#
# DESCRIPTION:
# A script to replace the 'update-notifier' on a system
# running Debian Wheezy and Xfce.
# See this bug: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=710565
#
# This is of course best run via a cronjob, but can be used as-is too.

# EXIT CODES:
# 0 - Success
# 100 - Error: No Internet connection
# 200 - Error: Not root

# VARIABLES:
USER=magnus
INTERNET=$(ping -t 1 google.com 2> /dev/null | head -1 | \
awk '{ print $1 }')
UPDATES_AVAILABLE=0

#######################################################################

# Check if we have connection to the Internet, otherwise exit
if [ "$INTERNET" != "PING" ]; then
  exit 100
fi

# Must be root. Check if that is the case
if [ $UID != 0 ]; then
  echo "You need to be root to run this program."
  exit 200
fi

# First, update with apt and send STDOUT to /dev/null
apt-get update > /dev/null

UPDATES_AVAILABLE=$(apt-get upgrade -s --assume-no | tail -1 | \
grep -o [1-9] | wc -c)

# debugging stuff below
# UPDATES_AVAILABLE=2
# end debugging

# Big gotcha: root (cron) cannot send messages via xmessage to another 
# user's desktop. Therefore we have to change user and call another
# script that does the actual 'notifying' (see bottom of page).
if [ $UPDATES_AVAILABLE -gt 0 ]; then
  DISPLAY=:0.0 su $USER -c /home/$USER/displayupdates.sh &
fi

exit 0

#######################################################################

# The code for notifying on updates:

##!/bin/bash
#
# echo -e "\n There are updates available for your system \n" | \
#  /usr/bin/X11/xmessage -center -timeout 120 -file -

#######################################################################
