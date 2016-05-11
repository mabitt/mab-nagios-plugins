#!/bin/sh

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

PROGNAME=`basename $0`
VERSION="Version 0.1.0,"
AUTHOR="MAB (MAB@MAB.NET)"

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo "$PROGNAME is a Nagios plugin to check blocked ips on HAProxy frontends,"
    echo ""
    exit $ST_UK
}

while test -n "$1"; do
    case "$1" in
        -help|-h)
            print_help
            exit $ST_UK
            ;;
        --version|-v)
            print_version $PROGNAME $VERSION
            exit $ST_UK
            ;;
        --frontend|-f)
            frontend=$2
            shift
            ;;
        --warning|-w)
            warning=$2
            shift
            ;;
        --critical|-c)
            critical=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit $ST_UK
            ;;
        esac
    shift
done

get_wcdiff() {
    if [ ! -z "$warning" -a ! -z "$critical" ]
    then
        wclvls=1
        if [ ${warning} -gt ${critical} ]
        then
            wcdiff=1
        fi
    elif [ ! -z "$warning" -a -z "$critical" ]
    then
        wcdiff=2
    elif [ -z "$warning" -a ! -z "$critical" ]
    then
        wcdiff=3
    fi
}

val_wcdiff() {
    if [ "$wcdiff" = 1 ]
    then
        echo "Please adjust your warning/critical thresholds. The warning must be lower than the critical level!"
        exit $ST_UK
    elif [ "$wcdiff" = 2 ]
    then
        echo "Please also set a critical value when you want to use warning/critical thresholds!"
        exit $ST_UK
    elif [ "$wcdiff" = 3 ]
    then
        echo "Please also set a warning value when you want to use warning/critical thresholds!"
        exit $ST_UK
    fi
}

get_vals() {
   haproxy_status=`echo "show table" ${frontend}| sudo socat stdio /var/run/haproxy.stat | grep -v "gpc0=0" | wc -l`
   haproxy_status=$(($haproxy_status - 2))
}

do_output() {
    output="Blocked clients on frontend \
${frontend}: \
${haproxy_status}"
}

do_perfdata() {
    perfdata="'blocked'=${haproxy_status}"
}


# Here we go!
get_wcdiff
val_wcdiff
if [ -z "$frontend" ]
    then
        echo "Please adjust your frontend value!"
        exit $ST_UK
fi
get_vals
do_output
do_perfdata

if [ -n "$warning" -a -n "$critical" ]
then
    if [ "$haproxy_status" -ge "$warning" -a "$haproxy_status" -lt "$critical" ]
    then
        echo "WARNING - ${output} | ${perfdata}"
        exit $ST_WR
    elif [ "$haproxy_status" -ge "$critical" ]
    then
        echo "CRITICAL - ${output} | ${perfdata}"
        exit $ST_CR
    else
        echo "OK - ${output} | ${perfdata}"
        exit $ST_OK
    fi
else
   echo "OK - ${output} | ${perfdata}"
    exit $ST_OK
fi

exit $ST_UK

