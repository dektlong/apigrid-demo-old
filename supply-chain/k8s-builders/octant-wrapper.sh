#!/usr/bin/env bash

case $1 in
start)
    octant -n dekt-apps --disable-open-browser
    ;;
stop)
    procid=$(pgrep octant)
    if [ "$procid" == "" ]
    then
        echo "octant process is not running"
    else 
        kill $procid
    fi
    ;;
*)
    echo "please specify 'start' or 'stop'"
    ;;
esac
