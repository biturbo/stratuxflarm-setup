# Copyright (c) 2018 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.


BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)


if [ $(whoami) != 'root' ]; then
    echo "${BOLD}${RED}This script must be executed as root, exiting...${WHITE}${NORMAL}"
    exit
fi


SCRIPTDIR="`pwd`"

#set -e

#outfile=setuplog
#rm -f $outfile

#exec > >(cat >> $outfile)
#exec 2> >(cat >> $outfile)

#### stdout and stderr to log file
#exec > >(tee -a $outfile >&1)
#exec 2> >(tee -a $outfile >&2)

#### execute the script: bash stratux-setup.sh

#### Revision numbers found via cat /proc/cpuinfo
# [Labeled Section]                                       [File]
# Dependencies                                          - stratux-setup.sh
# Hardware check                                        - stratux-setup.sh
# Setup /etc/hostapd/hostapd.conf                       - wifi-ap.sh
# Edimax WiFi check                                     - stratux-wifi.sh
# Boot config settings                                  - rpi.sh

#
RPI3BxREV=a02082
RPI3ByREV=a22082

REVISION="$(cat /proc/cpuinfo | grep Revision | cut -d ':' -f 2 | xargs)"


# Processor 
# [Labeled Section]                                       [File]
# Go bootstrap compiler installation                    - stratux-setup.sh
#
ARM6L=armv6l
ARM7L=armv7l
ARM64=aarch64

MACHINE="$(uname -m)"


echo "${MAGENTA}"
echo "******************************************"
echo "**** Jessie Setup Starting... *****"
echo "******************************************"
echo "${WHITE}"

if which ntp >/dev/null; then
    ntp -q -g
fi


##############################################################
##  Stop exisiting services
##############################################################
echo
echo "${YELLOW}**** Stop exisiting services... *****${WHITE}"

service stratux stop
echo "${MAGENTA}stratux service stopped...${WHITE}"

if [ -f "/etc/init.d/stratux" ]; then
    # remove old file
    rm -f /etc/init.d/stratux
    echo "/etc/init.d/stratux file found and deleted...${WHITE}"
fi

if [ -f "/etc/init.d/hostapd" ]; then
    service hostapd stop
    echo "${MAGENTA}hostapd service found and stopped...${WHITE}"
fi

if [ -f "/etc/init.d/isc-dhcp-server" ]; then
    service isc-dhcp-server stop
    echo "${MAGENTA}isc-dhcp service found and stopped...${WHITE}"
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  Dependencies
##############################################################
echo
echo "${YELLOW}**** Installing dependencies... *****${WHITE}"

 apt-get install -y rpi-update
 rpi-update

 apt-get purge -y sonic-pi
 apt-get purge -y wolfram-engine
 apt-get remove -y --purge libreoffice*
 apt-get purge -y minecraft-pi
 apt-get remove --purge python-minecraftpi
 apt-get remove -y libpam-chksshpwd
 rm /home/pi/python_games -rf

 apt-get autoremove -y

 apt-get update -y apt-mark hold plymouth
 apt-get dist-upgrade -y
 apt-get upgrade -y
 apt-get install -y git
 git config --global http.sslVerify false
 apt-get install -y iw lshw wget isc-dhcp-server tcpdump cmake libusb-1.0-0.dev build-essential
 apt-get install -y mercurial autoconf fftw3 fftw3-dev libtool automake
 apt-get remove -y hostapd
 apt-get install -y hostapd
 apt-get install -y pkg-config libjpeg-dev i2c-tools python-smbus python-pip python-dev python-pil python-daemon 
 apt-get install -y libconfig-dev libfftw3-dev lynx telnet libjpeg-turbo-progs screen minicom procserv nano
#pip install wiringpi
#apt-get purge golang*
 apt-get upgrade -y
 apt-get autoremove -y

echo "${GREEN}...done${WHITE}"


##############################################################
## Epilogue
##############################################################
echo
echo
echo "${MAGENTA}**** Jessie complete, don't forget to reboot! *****${WHITE}"
echo

echo ${NORMAL}
