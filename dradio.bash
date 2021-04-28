#!/bin/bash
#Start von firefox mit Deutschlandradio.de Lifestream App

/bin/echo "$@" "$*"

. /usr/local/etc/dradio.conf

DEBUG=$1
/bin/echo "$DEBUG"
if [[ "$DEBUG" == '-debug' ]] ; then
	set -x -v
	/bin/echo "This programm $0 is called with args $*"
	/bin/echo "if then $DEBUG"
	DBG="-v";
	/bin/echo $DBG
	/bin/echo "DISPLAY $DISPLAY"
else
	DBG=""
	/bin/echo 'if else no debug'
fi

while /usr/bin/xprop -name "${WINDOW_TITLE}" > /dev/null ; # kill all applications with the WINDOW_TITLE
do
	DRADIO_PID=$(/usr/bin/xprop -name "${WINDOW_TITLE}" | /bin/grep -m 1 PID | /usr/bin/cut -d "=" -f2)
	/bin/echo "DRADIO_PID=${DRADIO_PID}"
	[ -n "${DRADIO_PID}" ] && /bin/kill -15 "${DRADIO_PID}" || /bin/kill -9 "${DRADIO_PID}"
done 

if [[ $DBG == "-v" ]]; then
	date0=$(/bin/date +%s.%N)
fi

${EXEC_STRING} --new-window "${WINDOW_URL}" &
DRADIO_PID=$!

if [[ $DBG == "-v" ]]; then
	/bin/echo DRADIO_PID=${DRADIO_PID}
	date1=$(/bin/date +%s.%N)
	/bin/echo "$date1-$date0" | /usr/bin/bc
fi

# It takes several seconds, until the app is loaded and the window can be identified

until /usr/bin/xwininfo -tree -root | /bin/grep ${WINDOW_SHORT}; 
do
	/bin/echo /usr/bin/xwininfo $?
	/bin/sleep 3
done

# find the window ID 
DRADIO_WIN_ID=$(/usr/bin/xwininfo -tree -root | /bin/grep ${WINDOW_SHORT} | /usr/bin/cut -c 9-17)

if [[ $DBG == "-v" ]]; then
	/bin/echo "DRADIO_WIN_ID=${DRADIO_WIN_ID}"
	date2=$(/bin/date +%s.%N)
fi

# first resize window and second put im proper place
/usr/bin/wmctrl "$DBG" -i -r "${DRADIO_WIN_ID}" -b remove,maximized_horz,maximized_vert 
/usr/bin/wmctrl "$DBG" -i -r "${DRADIO_WIN_ID}" -e 0,"$X_POS,$Y_POS,$WIDTH,$HEIGHT"
# not in xdotool

if [[ $DBG == "-v" ]]; then
	/bin/echo "$date2-$date0" | /usr/bin/bc
	/bin/echo $X_POS,$Y_POS,$WIDTH,$HEIGHT $?
fi

exit 0

