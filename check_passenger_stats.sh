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
#
#   Author: Joel Parker Henderson (joel@sixarm.com, http://sixarm.com)
#   Updated: 2010-11-19
#
#   This program is based on code from check_nginx.sh
#   created by Mike Adolphs (http://www.matejunkie.com/)
#
#   We use this script to do Nagios monitoring on our web servers
#   that are running Ruby On Rails, Apache and Phusion Passenger.
#
#   For more info on Passenger & Nagios:
#   Phusion Passenger: http://phusion.nl
#   Nagios monitoring: http://www.nagios.org
#   Nagios graph tool: http://nagiosgraph.sourceforge.net/
#
#   We use this script for gathering memory stats info which we
#   display using Nagios Graph overlaid with other Nagios stats,
#   so this script always outputs "OK" rather than any alerts.
#
#   If you want to use the critical alert features of Nagios,
#   then you can modify this script to return different output
#   depending on whatever values that you feel are best for
#   your own server, available RAM, and Passenger settings.
#   If you need help with this, feel free to contact me.
#
### Include this lines in sudoers file
#Cmnd_Alias NRPE = /opt/ruby-enterprise/bin/passenger-status, /opt/ruby-enterprise-1.8.7-2010.02/bin/passenger-status
#nrpe    ALL=(ALL)               NOPASSWD: NRPE



PROGNAME=`basename $0`
VERSION="Version 1.2.0-MAB,"
AUTHOR="2011 MAB (mab@mab.net) based on 2010, Joel Parker Henderson (joel@sixarm.com, http://sixarm.com/)"

output_dir=/tmp
passengerstatus=/opt/ruby-enterprise/bin/passenger-status
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
    echo "$PROGNAME is a Nagios plugin to check passenger stats,"
    echo "specifically for Passenger processes/s and global queue."
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
get_status() {
    filename=${PROGNAME}-${HOSTNAME}
    filename=`echo $filename | tr -d '\/'`
    filename=${output_dir}/${filename}
    check_start=`date +%s`
    sudo ${passengerstatus} > ${filename}.1 2>/dev/null
    sleep 1
    sudo ${passengerstatus} > ${filename}.2 2>/dev/null
    check_end=`date +%s`
    }


get_vals() {
   passenger_status_global_queue=`cat ${filename}.1 | grep "global queue" | sed 's/.*: //; s/ //;'`
   passenger_status_processed_1=`cat ${filename}.1 | awk '{ sum += $7 }; END { print sum }'`
   passenger_status_processed_2=`cat ${filename}.2 | awk '{ sum += $7 }; END { print sum }'`
   passenger_status_processed=$((($passenger_status_processed_2 - $passenger_status_processed_1) / ($check_end - $check_start)))
   rm -f ${filename}.*
}

do_output() {
    output="Passenger global queue stats: \
${passenger_status_global_queue} / \
${passenger_status_processed} process/s"
}

do_perfdata() {
    perfdata="'queue'=${passenger_status_global_queue} \
'procs'=${passenger_status_processed}"
}


# Here we go!
get_wcdiff
val_wcdiff
get_status
get_vals
do_output
do_perfdata

if [ -n "$warning" -a -n "$critical" ]
then
    if [ "$passenger_status_global_queue" -ge "$warning" -a "$passenger_status_global_queue" -lt "$critical" ]
    then
        echo "WARNING - ${output} | ${perfdata}"
        exit $ST_WR
    elif [ "$passenger_status_global_queue" -ge "$critical" ]
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

