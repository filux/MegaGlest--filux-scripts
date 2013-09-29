#!/bin/bash
#
# v.0.8.5 RC
# Use this script to carry out the whole "installation" process of svn MegaGlest game on a number of Linux platforms.
#
# By design, this script should be run only once.
# When the script asks: Do you want to install or update some libraries?, you must agree on it.
# It's hard to predict the exact time of "installation", but it can take average about 1 hour.
# Before starting make sure, that you have at least ~1,6 GiB free space on partition with "/home/" directory.
# ----------------------------------------------------------------------------
# Before first run: make the script executable ("chmod +x run-installation.sh").
# Run the script in console using this command: "./run-installation.sh".
# The entire installation process is written to a log file.
# ----------------------------------------------------------------------------
# Written by filux <heross(@@)o2.pl>
# Copyright (c) 2013 filux under GNU GPL v3.0
LANG=C


if [ `id -u`'x' = '0x' ]; then echo " This script can't be run as root; the root's password will be required per moment after starting."; exit 9; fi
pwd0="$(pwd)""/"; pwd1="$pwd0""libraries/"; ilog="$pwd0""install.log"

fun_err() { 
	if [ "$?" -ne "0" ]; then 
		echo -e "\n >>> an error was detected <<<";
		echo -e "\n > Are you sure that you placed the script in the right directory? <"
		echo -e "\n ...and in this directory doesn't have missing write permissions?\n"
		sleep 10s
		exit 1 
	fi
 }

echo -e "Installation was started:\n`date`" > "$ilog"; fun_err; 
sleep 0.3s

cd "$pwd1"; fun_err
chmod +x install-mg.sh; fun_err

sleep 0.3s
./install-mg.sh |& tee -a "$ilog"; fun_err

sleep 1s
echo -e "\nInstallation was finisheded (or interrupted):\n`date`\n" >> "$ilog"; fun_err

exit 0
