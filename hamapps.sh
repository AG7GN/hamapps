#!/bin/bash        
#
# Script Name:    hamapps.sh
# Author:         Steve Magnuson AG7GN
# Date Created:   20180415
#
# Description:    This script will install or update common ham radio 
#                 applications on a Raspberry Pi running the standard Raspbian image.
#                 It has been tested on Buster only.  Use version 1.29 for Stretch.
#
# Usage           hampapps.sh install|upgrade <application(s)>
#                  
#                 Supply one or more of: fldigi,flmsg,flamp,flrig,xastir,direwolf,wsjtx,
#                 piardop,arim,pat,chirp
#                 Separate each app by a comma.
#
#=========================================================================================

VERSION="1.64.4"

GITHUB_URL="https://github.com"
HAMLIB_LATEST_URL="$GITHUB_URL/Hamlib/Hamlib/releases/latest"
FLROOT_URL="http://www.w1hkj.com/files/"
WSJTX_KEY_URL="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB5E1FEF627613D4957BA72885794D54C862549F9"
WSJTX_URL="http://www.physics.princeton.edu/pulsar/k1jt/wsjtx.html"
DIREWOLF_GIT_URL="$GITHUB_URL/wb2osz/direwolf"
DIREWOLF_LATEST="$DIREWOLF_GIT_URL/archive/dev.zip"
#DIREWOLF_LATEST="$DIREWOLF_GIT_URL/releases/latest"
XASTIR_GIT_URL="$GITHUB_URL/Xastir/Xastir.git"
ARIM_URL="https://www.whitemesa.net/arim/arim.html"
GARIM_URL="https://www.whitemesa.net/garim/garim.html"
#PIARDOP_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardopc"
PIARDOP_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardop2"
PAT_GIT_URL="$GITHUB_URL/la5nta/pat/releases"
CHIRP_URL="https://trac.chirp.danplanet.com/chirp_daily/LATEST"
HAMAPPS_GIT_URL="$GITHUB_URL/AG7GN/hamapps"
HAMPIUTILS_GIT_URL="$GITHUB_URL/AG7GN/hampi-utilities"
IPTABLES_GIT_URL="$GITHUB_URL/AG7GN/hampi-iptables"
AUTOHOTSPOT_GIT_URL="$GITHUB_URL/AG7GN/autohotspot"
KENWOOD_GIT_URL="$GITHUB_URL/AG7GN/kenwood"
HAMPI_BU_RS_GIT_URL="$GITHUB_URL/AG7GN/hampi-backup-restore"
PMON_REPO="https://www.scs-ptc.com/repo/packages/"
PMON_GIT_URL="$GITHUB_URL/AG7GN/pmon"

REBOOT="NO"

export CXXFLAGS='-O2 -march=armv8-a -mtune=cortex-a53'
export CFLAGS='-O2 -march=armv8-a -mtune=cortex-a53'
FLDIGI_DEPS_INSTALLED=0

function Usage () {
   echo
   echo "Version $VERSION"
   echo
   echo "This script installs common ham radio applications on a Raspberry Pi"
   echo "It has been tested on Raspbian 10 (Buster) only."
   echo 
   echo "This script does not configure any of the applications it installs."
   echo
   echo "Usage:"
   echo
   echo "$0 install|upgrade <apps>"
   echo 
   echo "Where:"
   echo "   <apps> is one or more apps, separated by comma, from this list:"
   echo "   fldigi,flmsg,flamp,flrig,flwrap,xastir,direwolf,wsjtx,arim,piardop,"
   echo "   pat,chirp,rigctl,hampi-backup-restore,hampi-iptables,autohotspot,710.sh"
   echo
   echo "   Note that if you use \"upgrade\" and the app is not already installed,"
   echo "   this script will install it."
   echo
   echo "   For fldigi and related apps, either \"install\" or \"upgrade\" will"
   echo "   retrieve the latest version and install it if the latest version is"
   echo "   not already installed."
   echo
   echo "   arim is a messaging, file transfer and keyboard-to-keyboard chat"
   echo "   program. It is designed to use the ARDOP (Amateur Radio Digital"
   echo "   Open Protocol) for communication between stations.  Installing"
   echo "   arim will automatically install piardopc, an implementation of"
   echo "   ARDOP for the Raspberry Pi.  garim is the graphical version of"
   echo "   arim.  Requesting an arim install will install both arim and"
   echo "   garim."
   echo
   exit 1
}

function installHamlib () {
   #INSTALLED_VER="None"
   #URL="$(wget -q -O - "$HAMLIB_LATEST_URL" | grep -m1 ".tar.gz\"" | tr -s ' ' '\n' | grep href | cut -d'"' -f2)"
   #[[ $URL == "" ]] && { echo >&2 "======= $HAMLIB_LATEST_URL download failed with $? ========"; exit 1; }
   #HAMLIB_URL="$GITHUB_URL/$URL"
   #cd $HOME
   #HAMLIB_FILE="${HAMLIB_URL##*/}"
   #LATEST_VER="$(echo $HAMLIB_FILE | cut -d- -f2 | sed 's/.tar.gz//')"
   #if which rigctl >/dev/null
   #then
   #   INSTALLED_VER="$($(which rigctl) -V | grep -i " Hamlib [0-9]" | cut -d' ' -f 3)"
   #fi      
   #[[ $INSTALLED_VER == $LATEST_VER ]] && return 1
   #wget -q -O $HAMLIB_FILE $HAMLIB_URL || { echo >&2 "======= $HAMLIB_URL download failed with $? ========"; exit 1; }
   #tar xzf $HAMLIB_FILE
   #HAMLIB_DIR="$(echo $HAMLIB_FILE | sed 's/.tar.gz//')"
   #cd $HAMLIB_DIR
	#echo "=========== Installing/upgrading Hamlib (rigctl) ==========="
	##sudo apt-get remove libhamlib2 -y
	#sudo apt-get install texinfo -y
   #if ./configure && make -j4 && sudo make install && sudo ldconfig
   #then
   #   cd $HOME
   #   rm -rf $HAMLIB_DIR
   #   rm -f $HAMLIB_FILE
   #	echo "=========== Hamlib (rigctl) installed/upgraded ==========="
	#	return 0
   #else
	#	echo >&2 "=========== Hamlib (rigctl) installation FAILED ========="
   #   cd $HOME
   #   exit 1
   #fi
	sudo apt-get -y install libhamlib2 libhamlib-dev 
	return $?
}

function installPiardop () {
   echo "=========== Installing piardop ==========="
   cd $HOME
   PIARDOP_BIN="${PIARDOP_URL##*/}"
   echo "=========== Downloading $PIARDOP_URL ==========="
   wget -q -O $PIARDOP_BIN $PIARDOP_URL || { echo >&2 "======= $PIARDOP_URL download failed with $? ========"; exit 1; }
   chmod +x $PIARDOP_BIN
   sudo mv $PIARDOP_BIN /usr/local/bin/
#	cat > $HOME/.asoundrc << EOF
#pcm.ARDOP {
#type rate
#slave {
#pcm "plughw:1,0"
#rate 48000
#}
#}
#EOF
   echo "=========== piardop installed  ==========="
}

function aptError () {
   echo
   echo
   echo
   echo >&2 "ERROR while running '$1'.  Exiting."
   echo
   echo
   echo
   exit 1
}

#function runInGUI () {
#   if [ -x /usr/bin/lxterminal ]; then
#      /usr/bin/lxterminal -t "Dire Wolf" -e "$1"
#      return 1
#   elif [ -x /usr/bin/xterm ]; then
#      /usr/bin/xterm -bg white -fg black -e "$1"
#      return 1
#   elif [ -x /usr/bin/x-terminal-emulator ]; then
#      /usr/bin/x-terminal-emulator -e "$1"
#      return 1
#   else
#      echo "Did not find an X terminal emulator.  \"$1\" did not run."
#      return 0
#   fi
#}

grep -qi buster /etc/*-release || { echo >&2 "This script only works on Raspbian 10 (Buster)."; Usage; }

case ${1,,} in
   install|upgrade|update)
      ;;
   *)
      Usage
      ;;
esac

[[ $2 == "" ]] && Usage

which wget >/dev/null || { echo >&2 "This script requires wget."; Usage; }
sudo apt-get update
if [[ $? != 0 ]]
then
   echo
   echo
   echo
   echo >&2 "ERROR updating package list while running 'sudo apt-get update'."
   echo
   echo >&2 "This is likely problem with a repository somewhere on the Internet.  Run this script again to retry."
   exit 1
fi
sudo apt-get --fix-broken -y install || aptError "sudo apt-get --fix-broken -y install"
sudo apt-get install -y extra-xdg-menus bc || aptError "sudo apt-get install -y extra-xdg-menus bc"

APPS="$(echo "${2,,}" | tr ',' '\n' | sort -u | xargs)" 

if ! [ -d /usr/local/src/hampi ]
then
	sudo mkdir -p /usr/local/src/hampi
fi	
sudo chown pi:pi /usr/local/src/hampi

for APP in $APPS
do
   case $APP in
      fldigi|flamp|flmsg|flrig|flwrap)
         cd $HOME
         if ls $HOME/.local/share/applications/${APP}*.desktop 1> /dev/null 2>&1
			then
            sed -i 's|\/home\/pi\/trim|\/usr\/local\/bin\/trim|' $HOME/.local/share/applications/${APP}*.desktop
            sudo mv -f $HOME/.local/share/applications/${APP}*.desktop /usr/local/share/applications/
            sudo mv -f $HOME/trim*.sh /usr/local/bin/		  
			fi		  
			if ls $HOME/.local/share/applications/flarq*.desktop 1> /dev/null 2>&1
			then
            sudo mv -f $HOME/.local/share/applications/flarq*.desktop /usr/local/share/applications/
			fi
         FILE=""
         rm -f $APP.list
         echo "========= Downloading ${FLROOT_URL}$APP =========="
         wget -q -O $APP.list ${FLROOT_URL}${APP} || { echo >&2 "======= $APP download failed with $? ========"; exit 1; }
         FILE="$(egrep '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+.tar.gz' $APP.list | tail -1 | cut -d' ' -f2 | cut -d'"' -f2)"
			echo "FILE=$FILE"
         if [[ $FILE != "" ]]
         then
            wget -q -O "$FILE" ${FLROOT_URL}${APP}/${FILE} || { echo >&2 "======= $APP download failed with $? ========"; exit 1; } 
            FNAME="$(echo $FILE | sed 's/.tar.gz//')"
            VERSION="$(echo $FNAME | cut -d'-' -f2)"
            INSTALLED="$($APP --version 2>/dev/null | grep -i "$APP\|^Version" | cut -d' ' -f2)"
            if [[ $VERSION != $INSTALLED ]]
            then
               tar xzf "$FILE"
               if [[ $FLDIGI_DEPS_INSTALLED == "0" ]]
               then
                  echo "========= The $APP app in the fldigi family was requested.  Installing dependencies.  =========="
                  #sed 's/; autospawn = yes/autospawn = no/' < /etc/pulse/client.conf  > $HOME/.config/pulse/client.conf
                  sudo sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list
                  sudo sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list.d/raspi.list
						sudo apt-get update || aptError "sudo apt-get update"
                  sudo apt-get build-dep -y fldigi || aptError "sudo apt-get build-dep -y fldigi"
                  sudo apt-get install -y synaptic pavucontrol libusb-1.0-0-dev libusb-1.0-doc || aptError "sudo apt-get install -y synaptic pavucontrol libusb-1.0-0-dev libusb-1.0-doc"
                  sudo apt-get autoremove -y || aptError "sudo apt-get autoremove -y"
                  installHamlib
                  FLDIGI_DEPS_INSTALLED=1
               fi
               echo "========= $APP dependencies are installed.  =========="
               echo "=========== Installing $FNAME ==========="
                 cd $FNAME
                 if ./configure && make -j4 && sudo make install
                 then
                    cd ..
                    rm -rf $FNAME
						  # Fix the *.desktop files
                    FLDIGI_DESKTOPS="/usr/local/share/applications $HOME/.local/share/applications"
                    for D in ${FLDIGI_DESKTOPS}
						  do
						     for F in $(ls ${D}/fl*.desktop 2>/dev/null)
                       do
							     [ -e "$F" ] || continue
                       	  sudo sed -i 's/Network;//g' $F
                       	  if [[ $F == "${FLDIGI_DESKTOPS}/flrig.desktop" ]]
                          then
                             grep -q "\-\-debug-level 0" ${FLDIGI_DESKTOPS}/flrig.desktop 2>/dev/null || sudo sed -i 's/Exec=flrig/Exec=flrig --debug-level 0/' $F
                          fi
							  done
                    done  
                    [ -f /usr/local/share/applications/${APP}.desktop ] && sudo mv -f /usr/local/share/applications/${APP}.desktop /usr/local/share/applications/${APP}.desktop.disabled
                    [ -f /usr/local/share/applications/flarq.desktop ] && sudo mv -f /usr/local/share/applications/flarq.desktop /usr/local/share/applications/flarq.desktop.disabled
                    lxpanelctl restart
                    echo "========= $FNAME installation done ==========="
                 else
                    echo >&2 "========= $FNAME installation FAILED ========="
                    cd $HOME
                    exit 1
                 fi
            else
               echo "========= $APP is already at latest version $VERSION ========"
            fi
            cd $HOME
            rm -f $FILE
            rm -f $APP.list
         else
            echo >&2 "Unable to retrieve $APP file $FILE"
            exit 1
         fi
         cd $HOME
         ;;
      xastir)
         cd $HOME
         echo "=========== Installing $APP ==========="
			if apt list --installed 2>/dev/null | grep -q xastir
			then
				echo "Removing existing binary that was installed from apt package"
				if [ -d /usr/share/xastir/maps ]
				then
					mkdir -p $HOME/maps
					cp -r /usr/share/xastir/maps/* $HOME/maps
				fi
				sudo apt-get remove -y xastir
				sudo apt-get -y autoremove
				if [ -d $HOME/maps ]
				then
					sudo cp -r $HOME/maps/* /usr/local/share/xastir/maps
					rm -rf $HOME/maps
				fi
				echo "Done."
			fi
			echo "Building $APP from source"
         sudo apt-get install -y build-essential || aptError "sudo apt-get install -y build-essential"
         sudo apt-get install -y git autoconf automake xorg-dev graphicsmagick gv libmotif-dev libcurl4-openssl-dev || aptError "sudo apt-get install -y git autoconf automake xorg-dev graphicsmagick gv libmotif-dev libcurl4-openssl-dev"
         sudo apt-get install -y gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.3-dev python-dev libwebp-dev || aptError "sudo apt-get install -y gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.3-dev python-dev libwebp-dev"
         sudo apt-get install -y shapelib libshp-dev festival festival-dev libgeotiff-dev libgraphicsmagick1-dev || aptError "sudo apt-get install -y shapelib libshp-dev festival festival-dev libgeotiff-dev libgraphicsmagick1-dev"
         sudo apt-get install -y xfonts-100dpi xfonts-75dpi || aptError "sudo apt-get install -y xfonts-100dpi xfonts-75dpi"
			xset +fp /usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi
         cd $HOME
         if [ -d $HOME/src/Xastir ] 
         then
            cd $HOME/src/Xastir
            git pull || { echo >&2 "======= $APP git pull failed with $? ========"; exit 1; }
          else
            mkdir -p $HOME/src
            cd $HOME/src
            git clone $XASTIR_GIT_URL || { echo >&2 "======= $APP git clone failed with $? ========"; exit 1; }
            cd Xastir
         fi
         ./bootstrap.sh
         mkdir -p build
         cd build
         ../configure CPPFLAGS="-I/usr/include/geotiff"
         if make -j4 && sudo make install
         then
            sudo chmod u+s /usr/local/bin/xastir
            cat > $HOME/.local/share/applications/xastir.desktop << EOF
[Desktop Entry]
Name=Xastir
Encoding=UTF-8
GenericName=Xastir
Comment=APRS
Exec=xastir
Icon=/usr/local/share/xastir/symbols/icon.png
Terminal=false
Type=Application
Categories=HamRadio;
EOF
            sudo mv -f $HOME/.local/share/applications/xastir.desktop /usr/local/share/applications/
				sed -i 's|\/usr\/share|\/usr\/local\/share|' $HOME/.xastir/config/xastir.cnf 2>/dev/null
            lxpanelctl restart
            echo "========= $APP installation complete ==========="
         else
            echo "========= $APP installation FAILED ==========="
            cd $HOME
            exit 1
         fi
         cd $HOME
         echo "========= $APP installation complete ==========="
         ;;
      rigctl)
         echo "=========== Installing $APP ==========="
			installHamlib && echo >&2 "=========== $APP installation complete ==========" || { echo >&2 ">>>   Error installing  $APP."; exit 1; }
			sudo apt-get -y install libhamlib-utils
			;;	
      direwolf)
         cd $HOME
			#DIREWOLF_LATEST_VER="$(wget -q -O - $DIREWOLF_LATEST | grep .tar.gz | grep "<a href" | cut -d'"' -f2)"
			#[[ $DIREWOLF_LATEST_VER == "" ]] && { echo >&2 "======= Failed to locate tar.gz file in $DIREWOLF_LATEST ========"; exit 1; }
			#DIREWOLF_LATEST_VER="${GITHUB_URL}${DIREWOLF_LATEST_VER}"
			mkdir -p direwolf
			cd direwolf
			wget -q -O dev.zip $DIREWOLF_LATEST || { echo >&2 "======= $DIREWOLF_LATEST_VER download failed with $? ========"; exit 1; }
			unzip -o dev.zip
			cd $(ls -td dire* | head -1)
			LATEST_VER="$(cat version.h | grep -m1 -i version | sed 's/[^0-9.]//g')"
			INSTALLED_VER="$(direwolf --version 2>/dev/null | grep -m1 -i "version" | sed 's/(.*)//g;s/[^0-9.]//g')"
			[[ $INSTALLED_VER == "" ]] && INSTALLED_VER=0
		   if ls $HOME/.local/share/applications/direwolf*.desktop 1> /dev/null 2>&1
         then
            [ -f /usr/local/share/applications/direwolf.desktop ] && sudo mv -f /usr/local/share/applications/direwolf.desktop /usr/local/share/applications/direwolf.desktop.disabled
            [ -f $HOME/direwolf.conf ] && mv $HOME/direwolf.conf $HOME/direwolf.conf.original
            sed -i 's|\/home\/pi\/d|\/usr\/local\/bin\/d|' $HOME/.local/share/applications/direwolf*.desktop
				sudo mv -f $HOME/.local/share/applications/direwolf*.desktop /usr/local/share/applications/
         fi
			if (( $(echo "$INSTALLED_VER >= $LATEST_VER" | bc -l) ))
			then
				echo "========= Direwolf is already at latest version $LATEST_VER ==========="
				cd ..
				rm -rf $(ls -td dire* | head -1)
				rm dev.zip
			else
				echo "========= Installing/upgrading $APP ==========="
            #mkdir -p $HOME/src
            #cd $HOME/src
				#wget -q -O ${DIREWOLF_LATEST_VER##*/} $DIREWOLF_LATEST_VER || { echo >&2 "======= $DIREWOLF_LATEST_VER download failed with $? ========"; exit 1; }
         	sudo apt-get install -y cmake build-essential libusb-1.0-0-dev libasound2-dev pavucontrol screen gpsd libgps-dev || aptError "sudo apt-get install -y cmake build-essential libusb-1.0-0-dev libasound2-dev pavucontrol screen gpsd libgps-dev"
            installHamlib 
				#tar zxvf ${DIREWOLF_LATEST_VER##*/}
				#cd $(ls -td dire* | head -1)
            #sed -i 's/#CFLAGS += -DUSE_HAMLIB/CFLAGS += -DUSE_HAMLIB/' Makefile.linux
            #sed -i 's/#LDFLAGS += -lhamlib/LDFLAGS += -lhamlib/' Makefile.linux
            if make -j4 && sudo make install
            then
               # Make a default config file if this is a new installation
               [[ ${1,,} == "install" ]] && make install-conf
               make install-rpi
               cd $HOME
               unlink $HOME/Desktop/direwolf.desktop
               [ -f /usr/local/share/applications/direwolf.desktop ] && sudo mv -f /usr/local/share/applications/direwolf.desktop /usr/local/share/applications/direwolf.desktop.disabled
               echo "========= $APP installation complete ==========="
            else
               echo >&2 "========= $APP installation FAILED ==========="
               cd $HOME
               exit 1
            fi
				#cd $HOME/src
				#rm -rf direwolf*/
				#rm -f ${DIREWOLF_LATEST_VER##*/}
				cd $HOME
				rm -f direwolf/dev.zip
         fi
         ;;
      wsjtx)
         echo "======== WSJT-X install/upgrade was requested ========="
			PKG="$(wget -O - -q "$WSJTX_URL" | grep -m1 armhf.deb | cut -d'"' -f2)"
			[[ $PKG =~ "armhf.deb" ]] || { echo >&2 "======= Failed to retrieve wsjtx from $WSJTX_URL ========"; exit 1; }
			URL="$(dirname $WSJTX_URL)/$PKG"
         echo "=========== Retrieving $APP from $URL ==========="
         mkdir -p $HOME/src
         cd $HOME/src
			wget -q $URL || { echo >&2 "======= $URL download failed with $? ========"; exit 1; }
         echo "=========== Installing $APP ==========="
			sudo apt remove -y wsjtx || aptError "sudo apt remove -y wsjtx"
			sudo apt install -y libgfortran3 libqt5multimedia5-plugins libqt5serialport5 libqt5sql5-sqlite libfftw3-single3 || aptError "sudo apt install -y libqt5multimedia5-plugins libqt5serialport5 libqt5sql5-sqlite libfftw3-single3" 
         sudo dpkg -i $PKG || { echo >&2 "======= $PKG install failed with $? ========"; exit 1; }
         sudo sed -i 's/AudioVideo;Audio;//' /usr/share/applications/wsjtx.desktop /usr/share/applications/message_aggregator.desktop 2>/dev/null
         lxpanelctl restart
         echo "========= $APP installation complete ==========="
         ;;
      piardop*)
         installPiardop
         ;;
      arim)
         #which rigctl >/dev/null && return 1 
         echo "======== arim installation requested ==========="
         installPiardop
         for URL in $ARIM_URL $GARIM_URL 
         do
            APP_NAME="$(echo ${URL##*/} | cut -d'.' -f1)"
            ARIM_FILE="${URL##*/}"
            echo "======== Downloading $URL ==========="
            wget -q -O $ARIM_FILE $URL || { echo >&2 "======= $URL download failed with $? ========"; exit 1; }
            TAR_FILE_URL="$(egrep 'https:.*arim.*[[:digit:]]+.tar.gz' $ARIM_FILE | grep -i 'current' | cut -d'"' -f2)"
            [[ $TAR_FILE_URL == "" ]] && { echo >&2 "======= Download failed.  Could not find tar file URL ========"; exit 1; }
            TAR_FILE="${TAR_FILE_URL##*/}"
            FNAME="$(echo $TAR_FILE | sed 's/.tar.gz//')"
            VERSION="$(echo $FNAME | cut -d'-' -f2)"
            INSTALLED="$($APP_NAME -v 2>/dev/null | grep -i "^$APP_NAME" | cut -d' ' -f2)"
            if [[ $VERSION != $INSTALLED ]]
            then
               echo "======== Downloading $TAR_FILE_URL ==========="
               wget -q -O $TAR_FILE $TAR_FILE_URL || { echo >&2 "======= $TAR_FILE_URL download failed with $? ========"; exit 1; }
               if [[ $APP_NAME == "arim" ]]
					then
						sudo apt install -y libncurses5-dev libncursesw5-dev || aptError "sudo apt install -y libncurses5-dev libncursesw5-de"
					else
						sudo apt install -y libfltk1.3-dev || aptError "sudo apt install -y libfltk1.3-dev"
					fi
               tar xzf $TAR_FILE
               ARIM_DIR="$(echo $TAR_FILE | sed 's/.tar.gz//')"
               cd $ARIM_DIR
               if ./configure && make -j4 && sudo make install
               then
						lxpanelctl restart
                  cd $HOME
                  rm -rf $ARIM_DIR
                  rm -f $TAR_FILE
                  echo "=========== $APP_NAME installed ==========="
               else
                  echo >&2 "===========  $APP_NAME installation FAILED ========="
                  cd $HOME
                  exit 1
               fi
            else
               echo "============= $APP_NAME is at latest version $VERSION. ================"
            fi
         done
         ;;
      pat)
         cd $HOME
         echo "============= pat installation requested from $PAT_GIT_URL ============="
         PAT_REL_URL="$(wget -qO - $PAT_GIT_URL | grep -m1 _linux_armhf.deb | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | cut -d'"' -f2)"
         [[ $PAT_REL_URL == "" ]] && { echo >&2 "======= $PAT_GIT_URL download failed with $? ========"; exit 1; }
         #PAT_URL="${GITHUB_URL}${PAT_REL_URL}"
         PAT_URL="${PAT_REL_URL}"
         PAT_FILE="${PAT_URL##*/}"
         echo "============= Downloading $PAT_URL ============="
         wget -q -O $PAT_FILE $PAT_URL || { echo >&2 "======= $PAT_URL download failed with $? ========"; exit 1; }
         [ -s "$PAT_FILE" ] || { echo >&2 "======= $PAT_FILE is empty ========"; exit 1; }
         sudo dpkg -i $PAT_FILE || { echo >&2 "======= pat installation failed with $? ========"; exit 1; }
			rm -f $PAT_FILE
         echo "============= pat installed ============="
         ;;
      hamapps*)
      	echo "============= hamapps install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/hamapps" ] && rm -rf hamapps/
      	git clone $HAMAPPS_GIT_URL || { echo >&2 "======= git clone $HAMAPPS_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(grep -i "^VERSION" $(which hamapps.sh))"
			LATEST_VER="$(grep -i "^VERSION" hamapps/hamapps.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= hamapps are up to date ============="
			else
      		sudo cp -f hamapps/updatepi.desktop /usr/local/share/applications/
      		sudo cp -f hamapps/*.sh /usr/local/bin/
	      	echo "============= hamapps installed =============="
			fi
     		[ -f $HOME/.local/share/applications/updatepi.desktop ] && rm -f $HOME/.local/share/applications/updatepi.desktop
      	rm -rf hamapps/
      	;;
      hampi-utilities)
      	echo "============= hampi-utilities install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/hampi-utilities" ] && rm -rf hamp-utilities/
      	git clone $HAMPIUTILS_GIT_URL || { echo >&2 "======= git clone $HAMPIUTILS_GIT_URL failed ========"; exit 1; }
      	if [ -s /usr/local/src/hampi/hampi-utilities.version ]
			then
				INSTALLED_VER="$(grep -i "^VERSION" /usr/local/src/hampi/hampi-utilities.version)"
			else
			   INSTALLED_VER="NONE"
			fi
			LATEST_VER="$(grep -i "^VERSION" hampi-utilities/hampi-utilities.version)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= hampi-utilities are up to date ============="
			else
      		cp -f hampi-utilities/hampi-utilities.version /usr/local/src/hampi/
      		cp -f hampi-utilities/*.conf /usr/local/src/hampi/
      		sudo cp -f hampi-utilities/*.sh /usr/local/bin/
      		sudo cp -f hampi-utilities/*.py /usr/local/bin/
      		sudo cp -f hampi-utilities/*.desktop /usr/local/share/applications/
      		sudo cp -f hampi-utilities/*.template /usr/local/share/applications/
	      	echo "============= hampi-utilities installed =============="
	     		REBOOT="YES"
			fi
     		rm -rf hampi-utilities/
      	;;
      autohotspot)
      	echo "============= autohotspot install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/autohotspot" ] && rm -rf autohotspot/
      	git clone $AUTOHOTSPOT_GIT_URL || { echo >&2 "======= git clone $AUTOHOTSPOT_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(grep -i "^VERSION" /usr/local/bin/configure-autohotspot.sh)"
			LATEST_VER="$(grep -i "^VERSION" autohotspot/configure-autohotspot.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= autohotspot is up to date ============="
			else
      		sudo cp autohotspot/*.sh /usr/local/bin/
      		sudo cp autohotspot/autohotspot.desktop /usr/local/share/applications/
      		[ -f $HOME/.local/share/applications/autohotspot.desktop ] && rm -f $HOME/.local/share/applications/autohotspot.desktop
	      	echo "============= autohotspot installed =============="
	     		REBOOT="YES"
			fi
      	rm -rf autohotspot/
      	;;
      hampi-backup-restore*)
      	echo "============= hampi-backup-restore install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/hampi-backup-restore" ] && rm -rf hampi-backup-restore/
      	git clone $HAMPI_BU_RS_GIT_URL || { echo >&2 "======= git clone $HAMPI_BU_RS_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(grep -i "^VERSION" /usr/local/bin/hampi-backup-restore.sh)"
			LATEST_VER="$(grep -i "^VERSION" hampi-backup-restore/hampi-backup-restore.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= hampi-backup-restore is up to date ============="
			else
      		sudo cp hampi-backup-restore/hampi-backup-restore.sh /usr/local/bin/
      		sudo cp hampi-backup-restore/hampi-backup-restore.desktop /usr/local/share/applications/
      		[ -f $HOME/.local/share/applications/hampi-backup-restore.desktop ] && rm -f $HOME/.local/share/applications/hampi-backup-restore.desktop
	      	echo "============= hampi-backup-restore installed =============="
	     		REBOOT="YES"
			fi
      	rm -rf hampi-backup-restore/
      	;;
      710*)
      	echo "============= 710.sh install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/kenwood" ] && rm -rf kenwood/
      	git clone $KENWOOD_GIT_URL || { echo >&2 "======= git clone $KENWOOD_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(grep -i "^VERSION" /usr/local/bin/710.sh)"
			LATEST_VER="$(grep -i "^VERSION" kenwood/710.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= 710.sh is up to date ============="
			else
      		sudo cp kenwood/710.sh /usr/local/bin/
	      	echo "============= 710.sh installed =============="
			fi
      	rm -rf kenwood/
      	;;
      hampi-iptables)
      	echo "============= hampi-iptables install/update requested ============="
      	cd $HOME
      	[ -d "$HOME/hampi-iptables" ] && rm -rf hampi-iptables/
      	git clone $IPTABLES_GIT_URL || { echo >&2 "======= git clone $IPTABLES_GIT_URL failed ========"; exit 1; }
     		INSTALLED_VER="$(head -n1 /etc/iptables/rules.v4)"
     		LATEST_VER="$(head -n1 hampi-iptables/rules.v4)"
      	if [ -s /etc/iptables/rules.v4 ] && [[ $INSTALLED_VER == $LATEST_VER ]]
      	then
     			echo "============= hampi-iptables is up to date ============="
			else      			
      		sudo cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.previous
      		sudo cp /etc/iptables/rules.v6 /etc/iptables/rules.v6.previous
      		sudo cp -f hampi-iptables/rules.v? /etc/iptables/
      		sudo iptables-restore < /etc/iptables/rules.v4
      		sudo ip6tables-restore < /etc/iptables/rules.v6
      		echo "============= hampi-iptables installed ================="
      	fi
     		rm -rf hampi-iptables/
      	;;
      chirp*)
         cd $HOME
         echo "============= chirp installation requested ============"
   		if which chirpw >/dev/null
   		then
      		INSTALLED_VER="$($(which chirpw) --version | cut -d' ' -f 2)"
   		fi      
         CHIRP_TAR_FILE="$(wget -qO - $CHIRP_URL | grep "\.tar.gz" | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | cut -d'"' -f2)"
         [[ $CHIRP_TAR_FILE == "" ]] && { echo >&2 "======= $CHIRP_URL download failed with $? ========"; exit 1; }
			LATEST_VER="$(echo $CHIRP_TAR_FILE | sed 's/^chirp-//;s/.tar.gz//')"
			if [[ $LATEST_VER == $INSTALLED_VER ]]
			then
            echo "============= chirp is already at latest version $LATEST_VER. ================"
	 		else
         	CHIRP_URL="${CHIRP_URL}/${CHIRP_TAR_FILE}"
         	echo "============= Downloading $CHIRP_URL ============="
         	wget -q -O $CHIRP_TAR_FILE $CHIRP_URL || { echo >&2 "======= $CHIRP_URL download failed with $? ========"; exit 1; }
         	[ -s "$CHIRP_TAR_FILE" ] || { echo >&2 "======= $CHIRP_TAR_FILE is empty ========"; exit 1; }
         	sudo apt-get install -y python-gtk2 python-serial python-libxml2 python-future || aptError "sudo apt-get install -y python-gtk2 python-serial python-libxml2 python-future"
         	tar xzf $CHIRP_TAR_FILE
         	CHIRP_DIR="$(echo $CHIRP_TAR_FILE | sed 's/.tar.gz//')"
         	cd $CHIRP_DIR
         	sudo python setup.py install
				lxpanelctl restart
         	echo "============= chirp installed ================"
         	cd $HOME
         	sudo rm -rf "$CHIRP_DIR"
			fi
         ;;
      pmon)
         cd $HOME
         echo "============= pmon installation requested ============"
         if grep -q scs-pts /etc/apt/sources.list.d/scs.list 2>/dev/null
         then
            sudo apt install pmon || aptError "sudo apt install pmon"
         else
            echo "deb $PMON_REPO buster non-free" | sudo tee /etc/apt/sources.list.d/scs.list > /dev/null
            wget -q -O - ${PMON_REPO}scs.gpg.key | sudo apt-key add -
            sudo apt update
            sudo apt install pmon || aptError "sudo apt install pmon"
         fi
      	[ -d "$HOME/pmon" ] && rm -rf pmon/
      	git clone $PMON_GIT_URL || { echo >&2 "======= git clone $PMON_GIT_URL failed ========"; exit 1; }
     		INSTALLED_VER="$(grep -i "^VERSION" /usr/local/bin/pmon.sh)"
     		LATEST_VER="$(grep -i "^VERSION" pmon/pmon.sh)"
      	if [ -s /usr/local/bin/pmon.sh ] && [[ $INSTALLED_VER == $LATEST_VER ]]
      	then
     			echo "============= pmon scripts are up to date ============="
			else      			
      		sudo cp pmon/pmon.sh /usr/local/bin/
      		sudo cp pmon/pmon.desktop /usr/local/share/applications/
      		echo "============= pmon and scripts installed ================="
      	fi
     		rm -rf pmon/
     		;;
      *)
         echo "Skipping unknown app \"$APP\"."
         ;;
   esac
done
[[ $REBOOT == "YES" ]] && exit 2 || exit 0


