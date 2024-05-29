#!/bin/bash 

#**************************************************************************************************************************

ALD_VERSION="2.3.0"
ASTRA_BASE="http://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.5/repository-base"
ASTRA_EXT="http://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.5/repository-extended"
ALD_MAIN="https://dl.astralinux.ru/aldpro/frozen/01/2.3.0"


HOSTNAME_NEW="dc01.ussov.locale"
IPV4="172.26.71.111"
MASK="255.255.255.0"
GATEWAY="172.26.71.1"
#Domain name
SEARCH="ussov.locale"
#IP-адрес DNS серевера для КД на момент установки пакетов из сервера репозитория REP-MAIN, после замениться на 127.0.0.1
NAMESERVERS="8.8.8.8"
PASSWORD_ADMIN=""

#**************************************************************************************************************************

#Добавление репозиториев Astra Linux
cat <<EOL > /etc/apt/sources.list
deb $ASTRA_BASE 1.7_x86-64 main non-free contrib
deb $ASTRA_EXT 1.7_x86-64 main contrib non-free
EOL

#Обновление ОС
apt update -y
apt install astra-update -y && sudo astra-update -A -r -T

#Добавление репозиториев ALD Pro
cat <<EOL > /etc/apt/sources.list.d/aldpro.list
deb $ALD_MAIN  1.7_x86-64  base  main
EOL

#Установка приоритетов репозиториев
#cat <<EOL > /etc/apt/preferences.d/aldpro
#Package: *
#Pin: release n=generic
#Pin-Priority: 900
#EOL

#Получение короткого имени hostname
hostnamectl set-hostname $HOSTNAME_NEW 
NAME=`awk -F"." '{print $1}' /etc/hostname`


#Настройка сети
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable networking

cat <<EOL > /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IPV4
netmask $MASK
gateway $GATEWAY
dns-nameservers $NAMESERVERS
dns-search $SEARCH
EOL

#Настройка /etc/hosts
cat <<EOL > /etc/hosts
127.0.0.1 localhost.localdomain localhost
$IPV4 $HOSTNAME_NEW $NAME
EOL

#Настройка /etc/resolv.conf
cat <<EOL > /etc/resolv.conf
search $SEARCH
nameserver $NAMESERVERS
EOL

systemctl restart networking
#apt update -y
#apt upgrade -y
apt update &&  apt dist-upgrade -y -o Dpkg::Options::=--force-confnew


#Настройка уровня безопасности
sleep 10
LEVEL=`astra-modeswitch get`

case $LEVEL in
0|1)

        astra-modeswitch set 2
        astra-mic-control enable
        astra-mac-control enable
        echo "Уровень безопасности: Смоленск"
        ;;

2)
        echo "Уровень безопасности: Смоленск"
        ;;
esac

#Установка пакетов
DEBIAN_FRONTEND=noninteractive apt-get install -q -y aldpro-mp aldpro-gc aldpro-syncer


#Настройка сети
cat <<EOL > /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IPV4
netmask $MASK
gateway $GATEWAY
dns-nameservers 127.0.0.1
dns-search $SEARCH
EOL

#Настройка /etc/resolv.conf
cat <<EOL > /etc/resolv.conf
search $SEARCH
nameserver 127.0.0.1
EOL

systemctl restart networking

aldpro-server-install -d $SEARCH  -p $PASSWORD_ADMIN -n $NAME --ip $IPV4  --setup_syncer --setup_gc --no-reboot

sleep 10
reboot

