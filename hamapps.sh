#!/bin/bash        
#
# Script Name:      hamapps.sh
# Author:         Steve Magnuson AG7GN
# Date Created:   20180415
#
# Description:      This script will install or update common ham radio 
#                  applications on a Raspberry Pi running the standard Raspbian image.
#                  It has been tested on Stretch, but should also work on other versions.
#
# Usage            hampapps.sh install|upgrade <application(s)>
#                  
#                  Supply one or more of: fldigi,flmsg,flamp,flrig,xastir,direwolf,wsjtx,
#                  piardop,arim,pat,chirp
#                  Separate each app by a comma.
#
#===========================================================================================

VERSION="1.20"

GITHUB_URL="https://github.com"
HAMLIB_LATEST_URL="$GITHUB_URL/Hamlib/Hamlib/releases/latest"
FLROOT_URL="http://www.w1hkj.com/files/"
WSJTX_KEY_URL="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB5E1FEF627613D4957BA72885794D54C862549F9"
WSJTX_REPO="deb http://ppa.launchpad.net/ki7mt/wsjtx/ubuntu trusty main"
DIREWOLF_GIT_URL="$GITHUB_URL/wb2osz/direwolf"
DIREWOLF_LATEST="$DIREWOLF_GIT_URL/releases/latest"
DIREWOLF_DESKTOP="/usr/local/share/applications/direwolf.desktop"
XASTIR_GIT_URL="$GITHUB_URL/Xastir/Xastir.git"
XASTIR_DESKTOP="/usr/local/share/applications/xastir.desktop"
ARIM_URL="https://www.whitemesa.net/arim/arim.html"
GARIM_URL="https://www.whitemesa.net/garim/garim.html"
#PIARDOP_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardopc"
PIARDOP_URL="http://www.cantab.net/users/john.wiseman/Downloads/Beta/piardop2"
PAT_GIT_URL="$GITHUB_URL/la5nta/pat/releases"
CHIRP_URL="https://trac.chirp.danplanet.com/chirp_daily/LATEST"

export CXXFLAGS='-O2 -march=armv8-a -mtune=cortex-a53'
export CFLAGS='-O2 -march=armv8-a -mtune=cortex-a53'
FLDIGI_DEPS_INSTALLED=0

function Usage () {
   echo
   echo "Version $VERSION"
   echo
   echo "This script installs common ham radio applications on a Raspberry Pi"
   echo "It has been tested on Raspbian Stretch, but will probably work on other"
   echo "Raspbian versions.  Use caution when running this script on non-Raspbian"
   echo "Raspberry Pis."
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
   echo "   pat,chirp"
   echo
   echo "   Note that if you use \"upgrade\" and the app is not already installed,"
   echo "   this script will install it.  For xastir and direwolf, if you use"
   echo "   \"install\" and the app is already installed, this script will upgrade"
   echo "   the application.  Using \"upgrade\" will not overwrite any existing"
   echo "   direwolf.conf file in your home directory."
   echo
   echo "   For fldigi and related apps, either \"install\" or \"upgrade\" will"
   echo "   retrieve the latest version and install it if the latest version is"
   echo "   not already installed."
   echo
   echo "   For wsjtx, the latest version will be installed from KI7MT's"
   echo "   repository."
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
   INSTALLED_VER="None"
   URL="$(wget -q -O - "$HAMLIB_LATEST_URL" | grep -m1 ".tar.gz\"" | tr -s ' ' '\n' | grep href | cut -d'"' -f2)"
   [[ $URL == "" ]] && { echo >&2 "======= $HAMLIB_LATEST_URL download failed with $? ========"; exit 1; }
   HAMLIB_URL="$GITHUB_URL/$URL"
   cd $HOME
   HAMLIB_FILE="${HAMLIB_URL##*/}"
   LATEST_VER="$(echo $HAMLIB_FILE | cut -d- -f2 | sed 's/.tar.gz//')"
   if which rigctl >/dev/null
   then
      INSTALLED_VER="$($(which rigctl) -V | grep -i " Hamlib [0-9]" | cut -d' ' -f 3)"
   fi      
   [[ $INSTALLED_VER == $LATEST_VER ]] && return 1
   wget -q -O $HAMLIB_FILE $HAMLIB_URL || { echo >&2 "======= $HAMLIB_URL download failed with $? ========"; exit 1; }
   tar xzf $HAMLIB_FILE
   HAMLIB_DIR="$(echo $HAMLIB_FILE | sed 's/.tar.gz//')"
   cd $HAMLIB_DIR
   echo "=========== Installing/upgrading Hamlib ==========="
   if ./configure && make && sudo make install && sudo ldconfig
   then
      cd $HOME
      rm -rf $HAMLIB_DIR
      rm -f $HAMLIB_FILE
      echo "=========== Hamlib installed/upgraded ==========="
   else
      echo >&2 "=========== Hamlib installation FAILED ========="
      cd $HOME
      exit 1
   fi
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

APPS="$(echo "${2,,}" | tr ',' '\n' | sort -u | xargs)" 

for APP in $APPS
do
   case $APP in
      fldigi|flamp|flmsg|flrig|flwrap)
         cd $HOME
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
                  sudo apt-get install -y synaptic pavucontrol
                  #sed 's/; autospawn = yes/autospawn = no/' < /etc/pulse/client.conf  > $HOME/.config/pulse/client.conf
                  sudo sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list
                  sudo sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list.d/raspi.list
                  sudo apt-get update
                  sudo apt-get build-dep -y fldigi
                  sudo apt-get autoremove -y
                  installHamlib
                  FLDIGI_DEPS_INSTALLED=1
               fi
               echo "========= $APP dependencies are installed.  =========="
               echo "=========== Installing $FNAME ==========="
                 cd $FNAME
                 if ./configure && make && sudo make install
               then
                  cd ..
                  rm -rf $FNAME
                  FLDIGI_DESKTOPS="/usr/local/share/applications"
                  for F in $(ls ${FLDIGI_DESKTOPS}/fl*.desktop)
                  do
                     sudo sed -i 's/Network;//g' $F
                     if [[ $F == "${FLDIGI_DESKTOPS}/flrig.desktop" ]]
                     then
                        sudo sed -i 's/Exec=flrig/Exec=flrig --debug-level 0/' $F
                     fi
                  done   
                  lxpanelctl restart
                    echo "========= $FNAME installation done ==========="
               else
                  echo >&2 "========= $FNAME installation FAILED ========="
                  cd $HOME
                  exit 1
               fi
            else
               echo "$APP already current at version $VERSION"
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
         sudo apt-get install -y build-essential
         sudo apt-get install -y git autoconf automake xorg-dev graphicsmagick gv libmotif-dev libcurl4-openssl-dev
         sudo apt-get install -y gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.3-dev python-dev libax25-dev libwebp-dev
         sudo apt-get install -y shapelib libshp-dev festival festival-dev libgeotiff-dev libgraphicsmagick1-dev
         sudo apt-get install -y xfonts-100dpi xfonts-75dpi
         #xset +fp /usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi
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
         if make && sudo make install
         then
            sudo chmod u+s /usr/local/bin/xastir
            if ! [ -s "$XASTIR_DESKTOP" ]
            then
               cat > $HOME/xastir.desktop << EOF
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
               sudo mkdir -p /usr/local/share/applications
               sudo mv $HOME/xastir.desktop $XASTIR_DESKTOP
               lxpanelctl restart
            fi
            echo "========= $APP installation complete ==========="
         else
            echo "========= $APP installation FAILED ==========="
            cd $HOME
            exit 1
         fi
         cd $HOME
         ;;
      direwolf)
         installHamlib 
         cd $HOME
			DIREWOLF_LATEST_VER="$(wget -q -O - $DIREWOLF_LATEST | grep .tar.gz | grep "<a href" | cut -d'"' -f2)"
			[[ $DIREWOLF_LATEST_VER == "" ]] && { echo >&2 "======= Failed to locate tar.gz file in $DIREWOLF_LATEST ========"; exit 1; }
			DIREWOLF_LATEST_VER="${GITHUB_URL}${DIREWOLF_LATEST_VER}"
         echo "=========== Installing $APP ==========="
         sudo apt-get install -y git cmake build-essential libusb-1.0-0-dev libasound2-dev pavucontrol ax25-tools screen
         #sed 's/; autospawn = yes/autospawn = no/' < /etc/pulse/client.conf  > $HOME/.config/pulse/client.conf
			#D="$(ls -td $HOME/src/* | head -1)"; 
			INSTALLED_VER="$(direwolf --version 2>/dev/null | grep -m1 -i "version" | cut -d' ' -f4)"
   		LATEST_VER="$(echo ${DIREWOLF_LATEST_VER##*/} | sed 's/.tar.gz//')"
			if [[ $INSTALLED_VER == $LATEST_VER ]]
			then
				echo "========= Direwolf is already at version $LATEST_VER ==========="
			else
				echo "========= Installing/upgrading direwolf ==========="
            mkdir -p $HOME/src
            cd $HOME/src
				wget -q -O ${DIREWOLF_LATEST_VER##*/} $DIREWOLF_LATEST_VER || { echo >&2 "======= $DIREWOLF_LATEST_VER download failed with $? ========"; exit 1; }
				tar zxvf ${DIREWOLF_LATEST_VER##*/}
				cd $(ls -td dire* | head -1)
            #sed -i 's/#CFLAGS += -DUSE_HAMLIB/CFLAGS += -DUSE_HAMLIB/' Makefile.linux
            #sed -i 's/#LDFLAGS += -lhamlib/LDFLAGS += -lhamlib/' Makefile.linux
            if make && sudo make install
            then
               # Make a default config file if this is a new installation
               [[ ${1,,} == "install" ]] && make install-conf
               make install-rpi
               cd $HOME
               unlink $HOME/Desktop/direwolf.desktop
               if ! [ -s "$DIREWOLF_DESKTOP" ]
               then
                  cat > $HOME/direwolf.desktop << EOF
[Desktop Entry]
Type=Application
Exec=lxterminal -t "Dire Wolf" -e "$(which direwolf)"
Name=Dire Wolf
Comment=APRS Soundcard TNC
Icon=/usr/share/direwolf/dw-icon.png
Path=$HOME
#Terminal=true
Categories=HamRadio;
Keywords=Ham Radio;APRS;Soundcard TNC;KISS;AGWPE;AX.25
EOF
                  sudo mkdir -p /usr/local/share/applications
                  sudo mv $HOME/direwolf.desktop $DIREWOLF_DESKTOP
                  lxpanelctl restart
               fi
               echo "========= $APP installation complete ==========="
            else
               echo >&2 "========= $APP installation FAILED ==========="
               cd $HOME
               exit 1
            fi
         fi
         ;;
      wsjtx)
         echo "======== WSJT-X install/upgrade was requested.  Adding repository if required. ========="
         wget -O - -q "$WSJTX_KEY_URL" | sudo apt-key add - || { echo >&2 "======= $WSJTX_KEY_URL download failed with $? ========"; exit 1; }
         if ! grep -q "$WSJTX_REPO" /etc/apt/sources.list
         then
            sudo apt-get remove -y --purge wsjtx
            sudo apt-get autoremove -y
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            echo "$WSJTX_REPO" | sudo tee --append /etc/apt/sources.list
            sudo apt-get update
         fi
         echo "======== WSJT-X repository ready to go ==========="
         echo "=========== Installing $APP ==========="
         #sudo apt-get install -y wsjtx pavucontrol
         sudo apt-get install -y wsjtx
         #sed 's/; autospawn = yes/autospawn = no/' < /etc/pulse/client.conf  > $HOME/.config/pulse/client.conf
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
               [[ $APP_NAME == "arim" ]] && sudo apt install -y libncurses5-dev libncursesw5-dev || sudo apt install -y libfltk1.3-dev
               tar xzf $TAR_FILE
               ARIM_DIR="$(echo $TAR_FILE | sed 's/.tar.gz//')"
               cd $ARIM_DIR
               if ./configure && make && sudo make install
               then
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
         echo "============= pat installed ============="
         ;;
      chirp)
         cd $HOME
         echo "============= chirp installation requested ============"
         CHIRP_TAR_FILE="$(wget -qO - $CHIRP_URL | grep "\.tar.gz" | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | cut -d'"' -f2)"
         [[ $CHIRP_TAR_FILE == "" ]] && { echo >&2 "======= $CHIRP_URL download failed with $? ========"; exit 1; }
         CHIRP_URL="${CHIRP_URL}/${CHIRP_TAR_FILE}"
         echo "============= Downloading $CHIRP_URL ============="
         wget -q -O $CHIRP_TAR_FILE $CHIRP_URL || { echo >&2 "======= $CHIRP_URL download failed with $? ========"; exit 1; }
         [ -s "$CHIRP_TAR_FILE" ] || { echo >&2 "======= $CHIRP_TAR_FILE is empty ========"; exit 1; }
         sudo apt-get install -y python-gtk2 python-serial python-libxml2
         tar xzf $CHIRP_TAR_FILE
         CHIRP_DIR="$(echo $CHIRP_TAR_FILE | sed 's/.tar.gz//')"
         cd $CHIRP_DIR
         sudo python setup.py install
         echo "============= chirp installed ================"
         cd $HOME
         sudo rm -rf "$CHIRP_DIR"
         ;;
      *)
         echo "Skipping unknown app \"$APP\"."
         ;;
   esac
done


