#!/bin/bash
#
# v.0.8.5 RC
#
# Use this script to carry out fast and fun downloading process of all official MegaGlest mods available in game mods' centre.
# Run it from any localization and then look for downloaded files in default localization ~/.megaglest/...
# ----------------------------------------------------------------------------
# Before first run: make the script executable ("chmod +x download-mg-m.sh").
# Run the script in console using this command: "./download-mg-m.sh".
# For headless server purposes (without scenarios) use command: "./download-mg-m.sh --headless".
# ----------------------------------------------------------------------------
# Written by filux <heross(@@)o2.pl>
# Copyright (c) 2013 filux under GNU GPL v3.0
LANG=C

echo -e "\n\n\n"; clear; echo " "
if [ `id -u`'x' = '0x' ]; then echo " This script can't be run as root."; read -t5; exit 9; fi
path=~/.megaglest/; dsx=".7z"; adpx="curl http://master.megaglest.org/show"; adsx="ForGlest.php"; errcount=0; skipunpack=0

if [ "$1" == "--headless" ]; then noscenarios='true';
			else noscenarios='false'; fi

fun_err() {
	if [ "$?" -ne "0" ]; then echo -e "\n >>> an error was detected <<< "
		case $1 in
			er1) echo -e "\n > It looks like that the problem is related to the functioning of the external 7z application. <\n"; sleep 10s; exit 1;;
			er2) echo -e "\n > It looks like you have missing write permissions. <\n\n press enter key to continue/exit...\n"; sleep 1s; read -t30; exit 2;;
			er3) echo -e "\n > It looks like some problem with server or network connection. <\n\n press enter key to continue/exit...\n"; sleep 1s; read -t30; exit 3;;
			er4) echo -e "\n > It looks like some problem with server or network connection. <\n"
				errcount=`expr $errcount + 1`; skipunpack=1; sleep 2s
				if [ "$errcount" -gt "3" ]; then sleep 10s; exit 4; fi;;
			*) ;;
		esac
	fi
}

te_fs=`$adpx"Techs"$adsx 2>/dev/null`; fun_err er3
ti_fs=`$adpx"Tilesets"$adsx 2>/dev/null`; fun_err er3
if [ "$noscenarios" != "true" ]; then
	sc_fs=`$adpx"Scenarios"$adsx 2>/dev/null`; fun_err er3
fi
ma_fs=`$adpx"Maps"$adsx 2>/dev/null`; fun_err er3

if [ ! -d "$path" ]; then 
	mkdir "$path"; fun_err er2
	sleep 0.5s 
fi 

fun_mkcd () {
	if [ ! -d "$path""$spx" ]; then
		mkdir "$path""$spx"; fun_err er2
		sleep 0.5s
	fi
	
	cd "$path""$spx"
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
		wget -O "$name""$sx" -c "$addr"; fun_err er4
		echo -e " -- V --\n"
		sleep 0.2s 
		
		if [ "$spx" = "maps/" ] && [ ! -f "$name" ]; then sleep 1s; fi
		
		if [ "$skipunpack" -eq "0" ]; then
			if [ ! -d "$name" ] && [ -f "$name$dsx" ]; then 
				7z x -y "$name""$dsx"; fun_err er1
				echo -e "\n -- V --\n"
				sleep 0.2s
			fi
		else
			skipunpack=0
		fi
	done< <(echo "$files")
	
	sleep 1s
	unset IFS
}

spx="maps/"; echo -e " -- V - maps - V --\n"; fun_mkcd; files="$ma_fs"; fun_get
spx="tilesets/"; echo -e " -- V - tilesets - V --\n"; fun_mkcd; files="$ti_fs"; fun_get
spx="techs/"; echo -e " -- V - techs - V --\n"; fun_mkcd; files="$te_fs"; fun_get
if [ "$noscenarios" != "true" ]; then 
	spx="scenarios/"; echo -e " -- V - scenarios - V --\n"; fun_mkcd; files="$sc_fs"; fun_get
fi

exit 0
