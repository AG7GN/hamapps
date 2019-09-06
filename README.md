## Scripts to install/update various ham radio applications as well as regular Raspbian Buster updates  

Version: 20190904  
Author: Steve Magnuson, AG7GN

### Prerequisites

- Raspberry Pi 3B or 3B+ running Raspbian Buster ONLY (__does not work on Raspbian Stretch or Compass__)
- Familiarity with Terminal and basic LINUX commands, including sudo

### Release Notes

- Added `sudo --fix-broken install` command to hamapps.sh to fix a problem with fortran packages that accompany the wsjtx installation.
- Moved autohotspot script install location to /usr/local/bin
- Added hampi-backup-restore.sh

## Download and Install

- Open a terminal and run:

		cd ~
		rm -rf hamapps 
		git clone https://github.com/AG7GN/hamapps  
		sudo cp hamapps/*.sh /usr/local/bin
		rm -rf hamapps 

## Run

Hamapps.sh is called from updatepi.sh (see "Run from Raspberry Menu" below) when updates or new installs of ham radio applications are requested.  It can also be run directly:  See "Run from Command Line" below.

### Run from Raspberry Menu

- Click __Raspberry > Hamradio > Update Pi and Ham Apps__.
- Check desired applications, click __OK__.

### Run from Command Line

- Open a Terminal and run:

		updatepi.sh  

- Read the instructions.  Installation or upgrade of ham radio applications will take a few minutes or
an hour or so depending on how many and what apps you install/upgrade.  

- From now on, just run `hamapps.sh` in a terminal window to upgrade or 
install ham radio applications.
