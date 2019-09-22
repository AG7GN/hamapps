#!/bin/bash        
#
# Script Name:    move-desktops.sh
# Author:         Steve Magnuson AG7GN
# Date Created:   20190914
#
# Description:    This script will move or delete the Hampi-generated desktop files from 
#                 $HOME/.local/share/applications.
#
#=========================================================================================

VERSION="1.0.1"

for APP in fldigi flamp flmsg flrig flwrap flarq
do
   if ls $HOME/.local/share/applications/${APP}*.desktop 1> /dev/null 2>&1
   then
      sed -i 's|\/home\/pi\/trim|\/usr\/local\/bin\/trim|' $HOME/.local/share/applications/${APP}*.desktop
      sudo mv -f $HOME/.local/share/applications/${APP}*.desktop /usr/local/share/applications/
      sudo mv -f $HOME/trim*.sh /usr/local/bin/		  
	fi		 
done

if [ -f $HOME/.local/share/applications/xastir.desktop ]
then
   sudo mv -f $HOME/.local/share/applications/xastir.desktop /usr/local/share/applications/
fi

if ls $HOME/.local/share/applications/direwolf*.desktop 1> /dev/null 2>&1
then
   sed -i 's|\/home\/pi\/d|\/usr\/local\/bin\/d|' $HOME/.local/share/applications/direwolf*.desktop
	sudo mv -f $HOME/.local/share/applications/direwolf*.desktop /usr/local/share/applications/
fi         

[ -f $HOME/.local/share/applications/updatepi.desktop ] && rm -f $HOME/.local/share/applications/updatepi.desktop
[ -f $HOME/.local/share/applications/autohotspot.desktop ] && rm -f $HOME/.local/share/applications/autohotspot.desktop
[ -f $HOME/.local/share/applications/hampi-backup-restore.desktop ] && rm -f $HOME/.local/share/applications/hampi-backup-restore.desktop
