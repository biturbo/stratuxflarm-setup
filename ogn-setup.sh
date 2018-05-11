# Copyright (c) 2016 Serge Guex
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "**** OGN install and setup... ******"
echo "************************************"
echo "${WHITE}"

##############################################################
##  OGN install and settings
##############################################################
echo
echo "${YELLOW}**** config settings... *****${WHITE}"

cd /home/pi/opt
rm rtlsdr-ogn-bin-ARM-latest.tgz

wget http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
tar xvzf rtlsdr-ogn-bin-ARM-latest.tgz

cd rtlsdr-ogn
rm -rf ogn-rf.fifo
rm gpu_dev

apt-get -y install libjpeg-dev libconfig-dev fftw3-dev lynx telnet
chown root gsm_scan
chmod a+s  gsm_scan
chown root ogn-rf
chmod a+s  ogn-rf
chown root rtlsdr-ogn
chmod a+s  rtlsdr-ogn
mknod gpu_dev c 100 0
mkfifo ogn-rf.fifo

rm /etc/init.d/rtlsdr-ogn
rm /etc/rtlsdr-ogn.conf

cp ${SCRIPTDIR}/files/rtlsdr-ogn /etc/init.d/rtlsdr-ogn
cp ${SCRIPTDIR}/files/rtlsdr-ogn.conf /etc/rtlsdr-ogn.conf
chmod +x /etc/init.d/rtlsdr-ogn

cp ${SCRIPTDIR}/files/ogn.conf /home/pi/opt/ogn.conf

cp ${SCRIPTDIR}/files/rtlsdr-ogn.service /etc/systemd/system/rtlsdr-ogn.service
systemctl daemon-reload 
#systemctl enable rtlsdr-ogn.service

echo "${GREEN}...done${WHITE}"


