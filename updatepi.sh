#!/bin/bash

# YAD/shell script to install or update certain ham applications, as well as 
# update Raspbian OS and apps.

VERSION="1.40"

if ! which hamapps.sh 1>/dev/null 2>&1
then
   echo "hamapps.sh is not installed.  Exiting."
   sleep 5
   exit 1
fi

APPS=""
TFILE="$(mktemp)"
echo -e "FALSE\nRaspbian OS and Apps\nCheck for Updates" > "$TFILE"
for A in fldigi flmsg flamp flrig flwrap direwolf pat arim piardop2 chirp wsjtx xastir hamapps.sh hampi-iptables autohotspot
do 
	case $A in
		hampi-iptables|autohotspot)
			echo -e "FALSE\n$A\nCheck for Updates" >> "$TFILE" 
			;;
		chirp)
			if which chirpw 1>/dev/null 2>&1
			then
				echo -e "FALSE\n$A\nCheck for Updates" >> "$TFILE" 
			else
				echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
			fi
			;;
		*)
		   if which $A 1>/dev/null 2>&1 
			then
	   		echo -e "FALSE\n$A\nCheck for Updates" >> "$TFILE"
			else
				echo -e "FALSE\n$A\nNew Install" >> "$TFILE"
			fi
			;;
	esac
done

COLUMN=""
for C in $APPS
do
   COLUMN+="FALSE $C "
done

OSUPDATES=NO
ANS="$(yad --title="Update Apps/OS - version $VERSION" --list --height=625 --width=400 --text-align=center \
	--text "<b>This script will install and/or check for and install updates for the apps you select below.\n \
If there are updates available, it will install them.</b>\n\n \
This Pi must be connected to the Internet\nfor this script to work.\n" \
	--separator="," --checklist --column Pick --column Applications --column Action < "$TFILE")"

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
	UPDATES="$(echo "$ANS" | grep Updates | sed 's/^TRUE,//g;s/,Check .*$//g' | tr '\n' ',' | sed 's/,$//')"
	INSTALLS="$(echo "$ANS" | grep Install | sed 's/^TRUE,//g;s/,New .*$//g' | tr '\n' ',' | sed 's/,$//')"
   echo
   if [[ $UPDATES != "" ]]
	then
      echo "Checking for and installing updates for $UPDATES..."
		echo
      $(which hamapps.sh) upgrade $UPDATES
	fi
   echo
   if [[ $INSTALLS != "" ]]
	then
      echo "Installing $INSTALLS..."
		echo
      $(which hamapps.sh) install $INSTALLS
	fi
   echo
   if [[ $OSUPDATES == "YES" ]]
   then
      echo "Checking for regular Raspberry Pi updates..."
		echo
      sudo apt-get update
      sudo apt-get -y upgrade && echo -e "\n\n=========== Raspbian OS Update Finished ==========="
   fi
fi

if [ -a /var/run/reboot-required ]
then 
   yad --title="Update Apps/OS - version $VERSION" --question --borders=30 --no-wrap \
	    --text="<b>Raspbian updates were installed and a reboot is required.</b>" \
	    --button="Reboot Now":0 --button=Close:1
   if [ "$?" -eq "1" ]
   then 
      echo "" && echo "Skipped reboot" && echo ""
      exit 0
   else 
      echo "" && echo "Reboot" && echo"" && sudo shutdown -r +0
   fi
fi 
yad --title="Update Apps/OS - version $VERSION" --info --borders=30 --no-wrap \
	 --text="<b>Finished.  No reboot required.</b>" --button=Close:0
exit 0


