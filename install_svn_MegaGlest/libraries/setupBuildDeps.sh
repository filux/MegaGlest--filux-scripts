#!/bin/bash
#
# Use this script to install build dependencies on a number of Linux platforms
# ----------------------------------------------------------------------------
# Originally written by Mark Vejvoda <mark_vejvoda@hotmail.com>
# Rewritten by Tom Reynolds <tomreyn@megaglest.org>
# ...and then little rewritten by filux <heross(@@)o2.pl>
# Copyright (c) 2012 Mark Vejvoda, Tom Reynolds under GNU GPL v3.0
LANG=C

# Got root?
if [ `id -u`'x' != '0x' ]; then echo 'This script must be run as root (UID 0).' >&2; exit 9; fi

# install parameter with a view to facilitate the installation of all libraries (with svn) for newbies
if [ "$1" == "--finstall" ]; then 
	svncheck='false'
else 	svncheck='true'; fi

if [ "$svncheck" == "true" ]; then
	# Do you have the 'svnversion' command?
	if [ `which svnversion`'x' = 'x' ]; then
		echo ''; echo 'Could not find "svnversion", please make sure it is installed.' >&2
		echo 'For this purpose you can simply try to run this script again with the parameter "--finstall".' >&2
		exit 8
	fi

	svnversion=`readlink -f $0 | xargs dirname | xargs svnversion`
fi

architecture=`uname -m`
if [ "$architecture" == "x86_64" ]; then
# ArchLN1 > "PCLinuxOS/Mageia/(Mandrake)" style, ArchLN2 > "Chakra/(Arch)" style
	ArchLN1="64"; ArchLN2="";
else 	ArchLN1=""; ArchLN2="lib32-"; fi

# Is the lsb_release command supported?
if [ `which lsb_release`'x' = 'x' ]; then
	lsb='false'
	
	if [ -e "/etc/os-release" ]; then
		distribution=`awk -F "=" '/^ID/ {print $2}' /etc/os-release | awk '{ gsub("\"|\t",""); print }' | awk '{ gsub(" |\t","_"); print }'`
		codename=`awk -F "=" '/PRETTY_NAME/ {print $2}' /etc/os-release | awk '{ gsub("\"|\t",""); print }'`
		release_ver=`awk -F "=" '/VERSION_ID/ {print $2}' /etc/os-release | awk '{ gsub("\"|\t",""); print }'`
		if [ "$release_ver" != "" ]; then release="$release_ver"; else release="unknown"; fi
	else
		distribution='unknown'; codename='unknown'; release='unknown'
	fi
else
	lsb='true'

	# lsb_release output by example:
        #
	# $ lsb_release -i
	# Distributor ID:       Ubuntu
	#
	# $ lsb_release -d
	# Description:  Ubuntu 12.04 LTS
	#
	# $ lsb_release -r
	# Release:      12.04
	#
	# $ lsb_release -c
	# Codename:     precise

	distribution=`lsb_release -i | awk -F':' '{ gsub(/^[ \t]*/,"",$2); print $2 }' | awk '{ gsub(" |\t","_"); print }'`
	release=`lsb_release -r | awk -F':' '{ gsub(/^[  \t]*/,"",$2); print $2 }'`
	codename=`lsb_release -c | awk -F':' '{ gsub(/^[ \t]*/,"",$2); print $2 }'`

	# Some distribution examples:
	#
	# OpenSuSE 12.1
	#LSB support:  1
	#Distribution: SUSE LINUX
	#Release:      12.1
	#Codename:     Asparagus
	#
	# OpenSuSE 12.3
	#LSB support:  1
	#Distribution: openSUSE project
	#Release:      12.3
	#Codename:     Dartmouth
	#
	# Arch
	#LSB Version:    n/a
	#Distributor ID: archlinux
	#Description:    Arch Linux
	#Release:        rolling
	#Codename:       n/a
	#
	# Ubuntu 12.04
	#Distributor ID: Ubuntu
	#Description:	 Ubuntu 12.04 LTS
	#Release:	 12.04
	#Codename:	 precise
fi

echo ' We have detected the following system:'
echo " [ $distribution ] [ $release ] [ $codename ] [ $architecture ]"
echo ''
echo ' On supported systems, we will now install build dependencies.'
echo ''

unsupported_error_common () {
	echo ''
	echo 'Please report a bug at http://bugs.megaglest.org providing the following information:'
	echo '--- snip ---'
	if [ "$svncheck" == "true" ]; then
		echo 'SVN version:  '"$svnversion"
	else    echo 'SVN version:  unknown'
	fi
	echo 'LSB support:  '"$lsb"
	echo 'Distribution: '"$distribution"
	echo 'Release:      '"$release"
	echo 'Codename:     '"$codename"
	echo 'Architecture: '"$architecture"
	echo '--- snip ---'
	echo ''
}

unsupported_distribution () {
	echo 'Unsupported Linux distribution.' >&2
	unsupported_error_common
	echo 'For now, you may want to take a look at the build hints on the MegaGlest wiki at http://wiki.megaglest.org/'
	echo 'If you can come up with something which works for you, please report back to us, on the forum https://forum.megaglest.org as a bug report. Thanks!'
	
	exit 1
}

unsupported_release () {
	echo 'Unsupported '"$distribution"' release.' >&2
	unsupported_error_common
	if [ "$installcommand" != '' ]; then
		echo 'For now, please try this (which works with other '"$distribution"' releases):'
		echo -e "$installcommand"
		echo '...and please report back to us, how it works for you, on the forum https://forum.megaglest.org as a bug report. Thanks!'
	fi
	
	exit 2
}

error_during_installation () {
	echo 'An error occurred while installing build dependencies.' >&2
	unsupported_error_common
	echo 'For now, you may want to take a look at the build hints on the MegaGlest wiki at http://wiki.megaglest.org/'
	echo 'If you can come up with something which works for you, please report back to us, on the forum https://forum.megaglest.org as a bug report. Thanks!'
	
	exit 3
}


case $distribution in
#	lsb_release|os-release)
	
	Debian|debian)
		apt-get update; echo ""
		LatestInstallCommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
		
		case $release in
			6.*)
			# end of life 2014-05-04 (4_May)
				# No libvlc-dev since version (1.1.3) in Debian 6.0/Squeeze is incompatible, no libluajit-5.1-dev because it is not available on Debian 6.0/Squeeze, cf. http://glest.org/glest_board/?topic=8460
				echo ''
				echo 'Highly recommended is upgrade Debian at least to the latest stable version.'
				echo ''
				
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev'
				$installcommand
				if [ "$?" != "0" ]; then 
					error_during_installation
					echo ''
					echo 'Be sure to have the squeeze-backports repository installed, it is required for libminiupnpc-dev.'
				fi
				;;
			7.*)
				# echo ''
				# echo 'Highly recommended is upgrade Debian at least to the latest stable version.'
				# echo ''
				
				# installcommand="apt-get install ..."
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
				$installcommand
				if [ "$?" != "0" ]; then 
					error_during_installation
					echo ''
					echo 'If you are using a stable release frozen e.g. a six months ago or more, then perhaps you should use also the backports repository.'
				fi
				;;
			testing|unstable)
				installcommand="$LatestInstallCommand"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			*)
				installcommand="$LatestInstallCommand"
				unsupported_release
				;;
		esac
		;;

	Ubuntu|ubuntu)
		apt-get update; echo ""
		LatestInstallCommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
		
		case $release in
			10.04)
			# LTS
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew1.5-dev libftgl-dev libfribidi-dev libcppunit-dev'
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			12.04|12.10|13.04)
				# installcommand="apt-get install ..."
				installcommand="$LatestInstallCommand"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			*)
				installcommand="$LatestInstallCommand"
				unsupported_release
				;;
		esac
		;;

	LinuxMint|linuxmint)
		apt-get update; echo ""
		LICbasedonubuntu='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
		
		# latest debian testing/unstable libs
		LICbesedondebian='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
				
		case $release in
			1)
			# LMDE -> Linux Mint Debian Edition
				# installcommand="apt-get install ... based on Debian testing"
				installcommand="$LICbesedondebian"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			
			13|14|15)
				# installcommand="apt-get install ... based on ubuntu"
				installcommand="$LICbasedonubuntu"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			*)
				
				installcommand="If you are using a distribution based on Ubuntu try:\n$LICbasedonubuntu\n\n...or if you are using a distribution based on Debian try:\n$LICbesedondebian"
				unsupported_release
				;;
		esac
		;;

	SuSE|SUSE_LINUX|Opensuse|openSUSE_project|opensuse)
		zypper refresh; echo ""
		LatestInstallCommand='zypper install subversion gcc gcc-c++ automake cmake libSDL-devel libxerces-c-devel Mesa-libGL-devel freeglut-devel libvorbis-devel wxWidgets-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel libcppunit-devel libminiupnpc-devel libjpeg-turbo vlc-devel help2man'

		case $release in
			11.2|11.4)
			# LTS
				installcommand='zypper install subversion gcc gcc-c++ automake cmake libSDL-devel libxerces-c-devel MesaGLw-devel freeglut-devel libvorbis-devel wxGTK-devel lua-devel libjpeg-devel libpng14-devel libcurl-devel openal-soft-devel xorg-x11-libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel cppunit-devel'
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi 
				;;
			12.2|12.3)
				# installcommand="zypper install ..."
				installcommand="$LatestInstallCommand"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi
				;;
			*)
				installcommand="$LatestInstallCommand"
				unsupported_release
				;;
		esac
		;;

	Fedora|fedora)
		yum check-update; echo ""
		LatestInstallCommand1='yum groupinstall development-tools'
		LatestInstallCommand2='yum install subversion automake autoconf autogen cmake SDL-devel xerces-c-devel mesa-libGL-devel mesa-libGLU-devel libvorbis-devel wxBase wxGTK-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel cppunit-devel'
		
		case $release in
			18|19)
				# installcommand="yum groupinstall ..."
				installcommand="$LatestInstallCommand1"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi
				
				# installcommand="yum install ..."
				installcommand="$LatestInstallCommand2"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi
				;;
			*)
				installcommand="$LatestInstallCommand1\n... and then ...\n$LatestInstallCommand2"
				unsupported_release
				;;
		esac
		;;

	PCLinuxOS|pclinuxos)
		apt-get update; echo ""
		LatestInstallCommand="apt-get install subversion gcc gcc-c++ automake cmake lib"$ArchLN1"SDL-devel lib"$ArchLN1"xerces-c-devel mesa-common-devel lib"$ArchLN1"freeglut-devel libvorbis-devel lib"$ArchLN1"wxgtk2.8-devel lua-static-devel lib"$ArchLN1"jpeg-static-devel lib"$ArchLN1"png-static-devel lib"$ArchLN1"curl-devel lib"$ArchLN1"openal-devel lib"$ArchLN1"x11-static-devel lib"$ArchLN1"xml2-devel lib"$ArchLN1"ircclient-devel lib"$ArchLN1"glew-devel lib"$ArchLN1"ftgl-devel lib"$ArchLN1"fribidi-static-devel lib"$ArchLN1"cppunit-devel lib"$ArchLN1"miniupnpc-devel vlc-devel help2man"
		
		case $release in
			2013*)
				# installcommand="apt-get install ..."
				installcommand="$LatestInstallCommand"
				$installcommand
				if [ "$?" != "0" ]; then error_during_installation; fi
				;;
			*)
				installcommand="$LatestInstallCommand"
				unsupported_release
				;;
		esac
		;;

#	Chakra|chakra) (& prob. Arch) doesn't like MegaGlest because just hate GTK > wxGTK, wxWidgets

#	V distributions that may be worth do test and maybe taking into consideration (future release) in ~mid-2014+ V
#	Mageia|mageia) based on ~Mandrake
#	Sabayon\sabayon) based on ~Gentoo
#	Korora|korora) based on ~Fedora

	*) 
		unsupported_distribution
		;;
esac

echo ''
echo 'Installation of build dependencies complete.'

exit 0
