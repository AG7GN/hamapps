#!/bin/bash        
#
# Script Name:    hamapps.sh
# Author:         Steve Magnuson AG7GN
# Date Created:   20180415
#
# Description:    This script will install or update common ham radio 
#                 applications on a Raspberry Pi running the standard Raspbian image.
#                 It has been tested on Buster only.  
#
# Usage           hampapps.sh install|upgrade <application(s)>
#                  
#                 Supply one or more of: fldigi,flmsg,flamp,flrig,xastir,direwolf,wsjtx,
#                 piardop,arim,pat,chirp
#                 Separate each app by a comma.
#
#=========================================================================================

VERSION="1.77.7"

GITHUB_URL="https://github.com"
HAMLIB_LATEST_URL="$GITHUB_URL/Hamlib/Hamlib/releases/latest"
FLROOT_URL="http://www.w1hkj.com/files/"
WSJTX_KEY_URL="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB5E1FEF627613D4957BA72885794D54C862549F9"
WSJTX_URL="http://www.physics.princeton.edu/pulsar/k1jt/wsjtx.html"
DIREWOLF_GIT_URL="$GITHUB_URL/wb2osz/direwolf"
XASTIR_GIT_URL="$GITHUB_URL/Xastir/Xastir.git"
ARIM_URL="https://www.whitemesa.net/arim/arim.html"
GARIM_URL="https://www.whitemesa.net/garim/garim.html"
PIARDOP_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardopc"
PIARDOP2_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardop2"
PAT_GIT_URL="$GITHUB_URL/la5nta/pat/releases"
CHIRP_URL="https://trac.chirp.danplanet.com/chirp_daily/LATEST"
HAMAPPS_GIT_URL="$GITHUB_URL/AG7GN/hamapps"
NEXUSUTILS_GIT_URL="$GITHUB_URL/AG7GN/nexus-utilities"
IPTABLES_GIT_URL="$GITHUB_URL/AG7GN/nexus-iptables"
AUTOHOTSPOT_GIT_URL="$GITHUB_URL/AG7GN/autohotspot"
KENWOOD_GIT_URL="$GITHUB_URL/AG7GN/kenwood"
NEXUS_BU_RS_GIT_URL="$GITHUB_URL/AG7GN/nexus-backup-restore"
PMON_REPO="https://www.scs-ptc.com/repo/packages/"
PMON_GIT_URL="$GITHUB_URL/AG7GN/pmon"
NEXUS_RMSGW_GIT_URL="$GITHUB_URL/AG7GN/rmsgw"
JS8CALL_URL="http://files.js8call.com/latest.html"
FEPI_GIT_URL="$GITHUB_URL/AG7GN/fe-pi"
LINBPQ_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/pilinbpq"
LINBPQ_DOC="http://www.cantab.net/users/john.wiseman/Downloads/Beta/HTMLPages.zip"
REBOOT="NO"
SRC_DIR="/usr/local/src/nexus"
SHARE_DIR="/usr/local/share/nexus"

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
   echo "   pat,linbpq,chirp,rigctl,nexus-backup-restore,nexus-iptables,autohotspot,710.sh"
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
   echo "   arim will automatically install piardopc and piardop2, implementations of"
   echo "   ARDOP versions 1 and 2 for the Raspberry Pi.  garim is the graphical version of"
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
	##sudo apt remove libhamlib2 -y
	#sudo apt install texinfo -y
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
	sudo apt -y install libhamlib2 libhamlib-dev 
	return $?
}

function installPiardop () {
	declare -A ARDOP
	ARDOP[1]="$PIARDOP_URL"
	ARDOP[2]="$PIARDOP2_URL"
  	cd $HOME
	for V in "${!ARDOP[@]}"
	do
   	echo "=========== Installing piardop version $V ==========="
   	PIARDOP_BIN="${ARDOP[$V]##*/}"
   	echo "=========== Downloading ${ARDOP[$V]} ==========="
   	wget -q -O $PIARDOP_BIN "${ARDOP[$V]}" || { echo >&2 "======= ${ARDOP[$V]} download failed with $? ========"; exit 1; }
   	chmod +x $PIARDOP_BIN
   	sudo mv $PIARDOP_BIN /usr/local/bin/
#	    cat > $HOME/.asoundrc << EOF
#pcm.ARDOP {
#type rate
#slave {
#pcm "plughw:1,0"
#rate 48000
#}
#}
#EOF
   	echo "=========== piardop version $V installed  ==========="
   done
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
sudo apt update
if [[ $? != 0 ]]
then
   echo
   echo
   echo
   echo >&2 "ERROR updating package list while running 'sudo apt update'."
   echo
   echo >&2 "This is likely problem with a repository somewhere on the Internet.  Run this script again to retry."
   exit 1
fi
sudo apt-get --fix-broken -y install || aptError "sudo apt-get --fix-broken -y install"
sudo apt install -y extra-xdg-menus bc dnsutils libgtk-3-bin jq moreutils || aptError "Unable to install required packages."

APPS="$(echo "${2,,}" | tr ',' '\n' | sort -u | xargs)" 

# Make nexus source and share folders if necessary
for D in $SRC_DIR $SHARE_DIR
do
	if [[ ! -d $D ]]
	then
		sudo mkdir -p $D
		sudo chown $USER:$USER $D
	fi	
	# Make sure ownership is $USER
	if [[ $(stat -c '%U:%G' $D) != "$USER:$USER" ]]
	then
		sudo chown -R $USER:$USER $D
	fi	
done

# Remove old hampi src folder
sudo rm -rf /usr/local/src/hampi
sudo rm -rf /usr/local/share/hampi

for APP in $APPS
do
   case $APP in
      fldigi|flamp|flmsg|flrig|flwrap)
         cd $HOME
         #if ls $HOME/.local/share/applications/${APP}*.desktop 1> /dev/null 2>&1
			#then
         #   sed -i 's|\/home\/pi\/trim|\/usr\/local\/bin\/trim|' $HOME/.local/share/applications/${APP}*.desktop
         #   sudo mv -f $HOME/.local/share/applications/${APP}*.desktop /usr/local/share/applications/
         #   sudo mv -f $HOME/trim*.sh /usr/local/bin/		  
			#fi		  
			#if ls $HOME/.local/share/applications/flarq*.desktop 1> /dev/null 2>&1
			#then
         #   sudo mv -f $HOME/.local/share/applications/flarq*.desktop /usr/local/share/applications/
			#fi
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
						#sudo apt update || aptError "sudo apt update"
                  sudo apt-get build-dep -y fldigi || aptError "sudo apt-get build-dep -y fldigi"
                  sudo apt install -y synaptic pavucontrol libusb-1.0-0-dev libusb-1.0-doc || aptError "sudo apt install -y synaptic pavucontrol libusb-1.0-0-dev libusb-1.0-doc"
                  sudo apt autoremove -y || aptError "sudo apt autoremove -y"
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
				sudo apt -y remove xastir
				sudo apt -y autoremove
				if [ -d $HOME/maps ]
				then
					sudo cp -r $HOME/maps/* /usr/local/share/xastir/maps
					rm -rf $HOME/maps
				fi
				echo "Done."
			fi
			echo "Building $APP from source"
         sudo apt install -y build-essential || aptError "sudo apt install -y build-essential"
         sudo apt install -y git autoconf automake xorg-dev graphicsmagick gv libmotif-dev libcurl4-openssl-dev || aptError "sudo apt install -y git autoconf automake xorg-dev graphicsmagick gv libmotif-dev libcurl4-openssl-dev"
         sudo apt install -y gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.3-dev python-dev libwebp-dev || aptError "sudo apt install -y gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.3-dev python-dev libwebp-dev"
         sudo apt install -y shapelib libshp-dev festival festival-dev libgeotiff-dev libgraphicsmagick1-dev || aptError "sudo apt install -y shapelib libshp-dev festival festival-dev libgeotiff-dev libgraphicsmagick1-dev"
         sudo apt install -y xfonts-100dpi xfonts-75dpi || aptError "sudo apt install -y xfonts-100dpi xfonts-75dpi"
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
         ;;
      rigctl)
         echo "=========== Installing $APP ==========="
			installHamlib && echo >&2 "=========== $APP installation complete ==========" || { echo >&2 ">>>   Error installing  $APP."; exit 1; }
			sudo apt -y install libhamlib-utils
			;;	
      direwolf)
         cd $HOME
			# Check prerequisites
			sudo apt -y install git gcc g++ make cmake libasound2-dev libudev-dev || aptError "sudo apt -y install git gcc g++ make cmake libasound2-dev libudev-dev"
			rm -rf direwolf
			git clone ${DIREWOLF_GIT_URL} || { echo >&2 "======= git clone $DIREWOLF_GIT_URL failed ========"; exit 1; }
			cd direwolf
			LATEST_VER="$(grep -m1 -i version src/version.h | sed 's/[^0-9.]//g')"
			INSTALLED_VER="$(direwolf --version 2>/dev/null | grep -m1 -i "version" | sed 's/(.*)//g;s/[^0-9.]//g')"
			[[ $INSTALLED_VER == "" || -f /usr/bin/direwolf ]] && INSTALLED_VER=0  # Development versions were installed in /usr/bin
			[ -f /usr/bin/direwolf ] && sudo rm -f /usr/bin/direwolf # Remove older dev version
			#if (( $(echo "$INSTALLED_VER >= $LATEST_VER" | bc -l) ))
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "========= $APP is already at latest version $LATEST_VER ==========="
				cd ..
				rm -rf $(ls -td dire* | head -1)
			else
				echo "========= Installing/upgrading $APP ==========="
         	sudo apt install -y cmake build-essential libusb-1.0-0-dev libasound2-dev pavucontrol screen gpsd libgps-dev || aptError "sudo apt install -y cmake build-essential libusb-1.0-0-dev libasound2-dev pavucontrol screen gpsd libgps-dev"
            installHamlib 
				mkdir build && cd build
            if cmake .. && make -j4 && sudo make install
            then
               # Make a default config file if this is a new installation
               #[[ ${1,,} == "install" ]] && make install-conf && cp direwolf.conf $HOME/direwolf.conf.sample
               make install-conf && cp direwolf.conf $HOME/direwolf.conf.sample
               cd $HOME
               [ -f $HOME/Desktop/direwolf.desktop ] && unlink $HOME/Desktop/direwolf.desktop
               [ -f /usr/local/share/applications/direwolf.desktop ] && sudo mv -f /usr/local/share/applications/direwolf.desktop /usr/local/share/applications/direwolf.desktop.disabled
               echo "========= $APP installation complete ==========="
            else
               echo >&2 "========= $APP installation FAILED ==========="
               cd $HOME
					rm -rf $(ls -td dire* | head -1)
               exit 1
            fi
				cd $HOME
				rm -rf $(ls -td dire* | head -1)
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
      piardop)
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
			LATEST_VER="$(echo $PAT_FILE | cut -d'_' -f2)"
			if command -v pat >/dev/null
			then
				INSTALLED_VER="$(pat version | cut -d' ' -f2 | tr -d [A-Za-z])"
			else
				INSTALLED_VER="NONE"
			fi
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= pat is up to date ============="
			else
         	sudo dpkg -i $PAT_FILE || { echo >&2 "======= pat installation failed with $? ========"; exit 1; }
         	echo "============= pat installed ============="
			fi
			rm -f $PAT_FILE
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
      nexus-utilities)
      	echo "========= nexus-utilities install/update requested ========"
 			VERSION_FILE_URL="https://raw.githubusercontent.com/AG7GN/nexus-utilities/master/nexus-utilities.version"
      	wget -qO /tmp/nexus-utilities.version $VERSION_FILE_URL || { echo >&2 "======= $VERSION_FILE_URL download failed with $? ========"; exit 1; }
      	if [ -s $SRC_DIR/nexus-utilities.version ]
			then
				INSTALLED_VER="$(grep -i "^VERSION" $SRC_DIR/nexus-utilities.version)"
			else
			   INSTALLED_VER="NONE"
			fi
			LATEST_VER="$(grep -i "^VERSION" /tmp/nexus-utilities.version)"
			echo "INSTALLED: $INSTALLED_VER   LATEST: $LATEST_VER"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= nexus-utilities are up to date ============="
			else
				cd $SRC_DIR
      		[ -d "$SRC_DIR/hampi-utilities" ] && rm -rf hampi-utilities/
      		[ -d "$SRC_DIR/nexus-utilities" ] && rm -rf nexus-utilities/
      		git clone $NEXUSUTILS_GIT_URL || { echo >&2 "======= git clone $NEXUSUTILS_GIT_URL failed ========"; exit 1; }
      		sudo chown $USER:$USER nexus-utilities/*
      		chmod +x nexus-utilities/*.sh
      		cp -f nexus-utilities/nexus-utilities.version $SRC_DIR/
      		cp -f nexus-utilities/*.conf $SRC_DIR/
      		cp -f nexus-utilities/*.html $SHARE_DIR/
      		cp -f nexus-utilities/*.jpg $HOME/Pictures/
      		cp -f nexus-utilities/*.example $HOME/
      		sudo cp -f nexus-utilities/*.sh /usr/local/bin/
      		sudo cp -f nexus-utilities/*.py /usr/local/bin/
      		sudo cp -f nexus-utilities/*.desktop /usr/local/share/applications/
      		sudo cp -f nexus-utilities/*.template /usr/local/share/applications/
	     		rm -rf nexus-utilities/
	      	echo "============= nexus-utilities installed =============="
	     		REBOOT="YES"
			fi
     		rm -f /tmp/nexus-utilities.version
      	;;
      fe-pi)
      	echo "========= fe-pi pulseaudio install/update requested ========"
 			VERSION_FILE_URL="https://raw.githubusercontent.com/AG7GN/fe-pi/master/fe-pi.version"
      	wget -qO /tmp/fe-pi.version $VERSION_FILE_URL || { echo >&2 "======= $VERSION_FILE_URL download failed with $? ========"; exit 1; }
      	if [ -s $SRC_DIR/fe-pi.version ]
			then
				INSTALLED_VER="$(grep -i "^VERSION" $SRC_DIR/fe-pi.version)"
			else
			   INSTALLED_VER="NONE"
			fi
			LATEST_VER="$(grep -i "^VERSION" /tmp/fe-pi.version)"
			echo "INSTALLED: $INSTALLED_VER   LATEST: $LATEST_VER"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= fe-pi pulseaudio files are up to date ============="
			else
				cd $SRC_DIR
      		[ -d "$SRC_DIR/fe-pi" ] && rm -rf fe-pi/
      		git clone $FEPI_GIT_URL || { echo >&2 "======= git clone $FEPI_GIT_URL failed ========"; exit 1; }
      		sudo chown $USER:$USER fe-pi/*
      		cp -f fe-pi/fe-pi.version $SRC_DIR/
      		[[ -s /etc/asound.conf ]] && sudo mv /etc/asound.conf /etc/asound.conf.previous
      		sudo cp -f fe-pi/etc/asound.conf /etc/
      		[[ -s /etc/pulse/default.pa ]] && sudo mv /etc/pulse/default.pa /etc/pulse/default.pa.previous
      		sudo cp -f fe-pi/etc/pulse/default.pa /etc/pulse/
	     		rm -rf fe-pi/
	      	echo "============= fe-pi pulseaudio updated =============="
	     		REBOOT="YES"
			fi
	      # Append sound directives to the end of cmdline.txt to restore ALSA sound
	      # interface definitions using the old method (needed for compatibility with Fldigi
	      # alert sounds as well as to retain the ability to switch between HDMI and 
	      # Analog from the Desktop).
	      CMD_STRING="snd-bcm2835.enable_compat_alsa=1 snd-bcm2835.enable_hdmi=0 snd-bcm2835.enable_headphones=0"
			if ! grep -q $CMD_STRING /boot/cmdline.txt 2>/dev/null
     		then
     			sudo sed -i -e "s/$/ $CMD_STRING/" /boot/cmdline.txt
	     		REBOOT="YES"
			fi
     		rm -f /tmp/fe-pi.version
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
      nexus-backup-restore*)
      	echo "============= nexus-backup-restore install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/nexus-backup-restore" ] && rm -rf nexus-backup-restore/
      	git clone $NEXUS_BU_RS_GIT_URL || { echo >&2 "======= git clone $NEXUS_BU_RS_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(grep -i "^VERSION" /usr/local/bin/nexus-backup-restore.sh)"
			LATEST_VER="$(grep -i "^VERSION" nexus-backup-restore/nexus-backup-restore.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= nexus-backup-restore is up to date ============="
			else
				sudo rm -f /usr/local/bin/hampi-backup-restore.sh
      		sudo cp nexus-backup-restore/nexus-backup-restore.sh /usr/local/bin/
      		sudo rm -f /usr/local/share/applications/hampi-backup-restore.desktop
      		sudo cp nexus-backup-restore/nexus-backup-restore.desktop /usr/local/share/applications/
      		[ -f $HOME/.local/share/applications/hampi-backup-restore.desktop ] && rm -f $HOME/.local/share/applications/hampi-backup-restore.desktop
	      	echo "============= nexus-backup-restore installed =============="
	     		REBOOT="YES"
			fi
      	rm -rf nexus-backup-restore/
      	;;
      710*)
      	echo "============= 710.sh install/update requested ========"
      	cd $HOME
      	[ -d "$HOME/kenwood" ] && rm -rf kenwood/
      	git clone $KENWOOD_GIT_URL || { echo >&2 "======= git clone $KENWOOD_GIT_URL failed ========"; exit 1; }
			INSTALLED_VER="$(egrep "^#-.*version" /usr/local/bin/710.sh | tr -s ' ' | cut -d' ' -f4)"
			LATEST_VER="$(grep -i "^VERSION" kenwood/710.sh)"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= 710.sh is up to date ============="
			else
      		sudo cp kenwood/710.sh /usr/local/bin/
      		sudo cp -f kenwood/*.py /usr/local/bin/
	      	echo "============= 710.sh installed =============="
			fi
      	rm -rf kenwood/
      	;;
      nexus-iptables)
      	echo "============= nexus-iptables install/update requested ============="
      	cd $HOME
      	[ -d "$HOME/nexus-iptables" ] && rm -rf nexus-iptables/
      	git clone $IPTABLES_GIT_URL || { echo >&2 "======= git clone $IPTABLES_GIT_URL failed ========"; exit 1; }
     		INSTALLED_VER="$(head -n1 /etc/iptables/rules.v4)"
     		LATEST_VER="$(head -n1 nexus-iptables/rules.v4)"
      	if [ -s /etc/iptables/rules.v4 ] && [[ $INSTALLED_VER == $LATEST_VER ]]
      	then
     			echo "============= nexus-iptables is up to date ============="
			else      			
      		sudo cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.previous
      		sudo cp /etc/iptables/rules.v6 /etc/iptables/rules.v6.previous
      		sudo cp -f nexus-iptables/rules.v? /etc/iptables/
      		sudo iptables-restore < /etc/iptables/rules.v4
      		sudo ip6tables-restore < /etc/iptables/rules.v6
      		echo "============= nexus-iptables installed ================="
      	fi
     		rm -rf nexus-iptables/
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
         	sudo apt install -y python-gtk2 python-serial python-libxml2 python-future || aptError "sudo apt install -y python-gtk2 python-serial python-libxml2 python-future"
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
            #sudo apt update
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
     	nexus-rmsgw)
      	echo "============= nexus-rmsgw install/update requested ========"
			VERSION_FILE_URL="https://raw.githubusercontent.com/AG7GN/rmsgw/master/nexus-rmsgw.version"
      	wget -qO /tmp/nexus-rmsgw.version $VERSION_FILE_URL || { echo >&2 "======= $VERSION_FILE_URL download failed with $? ========"; exit 1; }
      	if [ -s $SRC_DIR/nexus-rmsgw.version ]
			then
				INSTALLED_VER="$(grep -i "^VERSION" $SRC_DIR/nexus-rmsgw.version)"
			else
			   INSTALLED_VER="NONE"
			fi
			LATEST_VER="$(grep -i "^VERSION" /tmp/nexus-rmsgw.version)"
			echo "INSTALLED: $INSTALLED_VER   LATEST: $LATEST_VER"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "============= nexus-rmsgw is up to date ============="
			else
				cd $SRC_DIR
	      	[ -d "$SRC_DIR/rmsgw" ] && rm -rf rmsgw/
				git clone $NEXUS_RMSGW_GIT_URL || { echo >&2 "======= git clone $NEXUS_RMSGW_GIT_URL failed ========"; exit 1; }
				cd rmsgw
				./install-rmsgw.sh
				cp -f nexus-rmsgw.version $SRC_DIR/
	      	echo "============= nexus-utilities installed =============="
			fi
			rm -f /tmp/nexus-rmsgw.version
     		;;
     	js8call)
     		echo "============= $APP install/update requested ========"
			PKG_URL="$(wget -O - -q "$JS8CALL_URL" | grep -m1 ".armhf.deb\"" | tr -s ' ' '\n' | grep href | cut -d'"' -f2)"
			[[ $PKG_URL =~ "armhf.deb" ]] || { echo >&2 "======= Failed to retrieve $APP download URL from $JS8CALL_URL ========"; exit 1; }
         echo "=========== Retrieving $APP from $JS8CALL_URL ==========="
         mkdir -p $SRC_DIR/$APP
         cd $SRC_DIR/$APP
         rm -f *armhf.deb
         PKG="${PKG_URL##*/}"
			wget -q -O $PKG $PKG_URL || { echo >&2 "======= $PKG_URL download failed with $? ========"; exit 1; }
			LATEST_VER="$(dpkg -I $PKG | grep "^ Version:" | cut -d' ' -f3)"
			if dpkg -l js8call >/dev/null 2>&1
			then # $APP is already installed.  Check version. 
				INSTALLED_VER="$(dpkg -s $APP | grep "^Version:" | cut -d' ' -f2)"
				if [[ $INSTALLED_VER == $LATEST_VER ]]
				then # No need to update.  No further action needed for $APP
					echo "============= $APP is installed and up to date ============="
					continue
				else
					echo "============= Installing newer version of $APP ============="
					# Remove old version
					sudo apt remove -y $APP || aptError "sudo apt remove -y $APP"
				fi
			else # $APP not yet installed, so install it.
				echo "============= Installing $APP ============="
			fi
			sudo apt install -y libgfortran3 libqt5multimedia5-plugins libqt5serialport5 libqt5sql5-sqlite libfftw3-single3 || aptError "sudo apt install -y libqt5multimedia5-plugins libqt5serialport5 libqt5sql5-sqlite libfftw3-single3" 
         sudo dpkg -i $PKG || { echo >&2 "======= $PKG install failed with $? ========"; exit 1; }
         sudo sed -i 's/AudioVideo;Audio;//' /usr/share/applications/$APP.desktop 2>/dev/null
         lxpanelctl restart
         echo "========= $APP installation complete ==========="
     		;;
     	linbpq)
         cd $HOME
         echo "============= LinBPQ install/update requested ============"
         wget -q -O pilinbpq $LINBPQ_URL || { echo >&2 "======= $LINBPQ_URL download failed with $? ========"; exit 1; }
			chmod +x pilinbpq
			# LinBPQ documentation recommends installing app and config in $HOME
     	   if [[ -x $HOME/linbpq/linbpq ]]
     	   then # a version of linbpq is already installed
     	   	INSTALLED_VER="$($HOME/linbpq/linbpq -v | grep -i version)"
     	   	LATEST_VER="$($HOME/pilinbpq -v | grep -i version)"
				if [[ $INSTALLED_VER == $LATEST_VER ]]
				then # No need to update.  No further action needed for $APP
					echo "============= $APP is installed and up to date ============="
					rm -f pilinbpq
					continue
				else # New version
					echo "============= Installing newer version of $APP ============="
				fi
			else # No linbpq installed
				echo "============= Installing LinBPQ ============"
			fi		
			mkdir -p $HOME/linbpq/HTML
			mv -f $HOME/pilinbpq $HOME/linbpq/linbpq
			DOC="${LINBPQ_DOC##*/}"
			wget -q -O $DOC $LINBPQ_DOC || { echo >&2 "======= $LINBPQ_DOC download failed with $? ========"; exit 1; }
			unzip -o -d $HOME/linbpq/HTML $DOC || { echo >&2 "======= Failed to unzip $DOC ========"; exit 1; }
			rm -f $DOC
			sudo setcap "CAP_NET_ADMIN=ep CAP_NET_RAW=ep CAP_NET_BIND_SERVICE=ep" $HOME/linbpq/linbpq
     		echo "============= LinBPQ installed ================="
     		;;
      *)
         echo "Skipping unknown app \"$APP\"."
         ;;
   esac
done
[[ $REBOOT == "YES" ]] && exit 2 || exit 0
