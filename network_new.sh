#!/bin/bash

# Technokowski 2019

# Setting enviroment variables
# BSSID is here instead of in the
# logic because it looks better
# this way

WHO=$(whoami)
BSSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -n 's/^ *BSSID: //p')
COMP=$(scutil --get LocalHostName)
CONNECTION=false
WIFI=$(networksetup -getinfo Wi-Fi)
ETHO=$(networksetup -getinfo Ethernet)

# Prints the current logged in user
echo "Hello, $WHO"
echo ":::::::::::::::::::::::::::"
echo 'This is your computer name:'
echo $COMP
echo "..........................."

# If "Subnet" is contained in the
# $WIFI var it indicates that there
# is a valid IP present.
# When device is not connected
# to an AP, subnet is blank
# and the logic isn't ran
if [[ $WIFI == *"Subnet"* ]]; then
  IP=${WIFI%Subnet*}
  IP=${IP##*:}
  MAC=${WIFI##*WiFi ID:}
  CONNECTION=true
  echo "This is your WiFi IP Address:"
  echo $IP
  echo "This is the BSSID:"
  echo $BSSID
  echo ":::::::::::::::::::::::::::"
fi

# No "Subnet", no IP...
# logic doesn't print
if [[ $ETHO == *"Subnet"* ]]; then
  echo "This is your Ethernet IP Address:"
  ETHO=${ETHO%Subnet*}
  ETHO=${ETHO##*:}
  CONNECTION=true
  echo $ETHO
fi

# If $WiFi and $ETHO return false,
# there is a chance the machine is
# using an external NIC
# This loops through all iterations
# of en0-7 and adds them to a list,
# which is printed if exists.
# If list is empty, logic isn't ran
if [[ "$CONNECTION" = false ]]; then
  LIST=()
  for VAR in 1 2 3 4 5 6 7
    do
      TEMP=$(ipconfig getifaddr en$VAR)
      LIST+=($TEMP)
    done

    for ELEM in ${LIST[@]}
    do
      echo "Your current IP is:"
      echo $ELEM
    done

  if [ $LIST ]; then
    CONNECTION=true
  fi
fi

# When no conditions are met,
# it's assumed that the network connection
# is inactive.
if [ "$CONNECTION" = false ]; then
  echo "Please check network settings:"
  echo "System Preferences > Network"
fi
