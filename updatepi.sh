#!/bin/bash

# YAD/shell script to install or update certain ham applications, as well as 
# update Raspbian OS and apps.

VERSION="1.72.1"

function Help () {
	BROWSER="$(command -v chromium-browser)"
	declare -A APPS
	APPS[fldigi]="http://www.w1hkj.com/FldigiHelp"
	APPS[flmsg]="http://www.w1hkj.com/flmsg-help"
	APPS[flamp]="http://www.w1hkj.com/flamp-help"
	APPS[flrig]="http://www.w1hkj.com/flrig-help"
	APPS[flwrap]="http://www.w1hkj.com/flwrap-help"
	APPS[direwolf]="https://github.com/wb2osz/direwolf"
	APPS[pat]="https://getpat.io/"
	APPS[arim]="https://www.whitemesa.net/arim/arim.html"
	APPS[piardop2]="https://www.whitemesa.net/arim/arim.html"
	APPS[chirp]="https://chirp.danplanet.com/projects/chirp/wiki/Home"
	APPS[wsjtx]="https://physics.princeton.edu/pulsar/K1JT/wsjtx.html"
	APPS[xastir]="http://xastir.org/index.php/Main_Page"
	APPS[hampi-backup-restore.sh]="https://github.com/AG7GN/hampi-backup-restore/blob/master/README.md"
	APPS[hamapps]="https://github.com/AG7GN/hamapps/blob/master/README.md"
	APPS[hampi-iptables]="https://github.com/AG7GN/hampi-iptables/blob/master/README.md"
	APPS[hampi-utilities]="https://github.com/AG7GN/hampi-utilities/blob/master/README.md"
	APPS[autohotspot]="https://github.com/AG7GN/autohotspot/blob/master/README.md"
	APPS[710.sh]="https://github.com/AG7GN/kenwood/blob/master/README.md"
	APPS[pmon]="https://www.p4dragon.com/en/PMON.html"
	APPS[hampi-rmsgw]="https://github.com/AG7GN/rmsgw/blob/master/README.md"
	APP="$2"
	$BROWSER ${APPS[$APP]} &
}
export -f Help

function GenerateTable () {
	# Takes 1 argument:  The first word of the middle button ("Select" or "Unselect")

	ANS="$(yad --center --title="Update Apps/OS - version $VERSION" --list --borders=10 --height=625 --width=480 --text-align=center \
	--text "<b>This script will install and/or check for and install updates for the apps you select below.  \
If there are updates available, it will install them.</b>\n\n \
For information about or help with an app, double-click the app's name.  \
This will open the Pi's web browser.\n\n \
This Pi must be connected to the Internet for this script to work.\n\n \
<b><span color='red'>CLOSE ALL OTHER APPS</span></b> <u>before</u> you click OK.\n" \
--separator="," --checklist --grid-lines=hor \
--dclick-action="bash -c \"Help %s\"" \
--auto-kill --column Pick --column Applications \
--column Action < "$TFILE" --buttons-layout=center --button=Cancel:1 --button="$1 All Installed":2 --button=OK:0)"
}

function GenerateList () {
	# Takes 1 argument:  0 = Pick boxes for installed apps are not checked, 1 = Pick boxes for installed apps are checked.
	TFILE="$(mktemp)"
	declare -a CHECKED
	CHECKED[0]="FALSE"
	CHECKED[1]="TRUE"
	echo -e "${CHECKED[$1]}\nRaspbian OS and Apps\nCheck for Updates" > "$TFILE"
	for A in 710.sh arim autohotspot chirp direwolf fldigi flmsg flamp flrig flwrap hamapps hampi-backup-restore.sh hampi-iptables hampi-utilities hampi-rmsgw pat piardop2 pmon wsjtx xastir 
	do 
		case $A in
			hampi-iptables|autohotspot)
				echo -e "${CHECKED[$1]}\n$A\nInstalled - Check for Updates" >> "$TFILE" 
				;;
			chirp)
				if command -v chirpw 1>/dev/null 2>&1
				then
					echo -e "${CHECKED[$1]}\n$A\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
				fi
				;;
			hampi-utilities)
				if [ -s /usr/local/src/hampi/hampi-utilities.version ]
				then
					echo -e "${CHECKED[$1]}\n$A\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
				fi
				;;
			hampi-rmsgw)
				if [ -s /usr/local/src/hampi/hampi-rmsgw.version ]
				then
					echo -e "${CHECKED[$1]}\n$A\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
				fi
				;;
			hamapps)
				echo -e "FALSE\n$A\nUpdated Automatically" >> "$TFILE"
				;;
			*)
		   	if command -v $A 1>/dev/null 2>&1 
				then
	   			echo -e "${CHECKED[$1]}\n$A\nInstalled - Check for Updates" >> "$TFILE"
				else
					echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
				fi
				;;
		esac
	done
}

REBOOT="NO"
APPS=""
OSUPDATES=NO
GITHUB_URL="https://github.com"
HAMAPPS_GIT_URL="$GITHUB_URL/AG7GN/hamapps"

# Check for Internet connectivity
if ! ping -q -w 1 -c 1 github.com > /dev/null 2>&1
then
   yad --center --title="Update Apps/OS - version $VERSION" --info --borders=30 \
       --text="<b>No Internet connection found.  Check your Internet connection \
and run this script again.</b>" --buttons-layout=center \
       --button=Close:0
   exit 1
fi

# Check for and install hamapps.sh updates
echo "============= Checking for updates to updatepi.sh and hamapps.sh ========"
cd $HOME
[ -d "$HOME/hamapps" ] && rm -rf hamapps/
git clone $HAMAPPS_GIT_URL || { echo >&2 "======= git clone $HAMAPPS_GIT_URL failed ========"; exit 1; }
INSTALLED_VER="$(grep -i "^VERSION" $(which hamapps.sh))"
LATEST_VER="$(grep -i "^VERSION" hamapps/hamapps.sh)"
if [[ $INSTALLED_VER == $LATEST_VER ]]
then
	echo "============= updatepi.sh and hamapps.sh are up to date ============="
else
	sudo cp -f hamapps/updatepi.desktop /usr/local/share/applications/
	sudo cp -f hamapps/*.sh /usr/local/bin/
	[ -f $HOME/.local/share/applications/updatepi.desktop ] && rm -f $HOME/.local/share/applications/updatepi.desktop
  	echo "============= updatepi.sh and hamapps.sh have been updated =============="
  	echo
  	yad --center --title="Update Apps/OS - version $VERSION" --info --borders=30 \
--no-wrap --text="A new version of this script has been installed.\n\nPlease \
run <b>Raspberry > Hamradio > Update Pi and Ham Apps</b> again." --buttons-layout=center \
--button=Close:0
  	exit 0
fi
rm -rf hamapps/

# Move the direwolf scripts to /usr/local/bin if necessary
if ls $HOME/dw-*.sh >/dev/null 2>&1
then
	sudo mv -f $HOME/dw-*.sh /usr/local/bin/
fi

# Check for presence of system LXDE-pi autostart and insert check-piano.sh if not 
# already present
AUTOSTART="/etc/xdg/lxsession/LXDE-pi/autostart"
if [ -s $AUTOSTART ] 
then
	if ! grep -q check-piano.sh $AUTOSTART 2>/dev/null
	then
		sudo sed -i '/@pcmanfm .*/a @bash \/usr\/local\/bin\/check-piano.sh' $AUTOSTART
		REBOOT="YES"
	fi
fi

RESULT=2
# Initially generate app list with pick boxes for installed apps not checked
GenerateList 0
PICKBUTTON="Select"
until [ $RESULT -ne 2 ]
do 
	GenerateTable $PICKBUTTON 
	RESULT="$?"
	if [ $RESULT -eq 2 ]
	then # User clicked "*Select All Installed" button
		case $PICKBUTTON in
			Select)
				# Generate new list with pick box checked for each installed app
				GenerateList 1
				# Change button so user can de-select pick box for all installed apps
				PICKBUTTON="Unselect"
				;;
			Unselect)
				# Generate new list with pick box unchecked for each installed app
				GenerateList 0
				# Change button so user can check all installed apps.
				PICKBUTTON="Select"
				;;
		esac
	fi
done		
	
if [ "$?" -eq "1" ] || [[ $ANS == "" ]]
then 
   echo "Update Cancelled"
	rm "$TFILE"
   exit 0
else
	rm "$TFILE"
   if [[ $ANS =~ Raspbian ]]
   then
      OSUPDATES=YES
		ANS="$(echo "$ANS" | grep -v Raspbian)"
   fi
	UPDATES="$(echo "$ANS" | grep Updates | sed -e 's/^TRUE,//g' -e 's/,Check .*$//g' -e 's/,Installed.*$//g' | tr '\n' ',' | sed 's/,$//')"
	INSTALLS="$(echo "$ANS" | grep "New Install" | sed -e 's/^TRUE,//g' -e 's/,New .*$//g' | tr '\n' ',' | sed 's/,$//')"
   echo
   if [[ $UPDATES != "" ]]
	then
      echo "Looking for updates to $UPDATES..."
		echo
      $(which hamapps.sh) upgrade $UPDATES
      [ $? -eq 2 ] && REBOOT="YES"
	fi
   echo
   if [[ $INSTALLS != "" ]]
	then
      echo "Installing $INSTALLS..."
		echo
      $(which hamapps.sh) install $INSTALLS
      [ $? -eq 2 ] && REBOOT="YES"
	fi
   echo
   if [[ $OSUPDATES == "YES" ]]
   then
      echo "Checking for regular Raspberry Pi updates..."
		echo
      sudo apt update
      sudo apt -y upgrade && echo -e "\n\n=========== Raspbian OS Update Finished ==========="
      # Make sure pulseaudio is not default sound device.  If pulseaudio is updated,
      # it might restore this file and make pulseaudio the default sound interface.
      # So, we make sure every nonempty line is commented out.
      sudo sed -i -e '/^[^#]/ s/^#*/#/' /usr/share/alsa/pulse-alsa.conf
   fi
fi

if [[ $REBOOT == "YES" ]]
then 
   yad --center --title="Update Apps/OS - version $VERSION" --question \
       --borders=30 --no-wrap --text-align=center \
	    --text="<b>Reboot Required</b>\n\n" \
	    --button="Reboot Now":0 --buttons-layout=center --button=Close:1
   if [ "$?" -eq "1" ]
   then 
      echo "" && echo "Skipped reboot" && echo ""
      exit 0
   else 
      echo "" && echo "Reboot" && echo"" && sudo shutdown -r +0
   fi
fi 
yad --center --title="Update Apps/OS - version $VERSION" --info --borders=30 \
    --no-wrap --text-align=center --text="<b>Finished.</b>\n\n" --buttons-layout=center \
--button=Close:0
exit 0