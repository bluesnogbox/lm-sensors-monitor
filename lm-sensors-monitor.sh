#!/bin/bash

noSpamDelay=180 # Minimum wait in seconds between notifications
maxTemp=70
pushbulletAPI=
pushbulletDevice=
pushbulletPath=
#critTemp=
mmsAddr=
emailAddr=

# Example sensors -u output:
# coretemp-isa-0000
# Adapter: ISA adapter
# Core 0:
  # temp2_input: 70.000
  # temp2_crit: 125.000
  # temp2_crit_alarm: 0.000
# Core 1:
  # temp3_input: 71.000
  # temp3_crit: 125.000
  # temp3_crit_alarm: 0.000

# Get CPU temps.  sensors -u outputs raw data for easier parsing.
sensordata=$(sensors -u) # save data so we don't need to run sensors twice
cputemp0=$(echo "$sensordata" | sed -n 's/[ \t]*temp2_input:[ \t]*//p')
cputemp1=$(echo "$sensordata" | sed -n 's/[ \t]*temp3_input:[ \t]*//p')

# Touch cpu temp file to make sure it exists
touch /tmp/last_cpu_temp_notify
# Put CPU temps in an array
cpu=($cputemp0 $cputemp1)
for x in ${!cpu[@]}; do # ! means loop using the index instead of the value
    if (( $(echo "${cpu[$x]} $maxTemp" | awk '{print ($1 > $2)}') )); then
        if (( $(echo "$(date +%s) $(cat /tmp/last_cpu_temp_notify) $noSpamDelay" | awk '{print ($1 - $2 > $3)}') )); then # difference is more than noSpamDelay
            # Send Pushbullet notification
            # ${pushbulletPath}/pushbullet_cmd.py $pushbulletAPI note $pushbulletDevice "UNSAFE TEMPERATURE on Core $x: ${cpu[$x]}"
            echo "UNSAFE TEMPERATURE on Core $x: ${cpu[$x]}" # because I can't test pushbullets. you can remove this
            # Save timestamp in seconds since Jan 1, 1970 to temp file
            echo $(date +%s) > /tmp/last_cpu_temp_notify
        fi
    fi
done
