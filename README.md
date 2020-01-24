## Hampi: Update Pi and Ham Apps Scripts

Version: 20191012  
Author: Steve Magnuson, AG7GN

These scripts are used to install/update various ham radio applications as well as regular Raspbian Buster updates  

### Prerequisites

- Raspberry Pi 3B or 3B+ running Raspbian Buster ONLY (__does not work on Raspbian Stretch or Compass__)
- Familiarity with Terminal and basic LINUX commands, including sudo

## Download and Install

### Easy Install

The updatepi.sh script, which is run when you run __Raspberry > Hamradio > Update Pi and Ham Apps__, automaticall checks to see if it needs to update itself and related update apps.  If an update is available, it will automatically install it and tell you that an update was applied.  

### Manual Install

Alternatively, you can install these scripts manually as follows:

- Open a terminal and run:

		cd ~
		rm -rf hamapps/
		git clone https://github.com/AG7GN/hamapps  
		sudo cp hamapps/*.sh /usr/local/bin
		sudo cp hamapps/*.desktop /usr/local/share/applications/
		rm -rf hamapps 

## Run

Hamapps.sh is called from updatepi.sh (see "Run from Raspberry Menu" below) when updates or new installs of ham radio applications are requested.  It can also be run directly:  See "Run from Command Line" below.

### Run from Raspberry Menu

- Click __Raspberry > Hamradio > Update Pi and Ham Apps__.
- Check desired applications, click __OK__.

__Note__: Double-clicking an app name will open a browser to a link with information about that app.

### Run from Command Line

- Open a Terminal and run:

		updatepi.sh  

- Read the instructions.  Installation or upgrade of ham radio applications will take a few minutes or
an hour or so depending on how many and what apps you install/upgrade.  

