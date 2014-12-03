#!/bin/bash

# My main concern is how I should daemonize this--I have considered running it as a cron job. I have also thought about using systemd. I'd appreciate any feedback you might have

maxTemp=
pushbulletAPI=
pushbulletDevice=
pushbulletPath=
#critTemp=
mmsAddr=
emailAddr=


# testing daemonizing with a "while" loop to be called at boot
while [ true ]; do


## ultimately, I would like to use a "for" loop for setting cpu core variables; I would also like to make the script allow X number of cores, which would allow it to be used on any machine. Unfortunately, I am having trouble with the syntax to do that
## I also imagine that there is probably a better way to run these sed commands. I certainly welcome input here

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

# Here, I take the readings and send them to a variable, which I then split into an array. I imagine that there is probably a more elegant way to do this.
read cpu <<<$(echo $cpu0 $cpu1)
cpu=($cpu)

for x in ${cpu[@]}; do
if (( $(echo "$x $maxTemp" | awk '{print ($1 > $2)}') )); then
# Append temperature for $x to /tmp/cpu; this file, and the "notify" variable, will be cleared if a message is sent. This way, this loop allows for X number of cores
  echo "Core: ${x}C" >> /tmp/cpu
  cpuFile=`cat /tmp/cpu`
  notify="yes"
fi
done
if [[ $notify == "yes" ]]; then
  echo "$cpuFile" | mail -s "UNSAFE TEMPERATURE!" ${mmsAddr},${emailAddr}
## Send Pushbullet notification
  ${pushbulletPath}/pushbullet_cmd.py $pushbulletAPI note $pushbulletDevice "Unsafe Temperature!" "$cpuFile"
  rm /tmp/cpu
  notify=""
# wait 3 minutes if the temperature is above the "max" level so that user isn't bombarded with alerts. I may also define a "critical" level, which would then scale-back power to core x, but this would require another dependancy
sleep 180
fi

# wait 5 seconds between checking core temps
sleep 5
done
