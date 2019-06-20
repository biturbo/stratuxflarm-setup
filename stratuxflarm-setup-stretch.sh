# Copyright (c) 2019 Serge Guex
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

#### execute the script: bash stratux-setup.sh

echo "${MAGENTA}"
echo "******************************************"
echo "**** Stratux FLARM Setup Starting... *****"
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

systemctl start ntp
service stratux stop
systemctl enable isc-dhcp-server
systemctl enable ssh
systemctl disable ntp
systemctl disable dhcpcd
systemctl disable hciuart

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

apt install --yes rpi-update
rpi-update

apt update
apt dist-upgrade --yes
apt upgrade --yes
apt remove --yes hostapd
apt purge --yes hostapd

apt install --yes git iw wget lshw tcpdump cmake isc-dhcp-server libusb-1.0-0.dev automake pkg-config \
	libjpeg-dev python-pip libconfig-dev libfftw3-dev lynx telnet libjpeg-turbo-progs \
	libconfig9 hostapd isc-dhcp-server tcpdump git cmake \
    libusb-1.0-0.dev build-essential mercurial autoconf libfftw3-3 libfftw3-dev libtool i2c-tools python-smbus \
    python-pip screen libconfig-dev python-dev python-pil python-daemon #libjpeg8-dev libjpeg62-turbo-dev  

apt upgrade --yes
apt autoremove --yes
apt clean

echo "${GREEN}...done${WHITE}"

##############################################################
##  wiringpi
##############################################################
echo
echo "${YELLOW}**** Prepare wiringpi for fancontrol and some more tools... *****${WHITE}"

cd ../..
# Prepare wiringpi for fancontrol and some more tools
cd /root && git clone https://github.com/WiringPi/WiringPi.git && cd WiringPi/wiringPi && make && make install

ldconfig


cd /root/stratux
cp image/bashrc.txt /root/.bashrc
source /root/.bashrc

echo "${GREEN}...done${WHITE}"


##############################################################
##  Hardware check
##############################################################
#echo
echo "${YELLOW}**** Hardware check... *****${WHITE}"



echo "${GREEN}...done${WHITE}"


##############################################################
##  SSH setup and config
##############################################################
#echo
#echo "${YELLOW}**** SSH setup and config... *****${WHITE}"

#if [ ! -d /etc/ssh/authorized_keys ]; then
#    mkdir -p /etc/ssh/authorized_keys
#fi

#cp -n /etc/ssh/authorized_keys/root{,.bak}
#cp -f ${SCRIPTDIR}/files/root /etc/ssh/authorized_keys/root
#chown root.root /etc/ssh/authorized_keys/root
#chmod 644 /etc/ssh/authorized_keys/root

#cp -n /etc/ssh/sshd_config{,.bak}
#cp -f ${SCRIPTDIR}/files/sshd_config /etc/ssh/sshd_config
#rm -f /usr/share/dbus-1/system-services/fi.epitest.hostap.WPASupplicant.service

#echo "${GREEN}...done${WHITE}"


##############################################################
##  Hardware blacklisting
##############################################################
echo
echo "${YELLOW}**** Hardware blacklisting... *****${WHITE}"

if ! grep -q "blacklist dvb_usb_rtl28xxu" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist dvb_usb_rtl28xxu >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist e4000" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist e4000 >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist rtl2832" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist rtl2832 >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi

if ! grep -q "blacklist dvb_usb_rtl2832u" "/etc/modprobe.d/rtl-sdr-blacklist.conf"; then
    echo blacklist dvb_usb_rtl2832u >>/etc/modprobe.d/rtl-sdr-blacklist.conf
fi


##############################################################
##  Go environment setup
##############################################################
echo
echo "${YELLOW}**** Go environment setup... *****${WHITE}"

# if any of the following environment variables are set in .bashrc delete them
if grep -q "export GOROOT_BOOTSTRAP=" "/root/.bashrc"; then
    line=$(grep -n 'GOROOT_BOOTSTRAP=' /root/.bashrc | awk -F':' '{print $1}')d
    sed -i $line /root/.bashrc
fi

if grep -q "export GOPATH=" "/root/.bashrc"; then
    line=$(grep -n 'GOPATH=' /root/.bashrc | awk -F':' '{print $1}')d
    sed -i $line /root/.bashrc
fi

if grep -q "export GOROOT=" "/root/.bashrc"; then
    line=$(grep -n 'GOROOT=' /root/.bashrc | awk -F':' '{print $1}')d
    sed -i $line /root/.bashrc
fi

if grep -q "export PATH=" "/root/.bashrc"; then
    line=$(grep -n 'PATH=' /root/.bashrc | awk -F':' '{print $1}')d
    sed -i $line /root/.bashrc
fi

# only add new paths
XPATH="\$PATH"
if [[ ! "$PATH" =~ "/root/go/bin" ]]; then
    XPATH+=:/root/go/bin
fi

if [[ ! "$PATH" =~ "/root/go_path/bin" ]]; then
    XPATH+=:/root/go_path/bin
fi

echo export GOROOT_BOOTSTRAP=/root/gobootstrap >>/root/.bashrc
echo export GOPATH=/root/go_path >>/root/.bashrc
echo export GOROOT=/root/go >>/root/.bashrc
echo export PATH=${XPATH} >>/root/.bashrc

export GOROOT_BOOTSTRAP=/root/gobootstrap
export GOPATH=/root/go_path
export GOROOT=/root/go
export PATH=${PATH}:/root/go/bin:/root/go_path/bin

source /root/.bashrc

echo "${GREEN}...done${WHITE}"


##############################################################
##  Go bootstrap compiler installation
##############################################################
echo
echo "${YELLOW}**** Go bootstrap compiler installtion... *****${WHITE}"

cd /root

rm -rf go/
rm -rf gobootstrap/

cd root
wget https://dl.google.com/go/go1.12.4.linux-armv6l.tar.gz
tar xzf go1.12.4.linux-armv6l.tar.gz
rm go1.12.4.linux-armv6l.tar.gz


echo "${GREEN}...done${WHITE}"


##############################################################
##  RTL-SDR tools build
##############################################################
echo
echo "${YELLOW}**** RTL-SDR library build... *****${WHITE}"

rm -rf /root/librtlsdr
git clone https://github.com/jpoirier/librtlsdr /root/librtlsdr
mkdir -p /root/librtlsdr/build
cd /root/librtlsdr/build && cmake .. && make && make install && ldconfig


echo "${GREEN}...done${WHITE}"

##############################################################
##  Stratux build and installation
##############################################################
echo
echo "${YELLOW}**** Stratux build and installation... *****${WHITE}"

cd /
rm -Rf /root/stratux

export GOMAXPROCS=1

#cd && git clone https://github.com/0x74-0x62/stratux.git && cd stratux && git checkout remotes/origin/devel/flarm_receiver && make && make install
cd && git clone https://github.com/biturbo/stratux.git && cd stratux && make && make install
#cd && git clone https://github.com/TomBric/stratux.git && cd stratux && make && make install

echo "${GREEN}...done${WHITE}"


##############################################################
##  OGN install and settings
##############################################################
echo
echo "${YELLOW}**** OGN config... *****${WHITE}"

cd /root/stratux/ogn
rm -rf rtlsdr-ogn-bin-ARM-latest.tgz

wget http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
tar xvzf rtlsdr-ogn-bin-ARM-latest.tgz

cd rtlsdr-ogn

chown root gsm_scan
chmod a+s  gsm_scan
chown root ogn-rf
chmod a+s  ogn-rf
chown root rtlsdr-ogn
chmod a+s  rtlsdr-ogn

	rm -f /var/run/ogn-rf.fifo
	mkfifo /var/run/ogn-rf.fifo
	cp -f ogn/rtlsdr-ogn/ogn-rf /usr/bin/
	chmod a+s /usr/bin/ogn-rf
	cp -f ogn/rtlsdr-ogn/ogn-decode /usr/bin/
	chmod a+s /usr/bin/ogn-decode
	
rm -rf rtlsdr-ogn-bin-ARM-latest.tgz

echo "${GREEN}...done${WHITE}"


##############################################################
##  Kalibrate build and installation
##############################################################
echo
echo "${YELLOW}**** Kalibrate build and installation... *****${WHITE}"

cd /root

rm -rf kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap
./configure
make
make install

echo "${GREEN}...done${WHITE}"


##############################################################
##  System tweaks
##############################################################
echo
echo "${YELLOW}**** System tweaks... *****${WHITE}"

##### Some device setup - copy files from image directory ####
cd /root/stratux/image
#motd
cp -f motd /etc/motd

#dhcpd config
cp -f dhcpd.conf /etc/dhcp/dhcpd.conf

#hostapd config
cp -f hostapd.conf /etc/hostapd/hostapd.conf
cp -f hostapd-edimax.conf /etc/hostapd/hostapd-edimax.conf
#hostapd manager script
cp -f hostapd_manager.sh /usr/sbin/hostapd_manager.sh
chmod 755 /usr/sbin/hostapd_manager.sh
#hostapd
cp -f hostapd-edimax /usr/sbin/hostapd-edimax
chmod 755 /usr/sbin/hostapd-edimax
#remove hostapd startup scripts
rm -f /etc/rc*.d/*hostapd /etc/network/if-pre-up.d/hostapd /etc/network/if-post-down.d/hostapd /etc/init.d/hostapd /etc/default/hostapd
#interface config
cp -f interfaces /etc/network/interfaces
#custom hostapd start script
cp stratux-wifi.sh /usr/sbin/
chmod 755 /usr/sbin/stratux-wifi.sh

#SDR Serial Script
cp -f sdr-tool.sh /usr/sbin/sdr-tool.sh
chmod 755 /usr/sbin/sdr-tool.sh

#ping udev
cp -f 99-uavionix.rules /etc/udev/rules.d

#logrotate conf
cp -f logrotate.conf /etc/logrotate.conf

#fan/temp control script
#remove old script
rm -rf /usr/bin/fancontrol.py /usr/bin/fancontrol
#install new program
cp ../fancontrol /usr/bin
chmod 755 /usr/bin/fancontrol
/usr/bin/fancontrol remove
/usr/bin/fancontrol install

#isc-dhcp-server config
cp -f isc-dhcp-server /etc/default/isc-dhcp-server

#sshd config
cp -f sshd_config /etc/ssh/sshd_config

#udev config
cp -f 10-stratux.rules /etc/udev/rules.d

#stratux files
cp -f ../libdump978.so /usr/lib/libdump978.so

#debug aliases
cp -f stxAliases.txt /root/.stxAliases

#rtl-sdr setup
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/

#system tweaks
cp -f modules.txt /etc/modules

#boot settings
cp -f config.txt /boot/

cp /root/stratux/test/screen/screen.py /usr/bin/stratux-screen.py
mkdir -p /etc/stratux-screen/
cp -f /root/stratux/test/screen/stratux-logo-64x64.bmp /etc/stratux-screen/stratux-logo-64x64.bmp
cp -f /root/stratux/test/screen/CnC_Red_Alert.ttf /etc/stratux-screen/CnC_Red_Alert.ttf

#startup scripts
cp -f ../__lib__systemd__system__stratux.service /lib/systemd/system/stratux.service
cp -f ../__root__stratux-pre-start.sh /root/stratux-pre-start.sh
cp -f rc.local /etc/rc.local



echo "${GREEN}...done${WHITE}"


##############################################################
##  WiFi Access Point setup
##############################################################
echo
echo "${YELLOW}**** WiFi Access Point setup... *****${WHITE}"

#. ${SCRIPTDIR}/wifi-ap.sh



##############################################################
## Epilogue
##############################################################
echo
echo
echo "${MAGENTA}**** Setup complete, don't forget to reboot! *****${WHITE}"
echo

echo ${NORMAL}
