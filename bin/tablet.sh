#!/bin/bash

#check if monitor number was given
if test -z "$1" 
then
  #no monitor number was given, use the main display
  MON_NO=0
else
  MON_NO=$1
fi


#get connection of monitor with number $MON_NO
MON_CON=$(xrandr --listactivemonitors | grep "$MON_NO:" | tr -s " " | cut -d " " -f 5)

#check if monitors id could be found
if test -z "$MON_CON"
then
  #no monitor with given number found!
  echo "no monitor with number $MON_NO was found!"
  MON_COUNT=$(xrandr --listactivemonitors | grep "Monitors:" | cut -d " " -f 2)
  echo "(A total of $MON_COUNT monitors were found.)"
  exit -1
fi

#for each id of wacom devices set correct output monitor
TABLET_XINPUT_NAME="UGTABLET 6 inch PenTablet"
PEN_XINPUT_NAME="UGTABLET 6 inch PenTablet Pen"

echo Waiting to detect pen

while [[ -z "$TABLET_ID" ]]; do
    if !( xinput | grep -q "$TABLET_XINPUT_NAME"); then
      echo Tablet not found. Exiting...
      exit -1
    fi

    PEN_XINPUT_LINE="$( xinput | grep "$PEN_XINPUT_NAME" | tail -1)"
    TABLET_ID="$(echo "$PEN_XINPUT_LINE" | sed 's/.*id=\([0-9]*\).*/\1/')"
    sleep 1
done

xinput map-to-output $TABLET_ID $MON_CON
