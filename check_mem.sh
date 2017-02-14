#!/bin/bash

#The following plugin displays the percentage system memory available (from /proc/meminfo)

usage() { echo "Usage: $0 -c Critical -w Warning. (Warning>Critical)" 1>&2; exit 1; }

while getopts ":c:w:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${c}" ] || [ -z "${w}" ] || [ "$w" -gt "$c" ] ; then
    usage
fi


memtotal=$(cat /proc/meminfo | grep MemTotal|awk '{print $2}')
memavailable=$(cat /proc/meminfo | grep MemAvailable|awk '{print $2}')

if [ "$memtotal" -eq "0" ] ; then
   echo "Total Memory-0 !!!"
   exit 3
fi

percentage=$(awk "BEGIN {printf \"%.2f\",${memavailable}*100/${memtotal}}")
memused=$(echo "100 - $percentage" | bc)
echo "Memory Used- $memused % | mem_used=$memused%;$w;$c;0;100"

if [ $(echo "$memused > $c" | bc) -ne 0 ] ; then
   echo "Critical threshold- $c %"
   exit 2

elif [ $(echo "$memused > $w" | bc) -ne 0 ] ; then
   echo "Warning threshold- $w %"
   exit 1
fi

