#!/bin/bash

# YAD/shell script to install or update certain ham applications, as well as 
# update Raspbian OS and apps.

VERSION="1.74.10"

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
	APPS[js8call]="http://js8call.com"
	APP="$2"
	$BROWSER ${APPS[$APP]} 2>/dev/null &
}
export -f Help

function GenerateTable () {
	# Takes 1 argument:  The first word of the middle button ("Select" or "Unselect")

	ANS="$(yad --center --title="Update Apps/OS - version $VERSION" --list --borders=10 --height=600 --width=900 --text-align=center \
	--text "<b>This script will install and/or check for and install updates for the apps you select below.\n \
If there are updates available, it will install them.</b>\n\n \
<b><span color='blue'>For information about or help with an app, double-click the app's name.</span></b>\n \
This will open the Pi's web browser.\n \
This Pi must be connected to the Internet for this script to work.\n\n \
<b><span color='red'>CLOSE ALL OTHER APPS</span></b> <u>before</u> you click OK.\n" \
--separator="," --checklist --grid-lines=hor \
--dclick-action="bash -c \"Help %s\"" \
--auto-kill --column Pick --column Applications --column Description \
--column Action < "$TFILE" --buttons-layout=center --button=Cancel:1 --button="$1 All Installed":2 --button=OK:0)"
}

function GenerateList () {
	# Takes 1 argument:  0 = Pick boxes for installed apps are not checked, 1 = Pick boxes for installed apps are checked.
	TFILE="$(mktemp)"
	declare -a CHECKED
	CHECKED[0]="FALSE"
	CHECKED[1]="TRUE"
	LIST="710.sh arim autohotspot chirp direwolf flamp fldigi flmsg flrig flwrap hamapps hampi-backup-restore.sh hampi-iptables hampi-rmsgw hampi-utilities js8call pat piardop2 pmon wsjtx xastir"
	declare -A DESC
	DESC[710.sh]="Rig Control Script for Kenwood 710/71A"
	DESC[arim]="Amateur Radio Instant Messaging"
	DESC[autohotspot]="Wireless HotSpot on your Pi"
	DESC[chirp]="Radio Programming Tool"
	DESC[direwolf]="Packet Modem/TNC and APRS Encoder/Decoder"
	DESC[flamp]="Amateur Multicast Protocol tool for Fldigi"
	DESC[fldigi]="Fast Light DIGItal Modem"
	DESC[flmsg]="Forms Manager for Fldigi"
	DESC[flrig]="Rig Control for Fldigi"
	DESC[flwrap]="File Encapsulation for Fldigi"
	DESC[hamapps]="Tool for Installing/Updating Apps"
	DESC[hampi-backup-restore.sh]="Backup/Restore Home Folder"
	DESC[hampi-iptables]="Firewall Rules for Hampi Image"
	DESC[hampi-rmsgw]="RMS Gateway software for the Hampi Image"
	DESC[hampi-utilities]="Scripts and Apps for Hampi Image"
	DESC[js8call]="Weak signal keyboard to keyboard messaging using JS8"
	DESC[pat]="Winlink Email Client"
	DESC[piardop2]="Amateur Radio Digital Open Protocol Modem"
	DESC[pmon]="PACTOR Monitoring Utility"
	DESC[wsjtx]="Weak Signal Modes Modem"
	DESC[xastir]="APRS Tracking and Mapping Utility"
	
	echo -e "${CHECKED[$1]}\n<s>Raspbian OS and Apps</s>\n<s>Update Raspbian OS and Apps</s>\n<s>Check for Updates</s>" > "$TFILE"
	for A in $LIST 
	do 
		case $A in
			hampi-iptables|autohotspot)
				echo -e "${CHECKED[$1]}\n$A\n${DESC[$A]}\nInstalled - Check for Updates" >> "$TFILE" 
				;;
			chirp)
				if command -v chirpw 1>/dev/null 2>&1
				then
					echo -e "${CHECKED[$1]}\n$A\n${DESC[$A]}\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\n${DESC[$A]}\nNew Install" >> "$TFILE"
				fi
				;;
			hampi-utilities)
				if [ -s /usr/local/src/hampi/hampi-utilities.version ]
				then
					echo -e "${CHECKED[$1]}\n$A\n${DESC[$A]}\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
				fi
				;;
			hampi-rmsgw)
				if [ -s /usr/local/src/hampi/hampi-rmsgw.version ]
				then
					echo -e "${CHECKED[$1]}\n$A\n${DESC[$A]}\nInstalled - Check for Updates" >> "$TFILE" 
				else
					echo -e "FALSE\n$A\n${DESC[$A]}\nNew Install" >> "$TFILE"
				fi
				;;
			hamapps)
				echo -e "FALSE\n$A\n${DESC[$A]}\nUpdated Automatically" >> "$TFILE"
				;;
			*)
		   	if command -v $A 1>/dev/null 2>&1 
				then
	   			echo -e "${CHECKED[$1]}\n$A\n${DESC[$A]}\nInstalled - Check for Updates" >> "$TFILE"
				else
					echo -e "FALSE\n$A\n${DESC[$A]}\nNew Install" >> "$TFILE"
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

rm -f "$TFILE"
if [ $RESULT -eq "1" ] || [[ $ANS == "" ]]
then 
   echo "Update Cancelled"
   exit 0
else
   if [[ $ANS =~ Raspbian ]]
   then
      OSUPDATES=YES
		ANS="$(echo "$ANS" | grep -v Raspbian)"
   fi
	UPDATES="$(echo "$ANS" | grep Updates | cut -d, -f2 | tr '\n' ',' | sed 's/,$//')"
	INSTALLS="$(echo "$ANS" | grep "New Install" | cut -d, -f2 | tr '\n' ',' | sed 's/,$//')"
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
   	yad --center --title="Update Apps/OS - version $VERSION" --info --borders=30 \
--no-wrap --text-align=center --text="<b>Raspbian OS Updates are temporarily DISABLED due to a kernel bug that affects the Fe-Pi audio board</b>\n\n" \
--buttons-layout=center \
--button=Close:0
		exit 0
      echo "Checking for regular Raspberry Pi OS updates..."
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