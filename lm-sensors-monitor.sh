#!/bin/bash

# My main concern is how I should daemonize this--I have considered running it as a cron job. I have also thought about using systemd. I'd appreciate any feedback you might have

maxTemp=85
#critTemp=
mmsAddr=8149773797@att.mms.net
emailAddr=taylor.growden@gmail.com

## ultimately, I would like to use a "for" loop for cpu cores; unfortunately, I am having trouble with the syntax to do that

# list temp for CPU0
string0=`sensors |grep CPU0`
arr0=($string0)

cpu0=`echo ${arr0[2]} | sed "s/+//"`
cpu0=`echo ${cpu0} | sed "s/°//"`
cpu0=`echo ${cpu0} | sed "s/C//"`

# list temp for CPU1
string1=`sensors |grep CPU1`
arr1=($string1)

cpu1=`echo ${arr1[2]} | sed "s/+//"`
cpu1=`echo ${cpu1} | sed "s/°//"`
cpu1=`echo ${cpu1} | sed "s/C//"`

# test if temps are too high
# Like I said above, this should be a "for" loop (e.g. "for x in $cpuX"), but I'm having trouble with the syntax

if (( $(echo "$cpu0 $maxTemp" | awk '{print ($1 > $2)}') )); then
# send MMS to my phone via email
  echo "CPU0: ${cpu0}C   CPU1: ${cpu1}C" | mail -s "UNSAFE TEMPERATURE!" ${mmsAddr}, ${emailAddr}
## Send Pushbullet notification
  /home/taylor/bin/pyPushBullet/pushbullet_cmd.py P81dRv12Jp7cdza1zCbxyDidnyOl7YSV note ufenwEfsjAiVsKnSTs "Unsafe Temperature!" "CPU0: ${cpu0}C   CPU1: ${cpu1}C"
fi

