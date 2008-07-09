#!/bin/bash

## Justin White
## July 2008

## this little proggy uses debian's start-stop-daemon
## to get the scgi server going and stopping, and restarting
## like rc.d scripts, but this is mine, for practice

cmd=$1

name="scgi-server"

gid="www"
uid="www"

dir="/home/www/main"
exe="$dir/$name.py"
pid="$dir/$name.pid"
log="$dir/$name.log"

starter() {
	echo -n Starting $name...
	start-stop-daemon -v -g $gid -c $uid -d $dir -mp $pid -Sba $exe
	echo Done
}

stopper() {
	echo -n Stopping $name...
	start-stop-daemon -v -p $pid -K
	rm -f $pid
	echo Done
}

case "$cmd" in
"start")
	starter
;;
"stop")
	stopper
;;
"restart")
	stopper
	starter
;;
*)
	echo "Unknown request: '$cmd'"
;;
esac
