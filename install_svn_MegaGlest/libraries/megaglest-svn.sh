#!/bin/bash
#
# Script performs the function of updating, compiling and running the latest svn revision of the MegaGlest game in linux OS.
#
# filux's script v.0.8 RC, written and working perfectly in opensuse x64 v.12.2 with KDE
# Thanks for beta testing and given ideas to: Jammyjamjamman, titi|son, tomreyn.
# ----------------------------------------------------------------------------
# Written by filux <heross(@@)o2.pl>
# Copyright (c) 2013 filux under GNU GPL v3.0
# ----------------------------------------------------------------------------
# The objective of the script is to simplify the process of making sure the game is up to date before it is run, but in such a way that doesn't besot (not too much xD) its users.
#
# This script should be placed in the main directory, (parallel) to the "source" and "mk" directory etc.
# For example if exist path like this: "/home/user/megaglest_svn/mk/linux/" put the script in: "megaglest_svn" directory.
# Before first run make the script executable ("chmod +x megaglest-svn.sh").
# Run the script in console using this command: "./megaglest-svn.sh". It is also possible to run the script with the parameters, for more information about it go in to the help: "./megaglest-svn.sh --help".
#
# After the first run script, file/shortcut "megaglest-svn.desktop" will be created in the script's directory. 
# You can use this file as a mouse clickable shortcut to run script.
# If you want to have it on your desktop I suggest to create the shortcut (soft link/symlink/symbolic link etc.) for it. 
# How to create a symlink? The most universal way is using command similar to this example: "ln -s /home/user/megaglest_svn/megaglest-svn.desktop /home/user/Desktop/megaglest-svn.desktop"
# If you want to have it on standard OS menu (where you have "links" to instaled in standard way RTS games) I recommend creating (as root) a symlink in the path: "/usr/share/applications/".
LANG=C

echo -e "\n\n\n"; clear
if [ `id -u`'x' = '0x' ]; then echo -e "\n This script can't be run as root;\n the root's password may be required after starting (libcheck).\n"; exit 9; fi
count=0; helpex=0; noconex=0; fastex=0; freshex=0; rebuildex=0; libcheckex=0; ulimitcex=0; verboseex=0; runheadlessex=0; conect=0; conect2=0
vparam="--verbose"; hparam="--headless-server-mode=exit,vps"; FILE=$'megaglest-svn.desktop'; dir="mk"; builddir="build"; libso="lib"; libso2="lib_bkp"; pwd1="$(pwd)""/"; pwd3="$pwd1""mk/linux/"
pathtolog="$pwd1""logs/"; logfile="$pathtolog""lastsvngame.log"; logfilev="$pathtolog""lastvsvngame.log.gz"; logfileh="$pathtolog""lasthsvngame.log"
logfilevd="$logfilev""_date.txt"; logcoredate="$pathtolog""core_date.txt"; fullrebfile="$pathtolog""last_full_rebuild.mem"; x1=0.004; x2=0.02; x3=0.04; x4=0.08
exc="Mdata/glest_game/data/defaultNetworkGameSetup.mgg"; exc2="Mbuild-mg.sh"; exc3="Mmk/linux/setupBuildDeps.sh"; line="-----------------------------------"
while [ "$count" -lt "$#" ]; do count=`expr $count + 1`
  case ${@:$count:1} in
    "--help"|"-h") helpex=1;; "--nocon"|"-nc") noconex=1;; "--fast"|"-ft") fastex=1;; "--fresh"|"-fh") freshex=1;; "--rebuild"|"-rb") rebuildex=1;; 
    "--libcheck"|"-lc") libcheckex=1;; "--ulimitcu"|"-uu") ulimitcex=1;; "--verbose"|"-v") verboseex=1;; "--runheadless"|"-rh") runheadlessex=1;; *) ;;
  esac
done
if [ "$fastex" -ne "1" ]; then x1=0.4; x2=2; x3=4; x4=8; fi
fun_0() { if [ "$?" -ne "0" ]; then echo -e "\n >>> an error was detected <<< "
  case $1 in
    er1) echo -e "> Are you sure that you placed the script in the right directory? <\n> ...and MegaGlest svn game directories and files exist? <\n"; sleep "$x4"s; exit 1;;
    er2) echo -e "> It looks like that the script directory has missing write permissions. <\n"; sleep "$x4"s; exit 2;;
    er3) echo -e "> It looks like that the problem is related to the functioning of the external script or application. <\n"; sleep "$x4"s; exit 3;;
      *) ;;
  esac; fi
}
fun_1() { pidof megaglest &>/dev/null
  if [ "$?" -eq "0" ] && [ "$freshex" -ne "1" ]; then sleep "$x1"s; echo -e "\n Game client is already running. >>> Switches tasks to the "'"fresh"'" mode."; freshex=1; sleep "$x1"s; fi
  cd "$pwd3"; fun_0 er1; sleep 0.25s; echo -e "\n> Last full rebuild was: $rebrecord"
  if [ "$freshex" -ne "1" ]; then sleep "$x1"s
    if [ "$ulimitcex" -eq "1" ]; then
      ulimit -c unlimited; fun_0 er3; rm -f core*; fun_0 er2; echo -e "> Core File Dump is enabled:.../> ulimit -c unlimited  &&  rm -f core"
      echo -e "Last time when game has been launched with enabled Core File Dump was:\n`date`\n(if the Core file doesn't exist [.../mk/linux/] it means that it wasn't then created)\n\n" > "$logcoredate"; fun_0 er2
    fi
    if [ "$verboseex" -eq "1" ]; then echo -e "\n "$pwd3"> ./megaglest $vparam\n\n"; sleep "$x2"s
      date > "$logfilevd"; fun_0 er2; ./megaglest "$vparam" |& tee /dev/stderr | gzip -f > "$logfilev"; fun_0 er3
    elif [ "$runheadlessex" -eq "1" ]; then echo -e "\n "$pwd3"> ./megaglest $hparam\n"; sleep "$x3"s; clear; sleep "$x1"s
      echo -e "$line$line\n Attention!\n When you close the console, headless-server will be closed too.\n$line$line"; sleep "$x1"s; echo -e " >>> script has started the headless server <<<\n `date`\n" > "$logfileh"
      fun_0 er2; sleep 0.05s; ./megaglest --version |& tee -a "$logfileh"; fun_0 er3; sleep 0.05s; echo " " >> "$logfileh"; sleep 1s; echo -e "\n Waiting for players to join and start a game...\n"
      ./megaglest "$hparam" |& tee -a "$logfileh"; fun_0 er3
    else echo -e "\n "$pwd3"> ./megaglest\n"; sleep "$x2"s; sleep "$x1"s
      echo -e "Output from filux's script:\n`date`\n" > "$logfile"; fun_0 er2; sleep 0.05s; ./megaglest --version; fun_0 er3; sleep 1s;
      if [ "$ulimitcex" -ne "1" ]; then nohup ./megaglest >> "$logfile" 2>&1 0>/dev/null & 
      else ./megaglest |& tee -a "$logfile"; fun_0 er3; fi
    fi
    if [ "$noconex" -eq "1" ]; then sleep "$x1"s; echo -e "\n press enter key to continue/exit...\n\n"; read -t15; fi
  else
    if [ -f megaglest ]; then echo " "; ./megaglest --version; fun_0 er3; fi; echo -e "\n"
    if [ "$noconex" -eq "1" ]; then sleep "$x1"s; echo -e " press enter key to continue/exit...\n\n"; read -t25; fi
  fi
} 
fun_2() { sleep "$x3"s; clear; sleep "$x1"s; 
  if [ -d "$builddir" ] && [ "$rebuildex" -ne "1" ]; then nrebrecord=`expr $nrebrecord + 1`; else nrebrecord=0; fi; rebrecord="$nrebrecord regular builds ago"; echo "$rebrecord" > "$fullrebfile"; fun_0 er2
  echo -e "\n "$pwd1"> ./build-mg.sh\n"; sleep "$x2"s
  ./build-mg.sh; fun_0 er3
  echo -e "\n >>> ./build-mg.sh >>> done <<<\n"; sleep "$x3"s; clear
  fun_1
}
fun_3() { sleep "$x1"s; echo -e "\n "$pwd1"> svn update\n"; sleep "$x2"s
  timeout 5m svn update && conect2=1
  if [ "$?" -ne "0" ]; then sleep 10s; svn cleanup; sleep 10s; timeout 5m svn update && conect2=1; fi
  if [ "$conect2" -eq "1" ]; then echo -e "\n >>> svn update >>> done <<<\n"
  else echo -e "\n >>> svn update >>> have failed <<<\n\n When launching the game without checking the updates\n is recommended to play only in a single player mode.\n"; sleep 1s; fi
  fun_2
}
if [ "$helpex" -eq "1" ]; then  
  echo -e "\n Usage: megaglest-svn.sh [OPTIONS] >>> ./megaglest-svn.sh [--a ... --z]\n\n Script performs the function of updating, compiling and running the latest svn revision of the MegaGlest game in linux OS.\n\n Optional arguments:
--fast,-ft       significantly reduces time given to read messages\n--fresh,-fh      only update the compilation, without starting the game\n--rebuild,-rb    cause forced full rebuild of compilation
--libcheck,-lc   cause launch verification of the libraries needed to compile the game (root's password needed)\n--nocon,-nc      designed "'"to say"'": that script isn't run directly from the console (.desktop)
--ulimitcu,-uu   enables Core File Dump (useful debugging informations when game client crashes)\n--help,-h        give this help list\nUsing more than one parameter at the same time is possible too, but exist an exception: "'"--help"'"\n
 Additionally one of the following parameters can be used as transferred (indiretly) to command launching the game:\n--verbose,-v        cause launch game with more debugging informations than normally
--runheadless,-rh   cause launch headless server for one network game\n  \n Exit status:\n 0         if "'"ok"'",\n 1,2,3,9   if an error was detected.\n 
 Report script's bugs to filux in the mail heross(@@)o2.pl\n"
  sleep 5s; if [ "$noconex" -eq "1" ]; then sleep "$x1"s; echo -e " press enter key to continue/exit...\n"; read -t55; fi
else
  if [ ! -d "$dir" ]; then ! test "$dir"; fun_0 er1; fi
  if [ ! -d "$pathtolog" ]; then mkdir "$pathtolog"; fun_0 er2; fi
  if [ ! -f "$FILE" ]; then
    echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=MegaGlest svn\nGenericName=svn MegaGlest - Realtime Strategy Game\nComment=latest svn version of the MegaGlest game\nPath="$pwd1"\nIcon="$pwd3"megaglest.png\nType=Application\nTerminal=true
Exec=/bin/bash ./megaglest-svn.sh -nc\nCategories=Game;StrategyGame;" > "$FILE"; fun_0 er2; sleep 0.05s; chmod +x "$FILE"; fun_0 er2
  fi
  if [ "$libcheckex" -eq "1" ]; then cd "$pwd3"; fun_0 er1
    if [ ! -d "$libso" ]; then mkdir "$libso"; fun_0 er2; if [ ! -d "$libso2" ]; then mkdir "$libso2"; fun_0 er2; fi
    elif [ -d "$libso2" ] && [ ! "$(ls -A $libso2)" ]; then rm -r "$libso2"; fun_0 er2; fi
    sleep "$x1"s; echo -e "\n Script launched verification of the libraries needed to compile the game.\n"; sleep "$x1"s
    echo -e " "$pwd3"> ./setupBuildDeps.sh\n\n"; sleep "$x1"s; echo -e " Verification has to be done with "'"administrator"'" rights. Please enter the root's password.\n"
    echo -n " "; sleep "$x2"s; sudo ./setupBuildDeps.sh; fun_0 er3; echo -e "\n\n"; sleep "$x3"s
    if [ -f "megaglest" ]; then echo -e " "$pwd3"> ./start_megaglest --version\n"; sleep "$x2"s; ./start_megaglest --version; fun_0 er3; echo -e "\n\n"; sleep "$x3"s; fi; clear
  fi
  cd "$pwd1"; fun_0 er1; if [ "$rebuildex" -eq "1" ] && [ -d "$builddir" ]; then rm -r "$builddir"; fun_0 er1; fi
  if [ -f "$fullrebfile" ]; then read rebrecord < "$fullrebfile"; sleep 0.05s; nrebrecord=`expr "$rebrecord" : '\([0-9]*[0-9]\)'`; else nrebrecord=0; rebrecord="$nrebrecord regular builds ago"; echo "$rebrecord" > "$fullrebfile"; fun_0 er2; fi
  echo -e "\n >>> script checking now:\n"; echo -n " Is the MegaGlest svn game up to date?"
  rezult=`timeout 2m svn status -qu` && conect=1 
  if [ "$conect" -ne "1" ]; then clear; sleep "$x1"s 
    echo -e "\n Oops... Some problem with the connection to server detected.\n\n When launching the game without checking the updates\n is recommended to play only in a single player mode.\n"; sleep 1s; sleep "$x2"s
    if [ ! -d "$builddir" ]; then 
      if [ "$rebuildex" -ne "1" ]; then sleep "$x1"s; echo -e " ... and "'"build"'" directory doesn't exist.\n"; fi; 
      fun_2 
    else sleep "$x1"s; fun_1; fi
  else
    rezultl=${#rezult}
    if [ "$rezultl" -lt "999" ]; then
      serverv=`expr "$rezult" : '.*\(.....\)'`; rezult2=$(echo "$rezult" | sed -e '$d' -e "s|$serverv||" -e 's/ //g')
      rezult3=$(echo "$rezult2" | sed -e "s|$exc||" -e "s|$exc2||" -e "s|$exc3||" -e '/^$/d'); rezultl2=${#rezult3}
      if [ "$rezultl2" -eq "0" ]; then echo -e " >>> Yes, it is. <<<"
	if [ ! -d "$builddir" ]; then 
	  if [ "$rebuildex" -ne "1" ]; then sleep "$x1"s; echo -e "\n ... but "'"build"'" directory doesn't exist.\n"; fi; 
	  fun_2 
	else sleep "$x1"s; fun_1; fi
      else echo -e " >>> No, it isn't. <<<\n\n"; fun_3; fi
    else echo -e " >>> No, it isn't. <<<\n\n"; fun_3; fi  
  fi
  sleep "$x1"s
fi
exit 0
