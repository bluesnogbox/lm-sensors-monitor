#!/bin/bash

# My main concern is how I should daemonize this--I have considered running it as a cron job. I have also thought about using systemd. I'd appreciate any feedback you might have

maxTemp=15
pushbulletAPI=P81dRv12Jp7cdza1zCbxyDidnyOl7YSV
pushbulletDevice=ufenwEfsjAiVsKnSTs
pushbulletPath="/home/taylor/bin/pyPushBullet"
#critTemp=
mmsAddr=8149773797@mms.att.net
emailAddr=taylor.growden@gmail.com


# testing daemonizing with a "while" loop to be called at boot
while [ true ]; do


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

if (( $(echo "$cpu0 $maxTemp" | awk '{print ($1 > $2)}') )) || (( $(echo "$cpu0 $maxTemp" | awk '{print ($1 > $2)}') ) ; then
# send MMS to my phone via email
  echo "CPU0: ${cpu0}C   CPU1: ${cpu1}C" | mail -s "UNSAFE TEMPERATURE!" ${mmsAddr},${emailAddr}
## Send Pushbullet notification
  ${pushbulletPath}/pushbullet_cmd.py $pushbulletAPI note $pushbulletDevice "Unsafe Temperature!" "CPU0: ${cpu0}C   CPU1: ${cpu1}C"
# wait 3 minutes so that user isn't bombarded with alerts
sleep 180
fi

sleep 5
done
