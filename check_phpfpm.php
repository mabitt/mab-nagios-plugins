<?php

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

#   PNP Template for check_cpu.sh
#   Author: Mike Adolphs (http://www.matejunkie.com/

$opt[1] = "--vertical-label \"processes\" -l 0 -r --title \"PHP-FPM processes $hostname / $servicedesc\" ";


$def[1] =  "DEF:active=$rrdfile:$DS[2]:AVERAGE " ;
$def[1] .= "DEF:idle=$rrdfile:$DS[1]:AVERAGE " ;
$def[1] .= "DEF:total=$rrdfile:$DS[3]:AVERAGE " ;

$def[1] .= "COMMENT:\"\\t\\t\\tLAST\\t\\t\\tAVERAGE\\t\\tMAX\\n\" " ;

$def[1] .= "AREA:active#E8630C:\"active\\t\":STACK " ;
$def[1] .= "GPRINT:active:LAST:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:active:AVERAGE:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:active:MAX:\"%6.0lf \\n\" " ;

$def[1] .= "AREA:idle#3E00FF:\"idle\\t \\t\":STACK " ;
$def[1] .= "GPRINT:idle:LAST:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:idle:AVERAGE:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:idle:MAX:\"%6.0lf \\n\" " ;

$def[1] .= "LINE:total#3E00FF:\"Total\\t\t\" " ;
$def[1] .= "GPRINT:total:LAST:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:total:AVERAGE:\"%6.0lf \\t\\t\" " ;
$def[1] .= "GPRINT:total:MAX:\"%6.0lf \\n\" " ;

?>
