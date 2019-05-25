HOWTO install hamapps.sh
## HOWTO Install hamapps.sh on a Raspberry Pi  

Version: 20190524
Author: Steve Magnuson, AG7GN

### Prerequisites

- Raspberry Pi 3B or 3B+ running Raspbian Stretch (does not work on Compas image)
- Familiarity with Terminal and basic LINUX commands, including sudo

### Download and Install

- Open a terminal and run:

		git clone https://github.com/AG7GN/hamapps-installer  
		cd hamapps-installer 
		chmod +x hamapps.sh
		sudo cp hamapps.sh /usr/local/bin  

### Run		

- Open a terminal and run:

		hamapps.sh  

- Read the instructions.  Installation or upgrade of ham radio applications will take a few minutes or
an hour or so depending on how many and what apps you install/upgrade.  

- From now on, just run `hamapps.sh` in a terminal window to upgrade or 
install ham radio applications.

