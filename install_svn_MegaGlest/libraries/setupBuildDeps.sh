#!/bin/bash
#
# Use this script to install build dependencies on a number of Linux platforms
# ----------------------------------------------------------------------------
# Originally written by Mark Vejvoda <mark_vejvoda@hotmail.com>
# Rewritten by Tom Reynolds <tomreyn@megaglest.org>
# Copyright (c) 2012 Mark Vejvoda, Tom Reynolds under GNU GPL v3.0

LANG=C

# Got root?
if [ `id -u`'x' != '0x' ]
then 
	echo 'This script must be run as root (UID 0).' >&2
	exit 1
fi

# install parameter with a view to facilitate the installation of all libraries (with svn) for newbies
if [ "$1" == "--finstall" ]; then svncheck='false';
else svncheck='true'; fi

if [ "$svncheck" == "true" ]; then
	# Do you have the 'svnversion' command?
	if [ `which svnversion`'x' = 'x' ]
	then
		echo 'Could not find "svnversion", please make sure it is installed.' >&2
		echo 'For this purpose you can simply try to run this script again with the parameter "--finstall".' >&2
		exit 1
	fi

	svnversion=`readlink -f $0 | xargs dirname | xargs svnversion`
fi

architecture=`uname -m`

# Is the lsb_release command supported?
if [ `which lsb_release`'x' = 'x' ]
then
	lsb=0
	release='unknown release version';
	
	if [ -e /etc/debian_version ]; then distribution='Debian'; codename=`cat /etc/debian_version`
	elif [ -e /etc/SuSE-release ]; then distribution='SuSE'; codename=`cat /etc/SuSE-release`
	elif [ -e /etc/redhat-release ]; then 
		if [ -e /etc/fedora-release ]; then
			distribution='Fedora'; codename=`cat /etc/fedora-release`
		else 	distribution='Redhat'; codename=`cat /etc/redhat-release`; fi
	elif [ -e /etc/fedora-release ]; then 	distribution='Fedora'; codename=`cat /etc/fedora-release`
	elif [ -e /etc/mandrake-release ]; then distribution='Mandrake'; codename=`cat /etc/mandrake-release`
	else distribution='unknown'; release='unknown'; codename='unknown'; fi
else
	lsb=1

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
	# OpenSuSE 11.4
	#LSB Version:    n/a
	#Distributor ID: SUSE LINUX
	#Description:    openSUSE 11.4 (x86_64)
	#Release:        11.4
	#Codename:       Celadon
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

echo 'We have detected the following system:'
echo ' [ '"$distribution"' ] [ '"$release"' ] [ '"$codename"' ] [ '"$architecture"' ]'
echo ''
echo 'On supported systems, we will now install build dependencies.'
echo ''

# Until this point you may cancel without any modifications applied 
#exit 0


unsupported_distribution () {
	echo 'Unsupported Linux distribution.' >&2
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
	echo 'For now, you may want to take a look at the build hints on the MegaGlest wiki at http://wiki.megaglest.org/'
	echo 'If you can come up with something which works for you, please report back to us, too. Thanks!'
}

unsupported_release () {
	echo 'Unsupported '"$distribution"' release.' >&2
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
	if [ "$installcommand" != '' ]
	then
		echo 'For now, please try this (which works with other '"$distribution"' releases) and report back how it works for you:'
		echo -e $installcommand
		echo 'Thanks!'
	fi
}

error_during_installation () {
	echo 'An error occurred while installing build dependencies.' >&2
	echo ''
	echo 'Please report a bugs at http://bugs.megaglest.org providing the following information:'
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
	echo 'For now, you may want to take a look at the build hints on the MegaGlest wiki at http://wiki.megaglest.org/'
	echo 'If you can come up with something which works for you, please report back to us, too. Thanks!'
}


case $distribution in
	Debian) 
		case $release in
			6.0*)
			# end of life 2014-05-04 (4_May)
				# No libvlc-dev since version (1.1.3) in Debian 6.0/Squeeze is incompatible, no libluajit-5.1-dev because it is not available on Debian 6.0/Squeeze, cf. http://glest.org/glest_board/?topic=8460
				echo ''
				echo 'Highly recommended is upgrade Debian at least to the latest stable version.'
				echo ''
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev'
				$installcommand
				if [ $? != 0 ]; then 
					error_during_installation
					echo ''
					echo 'Be sure to have the squeeze-backports repository installed, it is required for libminiupnpc-dev.'
					exit 1
				fi
				;;
			7.*)
				# echo ''
				# echo 'Highly recommended is upgrade Debian at least to the latest stable version.'
				# echo ''
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
				$installcommand
				if [ $? != 0 ]; then 
					error_during_installation
					echo ''
					echo 'If are you using a stable release frozen e.g. a six months ago or more, then perhaps you should use also the backports repository.'
					exit 1
				fi
				;;
			testing|unstable)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi 
				;;
			*)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libminiupnpc-dev librtmp-dev libgtk2.0-dev libcppunit-dev libvlc-dev'
				unsupported_release
				exit 1
				;;
		esac
		;;

	Ubuntu) 
		case $release in
			10.04)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew1.5-dev libftgl-dev libfribidi-dev libcppunit-dev'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi 
				;;
			12.04|12.10|13.04)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi 
				;;
			*)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
				unsupported_release
				exit 1
				;;
		esac
		;;

	LinuxMint) 
		case $release in
			13|14|15)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi 
				;;
			*)
				installcommand='apt-get install build-essential subversion automake autoconf autogen cmake libsdl1.2-dev libxerces-c2-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libvorbis-dev libwxbase2.8-dev libwxgtk2.8-dev libx11-dev liblua5.1-0-dev libjpeg-dev libpng12-dev libcurl4-gnutls-dev libxml2-dev libircclient-dev libglew-dev libftgl-dev libfribidi-dev libvlc-dev libcppunit-dev'
				unsupported_release
				exit 1
				;;
		esac
		;;

	SuSE|SUSE_LINUX|Opensuse|openSUSE_project) 
		case $release in
			11.2|11.4)
				installcommand='zypper install subversion gcc gcc-c++ automake cmake libSDL-devel libxerces-c-devel MesaGLw-devel freeglut-devel libvorbis-devel wxGTK-devel lua-devel libjpeg-devel libpng14-devel libcurl-devel openal-soft-devel xorg-x11-libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel cppunit-devel'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi 
				;;
			12.2|12.3)
				installcommand='zypper install subversion gcc gcc-c++ automake cmake libSDL-devel libxerces-c-devel Mesa-libGL-devel freeglut-devel libvorbis-devel wxWidgets-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel libcppunit-devel libminiupnpc-devel libjpeg-turbo vlc-devel help2man'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi
				;;
			*)
				installcommand='zypper install subversion gcc gcc-c++ automake cmake libSDL-devel libxerces-c-devel Mesa-libGL-devel freeglut-devel libvorbis-devel wxWidgets-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel libcppunit-devel libminiupnpc-devel libjpeg-turbo vlc-devel help2man'
				unsupported_release
				exit 1
				;;
		esac
		;;

	Fedora) 
		case $release in
			18|19)
				installcommand='yum groupinstall development-tools'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi
				installcommand='yum install subversion automake autoconf autogen cmake SDL-devel xerces-c-devel mesa-libGL-devel mesa-libGLU-devel libvorbis-devel wxBase wxGTK-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel cppunit-devel'
				$installcommand
				if [ $? != 0 ]; then error_during_installation; exit 1; fi
				;;
			*)
				installcommand='yum groupinstall "Development Tools"\n...and then...\nyum install subversion automake autoconf autogen cmake SDL-devel xerces-c-devel mesa-libGL-devel mesa-libGLU-devel libvorbis-devel wxBase wxGTK-devel lua-devel libjpeg-devel libpng-devel libcurl-devel openal-soft-devel libX11-devel libxml2-devel libircclient-devel glew-devel ftgl-devel fribidi-devel cppunit-devel'
				unsupported_release
				exit 1
				;;
		esac
		;;

#	archlinux) 	>	rolling)
#	Redhat)
#	Mandrake|Mandriva)

	*) 
		unsupported_distribution
		exit 1
		;;
esac

echo ''
echo 'Installation of build dependencies complete.'

exit 0
