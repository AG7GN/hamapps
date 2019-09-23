#!/bin/bash

# updatepi-help.sh script

# If a user double-clicks on an app name in the updatepi.sh GUI, the app name is
# passed to this script.  This scriot uses the app name as an array index and then
# locates the URI associated with that app, and launches the $BROWSER to that URI.

VERSION="1.59.1"

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
APPS[hampi-iptables]="https://github.com/AG7GN/hampi-iptables/blob/master/README.md"
APPS[hampi-utilities]="https://github.com/AG7GN/hampi-utilities/blob/master/README.md"
APPS[autohotspot]="https://github.com/AG7GN/autohotspot/blob/master/README.md"
APPS[710.sh]="https://github.com/AG7GN/kenwood/blob/master/README.md"
APP="$(cat -)"
$BROWSER ${APPS[$APP]}
exit 0
