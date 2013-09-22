#!/bin/bash
#
# v.0.8 RC
#
# Use this script to carry out the fast and fun downloading process the all official MegaGlest mods available in game mods' centre.
# ----------------------------------------------------------------------------
# Before first run: make the script executable ("chmod +x download-mg-m.sh").
# Run the script in console using this command: "./download-mg-m.sh".
# ----------------------------------------------------------------------------
# Written by filux <heross(@@)o2.pl>
# Copyright (c) 2013 filux under GNU GPL v3.0
LANG=C

echo -e "\n\n\n"; clear; echo " "
path=~/.megaglest/; dsx=".7z"; adpx="curl http://master.megaglest.org/show"; adsx="ForGlest.php"

if [ "$1" == "--headless" ]; then noscenarios='true';
else noscenarios='false'; fi

fun_err() {
	if [ "$?" -ne "0" ]; then echo -e "\n >>> an error was detected <<< "
		case $1 in
			er1) echo -e "\n > It looks like that the problem is related to the functioning of the external script or application. <\n\n press enter key to continue/exit...\n"; sleep 1s; read -t30; exit 1;;
			er2) echo -e "\n > It looks like you have missing write permissions. <\n\n press enter key to continue/exit...\n"; sleep 1s; read -t30; exit 2;;
			er3) echo -e "\n > It looks like some problem with network connection. <\n\n press enter key to continue/exit...\n"; sleep 1s; read -t30; exit 3;;
			*) ;;
		esac
	fi
}

te_fs=`$adpx"Techs"$adsx 2>/dev/null`; fun_err er3
ti_fs=`$adpx"Tilesets"$adsx 2>/dev/null`; fun_err er3
if [ "$noscenarios" == "false" ]; then 
	sc_fs=`$adpx"Scenarios"$adsx 2>/dev/null`; fun_err er3
fi
ma_fs=`$adpx"Maps"$adsx 2>/dev/null`; fun_err er3

if [ ! -d "$path" ]; then 
	mkdir "$path"; fun_err er2
	sleep 0.5s 
fi 

fun_mk () {
	if [ ! -d "$path""$spx" ]; then 
		mkdir "$path""$spx"; fun_err er2
		sleep 0.5s
	fi
} 

fun_get () {
	if [ "$spx" = "maps/" ]; then sx=""; 
				else sx="$dsx"; fi
	
	IFS='|'
	while read; do
		read -ra array <<< "$REPLY"
		
		if [ "$spx" = "tilesets/" ] || [ "$spx" = "scenarios/" ]; then addr="${array[3]}"
									else addr="${array[4]}"; fi
		
		name="${array[0]}"
		wget -O "$name""$sx" -c "$addr"; fun_err er3
		echo -e " -- V --\n"
		sleep 0.2s 
		
		if [ "$spx" = "maps/" ] && [ ! -f "$name" ]; then sleep 1s; fi
		
		if [ ! -d "$name" ] && [ -f "$name$dsx" ]; then 
			7z x -y "$name""$dsx"; fun_err er1
			echo -e "\n -- V --\n"
			sleep 0.2s
		fi
	done< <(echo "$files")
	sleep 1s
	unset IFS
}

spx="maps/"; fun_mk; cd "$path""$spx"; files="$ma_fs"; fun_get
spx="tilesets/"; fun_mk; cd "$path""$spx"; files="$ti_fs"; fun_get
spx="techs/"; fun_mk; cd "$path""$spx"; files="$te_fs"; fun_get
if [ "$noscenarios" == "false" ]; then 
	spx="scenarios/"; fun_mk; cd "$path""$spx"; files="$sc_fs"; fun_get
fi

exit 0
