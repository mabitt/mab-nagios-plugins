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
VERSION="Version 0.0.0,"
AUTHOR="MAB@MAB.NET"


ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3
url=""

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
        echo ""
    echo "$PROGNAME is a Nagios plugin to check a url response md5 hash."
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
        --url|-H)
            url=$2
            shift
            ;;
        --md5|-P)
            md5=$2
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
get_args() {
    if [ -z "$url" -o -z "$md5" ]
    then
        echo "Please adjust your url/md5 values!"
        exit $ST_UK
    fi
}

get_md5() {
    md5response=`curl $url 2>/dev/null | md5sum --binary | awk {'print $1'}`
}

# Here we go!
get_args
get_md5

if [ "$md5response" !=  "$md5" ]
then
    echo "CRITICAL - check mismatch - Downloaded file MD5: $md5response"
    exit $ST_CR
else
    echo "OK - MD5 check pass"
    exit $ST_OK
fi

