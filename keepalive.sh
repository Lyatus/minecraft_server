#!/bin/bash

pid=`pgrep -f server.jar`

if [ "$1" == "restart" ] && test -n "$pid" ; then
	echo "Killing old server process"
	kill $pid
	if [ "$1" == "restart" ] ; then
		exit 0
	fi
fi

if test -n "$pid" ; then
	echo "Server already running"
else
	echo "Starting new server process"
	java -Xms1024M -Xmx1024M -jar server.jar nogui >> /dev/null&
fi
