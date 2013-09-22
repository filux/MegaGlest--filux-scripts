#!/bin/bash
#
# v.0.8 RC
# This script is used as a "library".
#
# Use this script to carry out the whole "installation process" of svn MegaGlest game on a number of Linux platforms.
# ----------------------------------------------------------------------------
# Written by filux <heross(@@)o2.pl>
# Copyright (c) 2013 filux under GNU GPL v3.0
LANG=C

echo -e "\n\n\n"; clear; echo " "
if [ `id -u`'x' = '0x' ]; then echo " This script can't be run as root; the root's password will be required per moment after starting."; exit 9; fi
pwd0="$(pwd)""/"; script="megaglest-svn.sh"; scrfile="$pwd0""$script"; cd ~; pwd1="$(pwd)""/"; dir="mglestsvn"; pwd2="$pwd1""$dir""/"; scrfile2="$pwd2""$script"
svnc="svn co https://megaglest.svn.sourceforge.net/svnroot/megaglest/trunk ."; line="--------------------------------------"
cnetg="defaultNetworkGameSetup.mgg"; opcnetg="$pwd0""$cnetg"; pcnetg="$pwd2""data/glest_game/data/"; count=0; ssize=1025
KDIALOG=$(which kdialog 2>/dev/null) || KDIALOG=''; ZENITY=$(which zenity 2>/dev/null) || ZENITY=''
fun_err() { if [ "$?" -ne "0" ]; then echo -e "\n >>> an error was detected <<< "
  case $1 in
    er1) echo -e "\n > It looks like that the problem is related to the functioning of the external script or application. <\n\n press enter key to continue/exit...\n"; sleep 0.5s; read -t30; exit 1;;
    er2) echo -e "\n > It looks like you have missing write permissions. <\n\n press enter key to continue/exit...\n"; sleep 0.5s; read -t30; exit 2;;
    er3) echo -e "\n > It looks like some problem with network connection or svn server. <\n"; sleep 5s; svn cleanup; echo -e "\n press enter key to continue/exit...\n"; sleep 0.5s; read -t30; exit 3;;
    er4) echo -e "\n > Are you sure that you placed the script in the right directory? <\n\n press enter key to continue/exit...\n"; sleep 0.5s; read -t30; exit 4;;
      *) ;;
  esac; fi }
cd "$pwd0"; fun_err er4; chmod +x "$pwd0""libraryBuildDeps.sh"; fun_err er2; echo -e " Please enter the root's password.\n"; sleep 0.3s
echo -n " "; echo -e "$pwd0>./libraryBuildDeps.sh\n"; echo -n " "; sleep 0.3s; sudo "$pwd0""./libraryBuildDeps.sh"; fun_err er1
if [ ! -d "$pwd2" ]; then mkdir "$pwd2"; fun_err er2; fi
cd "$pwd2"; fun_err er4; echo -e "\n\n$pwd2>$svnc\n"; if [ -x "$ZENITY" ] || [ -x "$KDIALOG" ]; then ( if [ ! -x "$ZENITY" ] && [ -x "$KDIALOG" ]; then 
dbusRef=`kdialog --progressbar "Downloading in progress..." --geometry 460x50+0+50 100`; fi; (while [ "$count" -lt "101" ]; do sleep 30s; du_s=`du -sm "$pwd2"`; asize=`expr "$du_s" : '\([0-9]*[0-9]\)'`;
if [ "$asize" -lt "1" ]; then asize=1; fi; count=$(($asize * 100 / $ssize)); if [ -x "$ZENITY" ]; then echo $count; elif [ -x "$KDIALOG" ]; then qdbus $dbusRef Set "" value $count; fi; if [ -f "$scrfile2" ]; then 
count=102; fi; done ) | if [ -x "$ZENITY" ]; then zenity --progress --text="Downloading\ in\ progress..." --width=460 --auto-close; fi; if [ ! -x "$ZENITY" ] && [ -x "$KDIALOG" ]; then qdbus $dbusRef close; fi ) &
fi; sleep 0.3s; $svnc; if [ "$?" -ne "0" ]; then sleep 2s; svn cleanup; sleep 5s; $svnc; fun_err er3; fi
if [ -f "$scrfile" ]; then cp "$scrfile" "$pwd2"; fun_err er2; cd "$pwd2"; fun_err er4; sleep 0.3s; chmod +x "$script"; fun_err er2; fi
sleep 0.3s; echo -e "\n\n$pwd2>./$script -fh"; ./"$script" -fh; fun_err er1; cp "$opcnetg" "$pcnetg"; fun_err er2; echo -e "\n$line$line
 Situation look like game was downloaded and compilated successfully.\n You will find the startup script the latest version of svn game in location:
 $pwd2\n Launch it with the command: "'"./'$script'"'"\n\n or with command: "'"./'$script' --help"'" to get more information about it.\n$line$line\n"
sleep 5s; echo -e " press enter key to continue/exit...\n"; read -t30; exit 0

