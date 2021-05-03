#!/usr/bin/env bash

case $1 in
stop)
    procid=$(pgrep octant)
    if [ "$procid" == "" ]
    then
        echo "octant process is not running"
    else 
        kill $procid
        osascript -e 'quit app "Terminal"'
    fi
    ;;
*) #start
    octant -n dekt-apps --disable-open-browser
    ;;
esac
