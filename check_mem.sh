#!/bin/bash
#
# evaluate free system memory from Linux based systems
#
# Date: 2007-11-12
# Author: Thomas Borger - ESG
#
# Percent Version - MAB - mab@mab.net
#
#
#
# the memory check is done with following command line:
# free -m | grep buffers/cache | awk '{ print $4 }'

# get arguments

while getopts 'w:c:hp' OPT; do
  case $OPT in
    w)  int_warn=$OPTARG;;
    c)  int_crit=$OPTARG;;
    h)  hlp="yes";;
    p)  perform="yes";;
    *)  unknown="yes";;
  esac
done

# usage
HELP="
    usage: $0 [ -w value -c value -p -h ]

    syntax:

            -w --> Warning % value
            -c --> Critical % value
            -p --> print out performance data
            -h --> print this help screen
"

if [ "$hlp" = "yes" -o $# -lt 1 ]; then
  echo "$HELP"
  exit 0
fi

# get free memory
TMEM=`free -m | grep Mem | awk '{ print $2 }'`
FMEM=`free -m | grep buffers/cache | awk '{ print $4 }'`
FMEMpc=$(($FMEM * 100 / $TMEM))

# output with or without performance data
if [ "$perform" = "yes" ]; then
  OUTPUTP="free system memory: ${FMEM}MB (${FMEMpc}%) | 'free_memory'=${FMEM}M;;;0,${TMEM} 'percent_free'=${FMEMpc}%;$int_warn;$int_crit;;"
else
  OUTPUT="free system memory: ${FMEM}MB (${FMEMpc}%)"
fi

if [ -n "$int_warn" -a -n "$int_crit" ]; then

  err=0

  if (( $FMEMpc <= $int_warn )); then
    err=1
  elif (( $FMEMpc <= $int_crit )); then
    err=2
  fi

  if (( $err == 0 )); then

    if [ "$perform" = "yes" ]; then
      echo -n "OK - $OUTPUTP"
      exit "$err"
    else
      echo -n "OK - $OUTPUT"
      exit "$err"
    fi

  elif (( $err == 1 )); then
    if [ "$perform" = "yes" ]; then
      echo -n "WARNING - $OUTPUTP"
      exit "$err"
    else
      echo -n "WARNING - $OUTOUT"
      exit "$err"
    fi

  elif (( $err == 2 )); then

    if [ "$perform" = "yes" ]; then
      echo -n "CRITICAL - $OUTPUTP"
      exit "$err"
    else
      echo -n "CRITICAL - $OUTPUT"
      exit "$err"
    fi

  fi

else

  echo -n "no output from plugin"
  exit 3

fi
exit
