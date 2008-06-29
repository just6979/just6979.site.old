#!/bin/bash

## this little proggy uses debian's start-stop-daemon
## to get the scgi server going and stopping

cmd=$1

name='scgi-server'
gid='www'
uid='www'
dir='/home/www/main/'
exe='/home/www/main/scgi-server.py'
pid='scgi-server.pid'
log='scgi-server.log'

if [[ $cmd = 'start' ]]
then
	start-stop-daemon -v -g $gid -c $uid -d $dir -mp $pid -Sba $exe
else
	if [[ $cmd = 'stop' ]]
	then
		start-stop-daemon -v -p $pid -K
		rm -f $pid
	else
		echo "Unknown request: '$cmd'"
	fi
fi

echo 'Done'
