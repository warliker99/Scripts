#!/bin/bash 

#****************************************************************************************************************************

ALD_VERSION="1.4.0"
ASTRA_BASE="http://10.13.81.193/repos/astra17/frozen-base"
ASTRA_EXT="http://10.13.81.193/repos/astra17/frozen-ext"
ALD_MAIN="http://10.13.81.193/repos/astra17/ald-main"
ALD_EXT="http://10.13.81.193/repos/astra17/ald-ext"

HOSTNAME_NEW="030922178a.guo.gazprom.ru"
SEARCH="guo.gazprom.ru"
#IP-адрес DNS серевера для КД на момент установки пакетов из сервера репозитория REP-MAIN, после замениться на 127.0.0.1
NAMESERVERS="10.13.81.190"
PASSWORD_ADMIN="E[fTotYtUjnjdf"

#**************************************************************************************************************************

#Добавление репозиториев Astra Linux
cat <<EOL > /etc/apt/sources.list
deb $ASTRA_BASE 1.7_x86-64 main non-free contrib
deb $ASTRA_EXT 1.7_x86-64 main contrib non-free
EOL

#Добавление репозиториев ALD Pro
cat <<EOL > /etc/apt/sources.list.d/aldpro.list
deb $ALD_MAIN $ALD_VERSION main
deb $ALD_EXT generic main
EOL

#Установка приоритетов репозиториев
cat <<EOL > /etc/apt/preferences.d/aldpro
Package: *
Pin: release n=generic
Pin-Priority: 900
EOL

#Настройка hostname
hostnamectl set-hostname $HOSTNAME_NEW
NAME=`awk -F"." '{print $1}' /etc/hostname`


#Настройка сети
systemctl stop networking
systemctl disable networking
systemctl enable NetworkManager


#Настройка /etc/hosts
cat <<EOL > /etc/hosts
127.0.0.1 localhost
127.0.1.1  $HOSTNAME_NEW $NAME
EOL

#Настройка /etc/resolv.conf
cat <<EOL > /etc/resolv.conf
search $SEARCH
nameserver $NAMESERVERS
EOL

systemctl restart networking
apt update -y
apt upgrade -y



DEBIAN_FRONTEND=noninteractive apt-get install -q -y aldpro-client


systemctl restart networking

/opt/rbta/aldpro/client/bin/aldpro-client-installer -c $SEARCH -u admin -p $PASSWORD_ADMIN -d $NAME -i -f

sleep 10
#reboot
sed -i '/id_provider = ipa/a dyndns_update = true\ndyndns_refresh_interval = 60' /etc/sssd/sssd.conf
systemctl restart sssd 
reboot
